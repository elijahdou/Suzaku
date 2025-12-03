//
//  HashedWheelTimer.swift
//  Suzaku
//
//  Created by elijah.
//

import Foundation

/// Timeout class can be inherited and customized by external module
open class Timeout {
    
    /// Empty constant
    public static let omit = Timeout(timeInterval: -1, workItem: DispatchWorkItem(block: {}))
    
    fileprivate var remainingRounds: Int64 = 0
    fileprivate var slot: Int64 = 0
    fileprivate let timeInterval: Int64
    fileprivate let workItem: DispatchWorkItem
    
    /// Owning node
    fileprivate weak var node: LinkedListNode<Timeout>?
    
    /// Bucket to which node belongs
    fileprivate weak var bucket: HashedWheelBucket?
    
    /// Repeating task whether it is
    fileprivate let repeating: Bool
    
    public required init(timeInterval: Int64, repeating: Bool = false, workItem: DispatchWorkItem) {
        self.timeInterval = timeInterval
        self.repeating = repeating
        self.workItem = workItem
    }
    
    public func performWork() {
        workItem.perform()
    }
    
    public func cancelWork() {
        workItem.cancel()
    }
    
    public var isCancelled: Bool { workItem.isCancelled }
    
    public func remove() {
        cancelWork()
        bucket?.remove(timeout: self)
    }
}

/// Timer error
public enum TimerError: Error, LocalizedError {
    case invalidWheelNum(desc: String)
    case internalError(desc: String)
    case invalidTimeout(originTime: DispatchTimeInterval)
    
    public var errorDescription: String? {
        switch self {
        case .invalidWheelNum(let desc):
            "Invalid wheel number: \(desc)"
        case .internalError(let desc):
            "Internal error: \(desc)"
        case .invalidTimeout(let originTime):
            "Invalid timeout: \(originTime)"
        }
    }
}

/// Timer, remember to call `stop` when you do not use timer anymore
open class HashedWheelTimer {
    private enum TimerState {
        case pause
        case resume
    }
    
    private var state: TimerState = .pause
    public let dispatchQueue: DispatchQueue
    private let workerQueue: DispatchQueue
    private let queueKey = DispatchSpecificKey<String>()
    private let timer: DispatchSourceTimer
    
    /// Duration of each tick in nanoseconds
    private let tickDuration: Int64
    /// Number of slots in the wheel (power of 2)
    private let ticksPerWheel: Int64
    /// Array of wheel buckets
    private let buckets: [HashedWheelBucket]
    
    /// Tick counter
    private var tick: Int64 = 0
    
    /// Self instance keeper, keeps self alive while timer is running.
    /// Will be set to nil when timer is cancelled.
    private var keeper: Any?
    
    /// Timer constructor
    /// - Parameters:
    ///   - tickDuration: the duration between tick
    ///   - ticksPerWheel: slot num of wheel (will be normalized to power of 2)
    ///   - dispatchQueue: callback queue
    ///   - targetQueue: target queue of internal queue
    /// - Throws: TimerError
    public required init(
        tickDuration: DispatchTimeInterval,
        ticksPerWheel: Int64,
        dispatchQueue: DispatchQueue = .main,
        targetQueue: DispatchQueue? = nil
    ) throws {
        self.dispatchQueue = dispatchQueue
        workerQueue = DispatchQueue(label: "com.suzaku.timer", target: targetQueue)
        workerQueue.setSpecific(key: queueKey, value: workerQueue.label)
        timer = DispatchSource.makeTimerSource(flags: [], queue: workerQueue)
        
        // Normalize tickDuration
        self.tickDuration = try Self.normalize(timeInterval: tickDuration)
        
        // Create wheel and save normalized slot count
        let (wheel, normalizedTicksPerWheel) = try Self.makeWheel(ticksPerWheel: ticksPerWheel)
        self.buckets = wheel
        self.ticksPerWheel = normalizedTicksPerWheel
        
        timer.schedule(deadline: .now(), repeating: .nanoseconds(Int(self.tickDuration)))
        timer.setEventHandler { [weak self] in
            self?.handleEvent()
        }
        timer.setCancelHandler { [weak self] in
            self?.handleCancel()
        }
        keeper = self
    }
    
    deinit {
        // Ensure that the timer does not crash when the timer is directly destructed by multiple threads in the suspended state
        stop()
    }
    
    /// Add timeout task
    /// - Parameters:
    ///   - timeInterval: time interval
    ///   - repeating: Is it a repetitive task
    ///   - block: task
    /// - Throws: invalid time interval, throws TimerError.invalidTimeout
    /// - Returns: timeout object, if timeInterval == 0, do it instantly and return Timeout.omit
    @discardableResult
    public func addTimeout(
        timeInterval: DispatchTimeInterval,
        repeating: Bool = false,
        block: @escaping (_ timer: HashedWheelTimer) -> Void
    ) throws -> Timeout {
        let normalized = try Self.normalize(timeInterval: timeInterval)
        if normalized == 0 {
            block(self)
            return Timeout.omit
        }
        guard normalized >= tickDuration else {
            throw TimerError.internalError(desc: "time interval must be greater than or equal to timer tick granularity")
        }
        let timeout = Timeout(
            timeInterval: normalized,
            repeating: repeating,
            workItem: DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.dispatchQueue.async { block(self) }
            }
        )
        add(timeout: timeout)
        return timeout
    }
    
    /// remove the given `Timeout`
    /// - Parameter timeout: timeout
    public func remove(timeout: Timeout) {
        performAsync {
            timeout.remove()
        }
    }
    
    public func removeAll() {
        performAsync { [weak self] in
            self?.forEachTimeout { $0.remove() }
        }
    }
    
    /// Perform `closure` sync safely
    /// - Parameter closure: callback
    public func performSync(_ closure: () -> Void) {
        if onWorkerQueue() {
            closure()
        } else {
            workerQueue.sync { closure() }
        }
    }
    
    /// Perform `closure` async safely
    /// - Parameter closure: callback
    public func performAsync(_ closure: @escaping () -> Void) {
        workerQueue.async { closure() }
    }
    
    // MARK: - Timer operation
    
    public var isCancelled: Bool { timer.isCancelled }
    
    public func resume() {
        guard state == .pause else { return }
        state = .resume
        timer.resume()
    }
    
    public func pause() {
        guard state == .resume else { return }
        state = .pause
        timer.suspend()
    }
    
    /// Stop timer and remove all `Timeouts` async
    public func stop() {
        guard !timer.isCancelled else { return }
        if state == .pause {
            timer.resume()
        }
        timer.cancel()
        state = .pause
        removeAll()
    }
    
    // MARK: - Private
    
    /// Iterate all timeout in HashedWheelTimer
    /// - Parameter body: A closure that takes an timeout of the HashedWheelTimer as a parameter.
    /// - Throws: rethrow body throw
    private func forEachTimeout(_ body: (Timeout) throws -> Void) rethrows {
        for bucket in buckets where !bucket.isEmpty {
            for node in bucket {
                try body(node.value)
            }
        }
    }
    
    private func handleEvent() {
        tick &+= 1
        let idx = tick & (ticksPerWheel - 1)
        let bucket = buckets[Int(idx)]
        let timeouts = bucket.executeTimeouts(tick: tick)
        guard !timeouts.isEmpty else { return }
        for timeout in timeouts {
            let position = hash(timeInterval: timeout.timeInterval)
            timeout.remainingRounds = position.rounds
            timeout.slot = position.slot
            buckets[Int(timeout.slot)].add(timeout: timeout)
        }
    }
    
    private func handleCancel() {
        keeper = nil
    }
    
    // MARK: - Wheel Setup
    
    private static func makeWheel(ticksPerWheel: Int64) throws -> (wheel: [HashedWheelBucket], normalizedCount: Int64) {
        guard ticksPerWheel > 0 else {
            throw TimerError.invalidWheelNum(desc: "must be positive")
        }
        guard ticksPerWheel < (1 << 30) else {
            throw TimerError.invalidWheelNum(desc: "too big")
        }
        let normalized = normalizeTicksPerWheel(ticksPerWheel)
        let wheel = (0..<normalized).map { _ in HashedWheelBucket() }
        return (wheel, Int64(normalized))
    }
    
    private static func normalizeTicksPerWheel(_ ticksPerWheel: Int64) -> Int {
        var normalized = 1
        while normalized < ticksPerWheel {
            normalized <<= 1
        }
        return normalized
    }
    
    private static func normalize(timeInterval: DispatchTimeInterval) throws -> Int64 {
        let normalized: Int = switch timeInterval {
        case .seconds(let time):
            time * Int(1e9)
        case .milliseconds(let time):
            time * Int(1e6)
        case .microseconds(let time):
            time * Int(1e3)
        case .nanoseconds(let time):
            time
        case .never:
            throw TimerError.invalidTimeout(originTime: timeInterval)
        @unknown default:
            throw TimerError.invalidTimeout(originTime: timeInterval)
        }
        return Int64(normalized)
    }
    
    private func hash(timeInterval: Int64) -> (rounds: Int64, slot: Int64) {
        let total = timeInterval / tickDuration
        let rounds = total / ticksPerWheel
        let untilTicks = tick + total
        let slot = untilTicks & (ticksPerWheel - 1)
        return (rounds, slot)
    }
    
    fileprivate func add(timeout: Timeout) {
        performAsync { [weak self] in
            guard let self else { return }
            let position = hash(timeInterval: timeout.timeInterval)
            timeout.remainingRounds = position.rounds
            timeout.slot = position.slot
            buckets[Int(timeout.slot)].add(timeout: timeout)
        }
    }
    
    private func onWorkerQueue() -> Bool {
        workerQueue.getSpecific(key: queueKey) == workerQueue.label
    }
}


private final class HashedWheelBucket: Sequence {
    private let linkedList = LinkedList<Timeout>()
    
    var isEmpty: Bool { linkedList.isEmpty }
    
    func add(timeout: Timeout) {
        timeout.node = linkedList.append(timeout)
        timeout.bucket = self
    }
    
    func remove(timeout: Timeout) {
        guard let node = timeout.node else { return }
        linkedList.remove(node: node)
    }
    
    func removeAll() {
        linkedList.removeAll()
    }
    
    func makeIterator() -> LinkedList<Timeout>.Iterator {
        linkedList.makeIterator()
    }
    
    func executeTimeouts(tick: Int64) -> [Timeout] {
        guard !linkedList.isEmpty else { return [] }
        
        var repeatingTimeouts: [Timeout] = []
        linkedList.forEach { node in
            var shouldRemove = false
            let timeout = node.value
            
            if timeout.remainingRounds <= 0 {
                // slot > tick should never happen; skip this iteration if it does
                guard timeout.slot <= tick else { return }
                timeout.performWork()
                shouldRemove = true
            } else if timeout.isCancelled {
                shouldRemove = true
            } else {
                timeout.remainingRounds -= 1
            }
            
            if shouldRemove, !linkedList.isEmpty {
                linkedList.remove(node: node)
                if timeout.repeating {
                    repeatingTimeouts.append(timeout)
                }
            }
        }
        return repeatingTimeouts
    }
}

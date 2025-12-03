import XCTest
import Suzaku

class LinkedListTests: XCTestCase {
    
    // MARK: - Basic Operations
    
    func testEmptyList() {
        let list = LinkedList<Int>()
        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.count, 0)
        XCTAssertNil(list.popLast())
    }
    
    func testAppendValue() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 2)
        XCTAssertEqual(list[2], 3)
    }
    
    func testAppendNode() {
        let list = LinkedList<Int>()
        let node1 = LinkedList<Int>.Node(value: 1)
        let node2 = LinkedList<Int>.Node(value: 2)
        list.append(node1)
        list.append(node2)
        
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 2)
    }
    
    func testAppendList() {
        let list1 = LinkedList<Int>()
        list1.append(1)
        list1.append(2)
        
        let list2 = LinkedList<Int>()
        list2.append(3)
        list2.append(4)
        
        list1.append(list2)
        
        XCTAssertEqual(list1.count, 4)
        XCTAssertEqual(list1[0], 1)
        XCTAssertEqual(list1[1], 2)
        XCTAssertEqual(list1[2], 3)
        XCTAssertEqual(list1[3], 4)
        
        // Verify list2 is not affected (values were copied)
        XCTAssertEqual(list2.count, 2)
    }
    
    // MARK: - Insert Operations
    
    func testInsertAtBeginning() {
        let list = LinkedList<Int>()
        list.append(2)
        list.append(3)
        list.insert(1, at: 0)
        
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 2)
        XCTAssertEqual(list[2], 3)
    }
    
    func testInsertAtMiddle() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(3)
        list.insert(2, at: 1)
        
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 2)
        XCTAssertEqual(list[2], 3)
    }
    
    func testInsertAtEnd() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.insert(3, at: 2)
        
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[2], 3)
    }
    
    func testInsertList() {
        let list1 = LinkedList<Int>()
        list1.append(1)
        list1.append(4)
        
        let list2 = LinkedList<Int>()
        list2.append(2)
        list2.append(3)
        
        list1.insert(list2, at: 1)
        
        XCTAssertEqual(list1.count, 4)
        XCTAssertEqual(list1[0], 1)
        XCTAssertEqual(list1[1], 2)
        XCTAssertEqual(list1[2], 3)
        XCTAssertEqual(list1[3], 4)
    }
    
    // MARK: - Remove Operations
    
    func testRemoveNode() {
        let list = LinkedList<Int>()
        let node1 = list.append(1)
        let node2 = list.append(2)
        let node3 = list.append(3)
        
        list.remove(node: node2)
        
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 3)
        
        // Remove head
        list.remove(node: node1)
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list[0], 3)
        
        // Remove tail
        list.remove(node: node3)
        XCTAssertTrue(list.isEmpty)
    }
    
    func testRemoveAtIndex() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        let removed = list.remove(at: 1)
        
        XCTAssertEqual(removed, 2)
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 3)
    }
    
    func testRemoveLast() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        let removed = list.removeLast()
        
        XCTAssertEqual(removed, 3)
        XCTAssertEqual(list.count, 2)
    }
    
    func testPopLast() {
        let list = LinkedList<Int>()
        XCTAssertNil(list.popLast())
        
        list.append(1)
        XCTAssertEqual(list.popLast(), 1)
        XCTAssertTrue(list.isEmpty)
    }
    
    func testRemoveAll() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        list.removeAll()
        
        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.count, 0)
    }
    
    func testRemoveAllWhere() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        list.append(4)
        list.append(5)
        
        list.removeAll { $0 % 2 == 0 }
        
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[1], 3)
        XCTAssertEqual(list[2], 5)
    }
    
    // MARK: - Access Operations
    
    func testNodeAtIndex() {
        let list = LinkedList<Int>()
        for i in 0..<10 {
            list.append(i)
        }
        
        // Test access from head side
        XCTAssertEqual(list.node(at: 0).value, 0)
        XCTAssertEqual(list.node(at: 2).value, 2)
        
        // Test access from tail side (optimization)
        XCTAssertEqual(list.node(at: 7).value, 7)
        XCTAssertEqual(list.node(at: 9).value, 9)
    }
    
    func testSubscript() {
        let list = LinkedList<Int>()
        list.append(10)
        list.append(20)
        list.append(30)
        
        XCTAssertEqual(list[0], 10)
        XCTAssertEqual(list[1], 20)
        XCTAssertEqual(list[2], 30)
    }
    
    // MARK: - Higher-order Functions
    
    func testForEach() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        var sum = 0
        list.forEach { node in
            sum += node.value
        }
        
        XCTAssertEqual(sum, 6)
    }
    
    func testMap() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        let mapped = list.map { $0 * 2 }
        
        XCTAssertEqual(mapped.count, 3)
        XCTAssertEqual(mapped[0], 2)
        XCTAssertEqual(mapped[1], 4)
        XCTAssertEqual(mapped[2], 6)
    }
    
    func testFilter() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        list.append(4)
        list.append(5)
        
        let filtered = list.filter { $0 % 2 == 1 }
        
        XCTAssertEqual(filtered.count, 3)
        XCTAssertEqual(filtered[0], 1)
        XCTAssertEqual(filtered[1], 3)
        XCTAssertEqual(filtered[2], 5)
    }
    
    func testReverse() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        list.reverse()
        
        XCTAssertEqual(list[0], 3)
        XCTAssertEqual(list[1], 2)
        XCTAssertEqual(list[2], 1)
    }
    
    // MARK: - Sequence Conformance
    
    func testSequenceIteration() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        var values: [Int] = []
        for node in list {
            values.append(node.value)
        }
        
        XCTAssertEqual(values, [1, 2, 3])
    }
    
    // MARK: - Array Literal
    
    func testArrayLiteralInit() {
        let list: LinkedList<Int> = [1, 2, 3, 4, 5]
        
        XCTAssertEqual(list.count, 5)
        XCTAssertEqual(list[0], 1)
        XCTAssertEqual(list[4], 5)
    }
    
    // MARK: - Description
    
    func testDescription() {
        let list = LinkedList<Int>()
        list.append(1)
        list.append(2)
        list.append(3)
        
        XCTAssertEqual(list.description, "[1, 2, 3]")
    }
}

// MARK: - HashedWheelTimer Tests

class HashedWheelTimerTests: XCTestCase {
    
    func testTimerCreation() {
        XCTAssertNoThrow(try HashedWheelTimer(tickDuration: .milliseconds(100), ticksPerWheel: 8))
    }
    
    func testTimerCreationWithInvalidWheelNum() {
        XCTAssertThrowsError(try HashedWheelTimer(tickDuration: .milliseconds(100), ticksPerWheel: 0)) { error in
            guard case TimerError.invalidWheelNum = error else {
                XCTFail("Expected invalidWheelNum error")
                return
            }
        }
    }
    
    func testTimerCreationWithTooLargeWheelNum() {
        XCTAssertThrowsError(try HashedWheelTimer(tickDuration: .milliseconds(100), ticksPerWheel: 1 << 31)) { error in
            guard case TimerError.invalidWheelNum = error else {
                XCTFail("Expected invalidWheelNum error")
                return
            }
        }
    }
    
    func testTimeoutExecution() {
        let expectation = XCTestExpectation(description: "Timeout executed")
        
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(50), ticksPerWheel: 8)
        timer.resume()
        
        _ = try? timer.addTimeout(timeInterval: .milliseconds(100)) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        timer.stop()
    }
    
    func testRepeatingTimeout() {
        let expectation = XCTestExpectation(description: "Repeating timeout executed")
        expectation.expectedFulfillmentCount = 3
        
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(50), ticksPerWheel: 8)
        timer.resume()
        
        var count = 0
        _ = try? timer.addTimeout(timeInterval: .milliseconds(100), repeating: true) { timer in
            count += 1
            expectation.fulfill()
            if count >= 3 {
                timer.stop()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testTimeoutCancellation() {
        let expectation = XCTestExpectation(description: "Timeout should not execute")
        expectation.isInverted = true
        
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(50), ticksPerWheel: 8)
        timer.resume()
        
        let timeout = try! timer.addTimeout(timeInterval: .milliseconds(200)) { _ in
            expectation.fulfill()
        }
        
        timeout.remove()
        
        wait(for: [expectation], timeout: 0.5)
        timer.stop()
    }
    
    func testTimerPauseResume() {
        let expectation = XCTestExpectation(description: "Timeout executed after resume")
        
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(50), ticksPerWheel: 8)
        timer.resume()
        timer.pause()
        
        _ = try? timer.addTimeout(timeInterval: .milliseconds(100)) { _ in
            expectation.fulfill()
        }
        
        // Should not execute while paused
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            timer.resume()
        }
        
        wait(for: [expectation], timeout: 1.0)
        timer.stop()
    }
    
    func testTimerStop() {
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(50), ticksPerWheel: 8)
        timer.resume()
        timer.stop()
        
        XCTAssertTrue(timer.isCancelled)
    }
    
    func testZeroTimeoutExecutesImmediately() {
        var executed = false
        
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(50), ticksPerWheel: 8)
        timer.resume()
        
        let timeout = try! timer.addTimeout(timeInterval: .nanoseconds(0)) { _ in
            executed = true
        }
        
        XCTAssertTrue(executed)
        XCTAssertTrue(timeout === Timeout.omit)
        timer.stop()
    }
    
    func testConcurrentAddTimeout() {
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(100), ticksPerWheel: 16)
        timer.resume()
        
        let expectation = XCTestExpectation(description: "All timeouts added")
        expectation.expectedFulfillmentCount = 10
        
        for _ in 0..<10 {
            _ = try? timer.addTimeout(timeInterval: .milliseconds(200)) { _ in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
        timer.stop()
    }
    
    func testTimerErrorDescription() {
        let error1 = TimerError.invalidWheelNum(desc: "test")
        let error2 = TimerError.internalError(desc: "internal")
        let error3 = TimerError.invalidTimeout(originTime: .never)
        
        XCTAssertNotNil(error1.errorDescription)
        XCTAssertNotNil(error2.errorDescription)
        XCTAssertNotNil(error3.errorDescription)
    }
}

// MARK: - Performance Tests

class PerformanceTests: XCTestCase {
    
    func testLinkedListAppendPerformance() {
        measure {
            let list = LinkedList<Int>()
            for i in 0..<10000 {
                list.append(i)
            }
        }
    }
    
    func testLinkedListAccessPerformance() {
        let list = LinkedList<Int>()
        for i in 0..<1000 {
            list.append(i)
        }
        
        measure {
            for i in 0..<1000 {
                _ = list[i]
            }
        }
    }
    
    func testTimerAddTimeoutPerformance() {
        let timer = try! HashedWheelTimer(tickDuration: .milliseconds(100), ticksPerWheel: 512)
        timer.resume()
        
        measure {
            for _ in 0..<1000 {
                _ = try? timer.addTimeout(timeInterval: .seconds(10)) { _ in }
            }
        }
        
        timer.stop()
    }
}

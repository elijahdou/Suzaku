//
//  LinkedList.swift
//  Suzaku
//
//  Created by elijah.
//

import Foundation


/// For easy call
typealias LinkedListNode<T> = LinkedList<T>.Node

/// Double linked list class
public final class LinkedList<T> {
    
    /// Double linked list node class.
    /// Uses the outer class's generic parameter T directly, avoiding redundant declaration.
    public class Node {
        public var value: T
        var next: Node?
        weak var previous: Node?
        
        public init(value: T) {
            self.value = value
        }
    }
    
    /// Head node of double linked list
    private(set) var head: Node?
    
    /// Tail node of double linked list.
    private(set) var tail: Node?
    
    /// Maintains node count, making count an O(1) operation
    private var _count = 0
    
    /// A Boolean value indicating whether a list has no nodes.
    /// - Complexity: O(1)
    public var isEmpty: Bool { head == nil }
    
    /// The number of nodes in the list.
    /// - Complexity: O(1)
    public var count: Int { _count }
    
    /// Default initializer
    public init() {}
    
    
    /// Accesses the value at the given index.
    ///
    /// - Parameter index: value's index to be returned
    public subscript(index: Int) -> T {
        node(at: index).value
    }
    
    /// Accesses the node at the given index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Node's index to be returned
    /// - Returns: Target node
    /// - Complexity: O(n), but traverses from whichever end is closer to the index
    public func node(at index: Int) -> Node {
        checkIndex(index)
        
        // Traverse from the closer end based on index position
        if index < _count / 2 {
            // Start from head
            var node = head!
            for _ in 0..<index {
                node = node.next!
            }
            return node
        } else {
            // Start from tail
            var node = tail!
            for _ in 0..<(_count - 1 - index) {
                node = node.previous!
            }
            return node
        }
    }
    
    /// Adds the value to the end of this list.
    ///
    /// - Parameter value: The data value to be appended
    @discardableResult
    public func append(_ value: T) -> Node {
        let newNode = Node(value: value)
        append(newNode)
        return newNode
    }
    
    /// Adds the node to the end of this list.
    ///
    /// - Parameter node: The node containing the value to be appended
    public func append(_ node: Node) {
        node.previous = tail
        node.next = nil
        
        if let tailNode = tail {
            tailNode.next = node
        } else {
            head = node
        }
        tail = node
        _count += 1
    }
    
    /// Append a copy of a LinkedList to the end of the list.
    /// Note: Copies values instead of sharing node references.
    ///
    /// - Parameter list: The list to be copied and appended.
    public func append(_ list: LinkedList) {
        for node in list {
            append(node.value)
        }
    }
    
    /// Insert a value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - value: The data value to be inserted
    ///   - index: Integer value of the index to be insterted at
    public func insert(_ value: T, at index: Int) {
        let newNode = Node(value: value)
        insert(newNode, at: index)
    }
    
    /// Insert a copy of a node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - node: The node containing the value to be inserted
    ///   - index: Integer value of the index to be inserted at
    public func insert(_ newNode: Node, at index: Int) {
        // Allow insertion at end (index == count)
        precondition(index >= 0, "Negative Array index is out of range: \(index)")
        precondition(index <= _count, "Array index is out of range: \(index)")
        
        if index == 0 {
            newNode.previous = nil
            newNode.next = head
            head?.previous = newNode
            head = newNode
            if tail == nil {
                tail = newNode
            }
            _count += 1
            return
        }
        
        if index == _count {
            // Insert at end, just call append
            append(newNode)
            return
        }
        
        let nextNode = node(at: index)
        let prevNode = nextNode.previous
        
        newNode.previous = prevNode
        newNode.next = nextNode
        prevNode?.next = newNode
        nextNode.previous = newNode
        _count += 1
    }
    
    /// Insert a copy of a LinkedList at a specific index. Crashes if index is out of bounds (0...self.count)
    /// Note: Copies values instead of sharing node references.
    ///
    /// - Parameters:
    ///   - list: The LinkedList to be copied and inserted
    ///   - index: Integer value of the index to be inserted at
    public func insert(_ list: LinkedList, at index: Int) {
        precondition(index >= 0, "Negative Array index is out of range: \(index)")
        precondition(index <= _count, "Array index is out of range: \(index)")
        
        guard !list.isEmpty else { return }
        
        // Insert values one by one to avoid sharing nodes
        var insertIndex = index
        for node in list {
            insert(node.value, at: insertIndex)
            insertIndex += 1
        }
    }
    
    /// Function to remove all nodes/value from the list
    public func removeAll() {
        head = nil
        tail = nil
        _count = 0
    }
    
    /// Function to remove a specific node.
    /// - Parameter node: The node to be removed
    /// - Returns: The deleted node
    @discardableResult
    public func remove(node: Node) -> Node {
        let prev = node.previous
        let next = node.next
        
        if let prev {
            prev.next = next
        } else {
            head = next
        }
        
        if let next {
            next.previous = prev
        } else {
            tail = prev
        }
        
        // Clear the removed node's references
        node.previous = nil
        node.next = nil
        _count -= 1
        
        return node
    }
    
    @discardableResult
    public func popLast() -> T? {
        guard let tail else { return nil }
        return remove(node: tail).value
    }
    
    /// Remove the last node in the list. Crashes if the list is empty
    ///
    /// - Returns: The data value contained in the deleted node.
    @discardableResult
    public func removeLast() -> T {
        remove(node: tail!).value
    }
    
    /// Function to remove a node/value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the index of the node to be removed
    /// - Returns: The data value contained in the deleted node
    @discardableResult
    public func remove(at index: Int) -> T {
        let node = self.node(at: index)
        return remove(node: node).value
    }
    
    public func reverse() {
        var front = head
        var end = tail
        while let f = front, let e = end, f !== e {
            swap(&f.value, &e.value)
            if f.next === e { break }
            front = f.next
            end = e.previous
        }
    }
    
    // MARK: - Higher-order function
    
    public func forEach(_ body: (Node) throws -> Void) rethrows {
        var node = head
        while let nd = node {
            try body(nd)
            // Double check: prevent continuing if list was cleared during traversal
            guard head != nil else { break }
            node = nd.next
        }
    }
    
    public func map<U>(_ transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        for node in self {
            result.append(transform(node.value))
        }
        return result
    }
    
    public func filter(_ isIncluded: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        for node in self {
            if isIncluded(node.value) {
                result.append(node.value)
            }
        }
        return result
    }
    
    /// Removes all nodes that satisfy the given predicate (in-place modification).
    /// - Parameter shouldRemove: A closure that returns true if the node should be removed
    public func removeAll(where shouldRemove: (T) -> Bool) {
        var node = head
        while let current = node {
            let next = current.next
            if shouldRemove(current.value) {
                remove(node: current)
            }
            node = next
        }
    }
    
    /// Check that the specified `index` is valid, i.e. `0 ≤ index ≤ count - 1`.
    /// - Complexity: O(1)
    private func checkIndex(_ index: Int) {
        precondition(index >= 0, "Negative Array index is out of range: \(index)")
        precondition(index <= _count - 1, "Array index is out of range: \(index)")
    }
}

// MARK: - Sequence Conformance
extension LinkedList: Sequence {
    public struct Iterator: IteratorProtocol {
        private var current: Node?
        
        init(start: Node?) {
            self.current = start
        }
        
        public mutating func next() -> Node? {
            defer { current = current?.next }
            return current
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(start: head)
    }
}

// MARK: - Extension to enable initialization from an Array Literal
extension LinkedList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        elements.forEach { append($0) }
    }
}

// MARK: - Custom string convertible
extension LinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var first = true
        for node in self {
            if !first { s += ", " }
            s += "\(node.value)"
            first = false
        }
        return s + "]"
    }
}

extension LinkedList: CustomDebugStringConvertible {
    public var debugDescription: String { description }
}

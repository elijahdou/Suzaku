//
//  LinkedList.swift
//  Suzaku
//
//  Created by elijah.
//

import Foundation


/// For easy call
typealias LinkedListNode<T> = LinkedList<T>.Node<T>

/// Double linked list class
public final class LinkedList<T> {
    
    /// Double linked list node class
    public class Node<T> {
        public var value: T
        var next: Node? = nil
        weak var previous: Node? = nil
        
        public init(value: T) {
            self.value = value
        }
    }
    
    /// Head node of double linked list
    private(set) var head: Node<T>?
    
    /// Tail node of double linked list.
    private(set) var tail: Node<T>? = nil
    
    /// A Boolean value indicating whether a list has no nodes.
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        return head == nil
    }
    
    /// The number of nodes in the list.
    /// - Complexity: O(n)
    public var count: Int {
        var count = 0
        forEach { (_ ) in
            count += 1
        }
        return count
    }
    
    /// Default initializer
    public init() {}
    
    
    /// Accesses the value at the given index.
    ///
    /// - Parameter index: value's index to be returned
    public subscript(index: Int) -> T {
        let node = self.node(at: index)
        return node.value
    }
    
    /// Accesses the node at the given index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Node's index to be returned
    /// - Returns: Target node
    public func node(at index: Int) -> Node<T> {
        checkIndex(index)
        
        if index == 0 {
            return head!
        }
        var node = head!.next
        for _ in 1..<index {
            node = node?.next
            if node == nil {
                break
            }
        }
        return node!
    }
    
    /// Adds the value to the end of this list.
    ///
    /// - Parameter value: The data value to be appended
    @discardableResult public func append(_ value: T) -> Node<T> {
        let newNode = Node(value: value)
        append(newNode)
        return newNode
    }
    
    /// Adds the node to the end of this list.
    ///
    /// - Parameter node: The node containing the value to be appended
    public func append(_ node: Node<T>) {
        guard let head = head else {
            self.head = node
            tail = node
            node.previous = nil
            node.next = nil
            return
        }
        node.previous = tail
        node.next = nil
        if head === tail {
            head.next = node
            head.previous = nil
        }
        tail?.next = node
        tail = node
    }
    
    /// Append a copy of a LinkedList to the end of the list.
    ///
    /// - Parameter list: The list to be copied and appended.
    public func append(_ list: LinkedList) {
        list.forEach { (node) in
            append(node)
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
    public func insert(_ newNode: Node<T>, at index: Int) {
        if index == 0 {
            if head == nil {
                head = newNode
                tail = newNode
                newNode.next = nil
                newNode.previous = nil
                return
            }
            
            newNode.next = head
            newNode.previous = nil
            if head === tail {
                tail!.previous = newNode;
                tail!.next = nil
            }
            head!.previous = newNode
            head = newNode
            return
        }
        let prev = node(at: index - 1)
        let next = prev.next
        newNode.previous = prev
        newNode.next = next
        next?.previous = newNode
        prev.next = newNode
    }
    
    /// Insert a copy of a LinkedList at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - list: The LinkedList to be copied and inserted
    ///   - index: Integer value of the index to be inserted at
    public func insert(_ list: LinkedList, at index: Int) {
        checkIndex(index)
        if index == 0 {
            list.tail?.next = head
            head = list.head
            return
        }
        let prev = node(at: index - 1)
        let next = prev.next
        
        prev.next = list.head
        list.head?.previous = prev
        
        list.tail?.next = next
        next?.previous = list.tail
    }
    
    /// Function to remove all nodes/value from the list
    public func removeAll() {
        head = nil
        tail = nil
    }
    
    /// Function to remove a specific node.
    ///
    /// - Parameter node: The node to be deleted
    /// - Returns: The data value contained in the deleted node.
    public func drop(node: Node<T>) {
        remove(node: node)
    }
    
    /// Function to drop a specific node.
    /// - Parameter node: The node to be droped
    /// - Returns: The deleted node
    @discardableResult public func remove(node: Node<T>) -> Node<T> {
        if (node.previous == nil && node.next == nil) && (head != nil && head === tail) {
            head = nil
            head?.next = nil
            tail = nil
            return node
        }
        let previous = node.previous
        let next = node.next
        if let previous = previous, next == nil {
            previous.next = nil
            tail = previous
            return node
        }
        if previous == nil, let next = next {
            next.previous = nil
            head = next
            return node
        }
        previous?.next = node.next
        next?.previous = node.previous
        return node
    }
    
    @discardableResult public func popLast() -> T? {
        guard !isEmpty else { return nil }
        return removeLast()
    }
    
    /// Remove the last node in the list. Crashes if the list is empty
    ///
    /// - Returns: The data value contained in the deleted node.
    @discardableResult public func removeLast() -> T {
        return remove(node: tail!).value
    }
    
    /// Function to remove a node/value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the index of the node to be removed
    /// - Returns: The data value contained in the deleted node
    @discardableResult public func remove(at index: Int) -> T {
        let node = self.node(at: index)
        return remove(node: node).value
    }
    
    public func reverse() {
        var front = head
        var end = tail
        while let f = front, let e = end, !(f === e) {
            swap(&f.value, &e.value)
            if f.next === e {
                break
            }
            front = f.next
            end = e.previous
        }
    }
    
    // MARK: - Higher-order function
    public func forEach(_ body: (Node<T>) throws -> Void) rethrows {
        var node = head
        while let nd = node {
            try body(nd)
            if head == nil { // double check
                break
            }
            node = nd.next
        }
    }
    
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        forEach { (node) in
            result.append(transform(node.value))
        }
        return result
    }
    
    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        forEach { (node) in
            if predicate(node.value) {
                result.append(node.value)
            }
        }
        return result
    }
    
    public func filtered(predicate: (T) -> Bool) {
        forEach { (node) in
            if predicate(node.value) {
                remove(node: node)
            }
        }
    }
    
    /// Check that the specified `index` is valid, i.e. `0 ≤ index ≤ count - 1`.
    private func checkIndex(_ index: Int) {
        precondition(index <= count - 1, "Array index is out of range: \(index)")
        precondition(index >= 0, "Negative Array index is out of range: \(index)")
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
        forEach { (node) in
            s += "\(node.value)"
            if node.next != nil { s += ", " }
        }
        return s + "]"
    }
}

extension LinkedList: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

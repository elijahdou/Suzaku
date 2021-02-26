//
//  ViewController.swift
//  Suzaku
//
//  Created by elijah.
//  Copyright (c) 2020 elijah. All rights reserved.
//

import UIKit
import Suzaku

class ViewController: UIViewController {
    let timer = try! HashedWheelTimer(tickDuration: .seconds(1), ticksPerWheel: 8, dispatchQueue: DispatchQueue.global())
    var counter = 0
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        let list = LinkedList<Int>()
        list.insert(69, at: 0)
        let n0 = list.append(0)
        let n1 = list.append(1)
        let n2 = list.append(2)
        let n3 = list.append(3)
        list.remove(node: n1)
        list.insert(6, at: 0)
        list.removeLast()
        list.insert(9, at: 2)
//        list.removeAll()
//        list.forEach { (node) in
//            print(node.value)
//            if node.value == 0 {
//                list.removeAll()
//            }
//        }
        print("normal: \(list)")
        list.reverse()
        print("reverse: \(list)")
        print("list count: \(list.count)")
        timer.resume()
        _ = try? timer.addTimeout(timeInterval: .seconds(3), reapting: true, block: { [weak self](timer) in
            guard let self = self else { return }
            self.counter += 1
            print("\(Thread.current) counter: \(self.counter) at \(self.dateFormatter.string(from: Date()))")
            if self.counter == 18 {
                timer.stop()
            }
        })
        
        
        var localTimer = try? HashedWheelTimer(tickDuration: .seconds(1), ticksPerWheel: 1, dispatchQueue: DispatchQueue.global())
        localTimer?.resume()
        print("fire \(self.dateFormatter.string(from: Date()))")
        _ = try? localTimer?.addTimeout(timeInterval: .seconds(5), reapting: true, block: { [weak self](timer) in
            guard let self = self else { return }
            print("\(Thread.current) fired \(self.dateFormatter.string(from: Date()))")
        })
        
        DispatchQueue.concurrentPerform(iterations: 10000) { (_ ) in
            let sec = Int.random(in: 1...10)
            _ = try? localTimer?.addTimeout(timeInterval: .seconds(sec), reapting: false, block: { [weak self](timer) in
                guard let self = self else { return }
                print("\(Thread.current) random \(sec) \(self.dateFormatter.string(from: Date()))")
            })
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 38) {
            localTimer?.stop()
            localTimer = nil
            print("\(Thread.current) remove all \(self.dateFormatter.string(from: Date()))")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


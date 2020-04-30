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
    let timer = try! HashedWheelTimer(tickDuration: .seconds(1), ticksPerWheel: 8, dispatchQueue: nil)
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
        _ = try? timer.addTimeout(timeInterval: .seconds(3), reapting: true) { [weak self, weak timer] in
            guard let self = self, let timer = timer else { return }
            self.counter += 1
            print("counter: \(self.counter) at \(self.dateFormatter.string(from: Date()))")
            if self.counter == 66 {
                timer.removeAll()
                timer.stop()
            }
        }
        
        
        var localTimer: HashedWheelTimer? = try! HashedWheelTimer(tickDuration: .seconds(1), ticksPerWheel: 1, dispatchQueue: nil)
        localTimer?.resume()
        print("fire \(self.dateFormatter.string(from: Date()))")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            _ = try? localTimer?.addTimeout(timeInterval: .seconds(5), reapting: true) { [weak self] in
                guard let self = self else { return }
                print("fired \(self.dateFormatter.string(from: Date()))")
                localTimer?.stop()
                localTimer = nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


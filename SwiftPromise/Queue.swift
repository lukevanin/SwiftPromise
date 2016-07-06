//
//  Queue.swift
//  SwiftPromise
//
//  Created by Luke Van In on 2016/07/05.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import Foundation

internal let DefaultQueue = Queue(DispatchQueue(label: "SwiftPromise.DefaultQueue", attributes: .serial))

internal let MainQueue = Queue(DispatchQueue(label: "SwiftPromise.MainQueue", attributes: .serial, target: DispatchQueue.main))

public enum PromiseQueueType {

    case Background
    case Main

    internal var queue: Queue {
        switch self {
        case .Background:
            return DefaultQueue
        case Main:
            return MainQueue
        }
    }
}

internal struct Queue {

    typealias Block = () -> Void
    typealias Execute = (Block) -> Void

    let _execute: Execute

    init(_ queue: DispatchQueue) {
        _execute = { block in
            queue.async(execute: block)
        }
    }

    init(_ queue: OperationQueue) {
        _execute = queue.addOperation
    }

    init(_ execute: Execute) {
        _execute = execute
    }

    func execute(block: Block) {
        _execute(block)
    }
}

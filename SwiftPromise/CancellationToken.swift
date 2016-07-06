//
//  CancellationToken.swift
//  SwiftPromise
//
//  Created by Luke Van In on 2016/07/05.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import Foundation

public class CancellationToken {

    public typealias Handler = (Void) -> Void

    public var cancelled: Bool {
        return _cancelled
    }

    private let lockQueue = DispatchQueue(
        label: "SwiftPromise.CancellationToken.lockQueue",
        attributes: .serial
    )

    private let eventQueue = DispatchQueue(
        label: "SwiftPromise.CancellationToken.eventQueue",
        attributes: .serial
    )

    private var _cancelled = false

    public init() {
        eventQueue.suspend()
    }

    public func cancel() {
        lockQueue.sync() { [weak self] in

            guard let `self` = self else {
                return
            }

            guard !self.cancelled else {
                return
            }

            self._cancelled = true
            self.eventQueue.resume()
        }
    }

    public func onCancel(handler: Handler) {
        eventQueue.async(execute: handler)
    }
}

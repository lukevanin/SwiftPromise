//
//  Future.swift
//  SwiftPromise
//
//  Created by Luke Van In on 2016/07/05.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import Foundation

public class Future<T> {

    private var result: Result<T>!

    private let lockQueue = DispatchQueue(
        label: "SwiftPromise.Future.lockQueue",
        attributes: .serial
    )

    private let eventQueue = DispatchQueue(
        label: "SwiftPromise.Future.eventQueue",
        attributes: .serial
    )

    public convenience init(value: T) {
        self.init()
        resolve(value: value)
    }

    public convenience init(error: ErrorProtocol) {
        self.init()
        resolve(error: error)
    }

    public convenience init(result: Result<T>) {
        self.init()
        resolve(result: result)
    }

    public required init() {
        eventQueue.suspend()
    }

    public func promise() -> Promise<T> {
        return Promise(future: self)
    }

    @discardableResult public func resolve(value: T) -> Future {
        return resolve(result: .Success(value))
    }

    @discardableResult public func resolve(error: ErrorProtocol) -> Future {
        return resolve(result: .Failure(error))
    }

    @discardableResult public func resolve(result: Result<T>) -> Future {

        lockQueue.sync() {

            guard self.result == nil else {
                return
            }

            self.result = result

            self.eventQueue.resume()
        }

        return self
    }

    internal func onResolve(onQueue queue: Queue, f: (Result<T>) -> Void) {

        eventQueue.async() {

            guard let result = self.result else {
                fatalError("Unexpected nil result. Future was resolved before result was set.")
            }

            queue.execute() {

                f(result)
            }
        }
    }

    internal func onSuccess<U>(onQueue queue: Queue, f: (T) -> Result<U>) -> Promise<U> {

        let output = Future<U>()

        onResolve(onQueue: queue) { result in

            output.resolve(result: result.flatMap(f: f))
        }

        return output.promise()
    }

    internal func onFailure(onQueue queue: Queue, f: (ErrorProtocol) -> Void) {

        onResolve(onQueue: queue) { result in

            if let error = result.error {
                f(error)
            }
        }
    }
}

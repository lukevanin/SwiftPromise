//
//  Promise.swift
//  SwiftPromise
//
//  Created by Luke Van In on 2016/07/05.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import Foundation

public class Promise<T> {

    private var future: Future<T>

    internal init(future: Future<T>) {
        self.future = future
    }
}

extension Promise {

    //
    // then
    //
    public func then(f: Future<T>) -> Promise<T> {
        return then(onQueue: DefaultQueue, f: f)
    }

    public func then(onQueue queue: PromiseQueueType, f: Future<T>) -> Promise<T> {
        return then(onQueue: queue.queue, f: f)
    }

    public func then(onQueue queue: OperationQueue, f: Future<T>) -> Promise<T> {
        return then(onQueue: Queue(queue), f: f)
    }

    public func then(onQueue queue: DispatchQueue, f: Future<T>) -> Promise<T> {
        return then(onQueue: Queue(queue), f: f)
    }

    private func then(onQueue queue: Queue, f: Future<T>) -> Promise<T> {

        _ = then(onQueue: queue, f: f.resolve)

        return f.promise()
    }
}

extension Promise {

    //
    // then
    //
    public func then<U>(f: (Result<T>) throws -> U) -> Promise<U> {
        return then(onQueue: DefaultQueue, f: f)
    }

    public func then<U>(onQueue queue: PromiseQueueType, f: (Result<T>) throws -> U) -> Promise<U> {
        return then(onQueue: queue.queue, f: f)
    }

    public func then<U>(onQueue queue: OperationQueue, f: (Result<T>) throws -> U) -> Promise<U> {
        return then(onQueue: Queue(queue), f: f)
    }

    public func then<U>(onQueue queue: DispatchQueue, f: (Result<T>) throws -> U) -> Promise<U> {
        return then(onQueue: Queue(queue), f: f)
    }

    private func then<U>(onQueue queue: Queue, f: (Result<T>) throws -> U) -> Promise<U> {

        let output = Future<U>()

        future.onResolve(onQueue: queue) { input in

            let result = Result<U>() {
                return try f(input)
            }

            output.resolve(result: result)
        }

        return output.promise()
    }
}

extension Promise {

    //
    // then
    //
    public func then<U>(f: (Result<T>) -> Result<U>) -> Promise<U> {
        return then(onQueue: DefaultQueue, f: f)
    }

    public func then<U>(onQueue queue: PromiseQueueType, f: (Result<T>) -> Result<U>) -> Promise<U> {
        return then(onQueue: queue.queue, f: f)
    }

    public func then<U>(onQueue queue: OperationQueue, f: (Result<T>) -> Result<U>) -> Promise<U> {
        return then(onQueue: Queue(queue), f: f)
    }

    public func then<U>(onQueue queue: DispatchQueue, f: (Result<T>) -> Result<U>) -> Promise<U> {
        return then(onQueue: Queue(queue), f: f)
    }

    private func then<U>(onQueue queue: Queue, f: (Result<T>) -> Result<U>) -> Promise<U> {

        let output = Future<U>()

        future.onResolve(onQueue: queue) { input in

            output.resolve(result: f(input))
        }

        return output.promise()
    }
}

extension Promise {

    //
    // map
    //
    public func map<U>(f: (T) throws -> U) -> Promise<U> {
        return map(onQueue: DefaultQueue, f: f)
    }

    public func map<U>(onQueue queue: PromiseQueueType, f: (T) throws -> U) -> Promise<U> {
        return map(onQueue: queue.queue, f: f)
    }

    public func map<U>(onQueue queue: OperationQueue, f: (T) throws -> U) -> Promise<U> {
        return map(onQueue: Queue(queue), f: f)
    }

    public func map<U>(onQueue queue: DispatchQueue, f: (T) throws -> U) -> Promise<U> {
        return map(onQueue: Queue(queue), f: f)
    }

    private func map<U>(onQueue queue: Queue, f: (T) throws -> U) -> Promise<U> {

        let output = Future<U>()

        future.onResolve(onQueue: queue) { input in

            let result = input.map(f: f)
            output.resolve(result: result)
        }

        return output.promise()
    }
}

extension Promise {

    //
    // map
    //
    public func map<U>(f: (T) -> Result<U>) -> Promise<U> {
        return map(onQueue: DefaultQueue, f: f)
    }

    public func map<U>(onQueue queue: PromiseQueueType, f: (T) -> Result<U>) -> Promise<U> {
        return map(onQueue: queue.queue, f: f)
    }

    public func map<U>(onQueue queue: OperationQueue, f: (T) -> Result<U>) -> Promise<U> {
        return map(onQueue: Queue(queue), f: f)
    }

    public func map<U>(onQueue queue: DispatchQueue, f: (T) -> Result<U>) -> Promise<U> {
        return map(onQueue: Queue(queue), f: f)
    }

    private func map<U>(onQueue queue: Queue, f: (T) -> Result<U>) -> Promise<U> {

        let output = Future<U>()

        future.onResolve(onQueue: queue) { input in

            output.resolve(result: input.flatMap(f: f))
        }

        return output.promise()
    }
}

extension Promise {

    //
    // flatMap
    //

    private func flatMap<U>(onQueue queue: Queue, p: Promise<U>) -> Promise<U> {

        return flatMap(onQueue: queue) { _ in
            return p
        }
    }


    //
    // flatMap
    //

    public func flatMap<U>(f: (T) throws -> Promise<U>) -> Promise<U> {

        return flatMap(onQueue: DefaultQueue, f: f)
    }

    public func flatMap<U>(onQueue queue: PromiseQueueType, f: (T) throws -> Promise<U>) -> Promise<U> {
        return flatMap(onQueue: queue.queue, f: f)
    }

    public func flatMap<U>(onQueue queue: OperationQueue, f: (T) throws -> Promise<U>) -> Promise<U> {
        return flatMap(onQueue: Queue(queue), f: f)
    }

    public func flatMap<U>(onQueue queue: DispatchQueue, f: (T) throws -> Promise<U>) -> Promise<U> {
        return flatMap(onQueue: Queue(queue), f: f)
    }

    private func flatMap<U>(onQueue queue: Queue, f: (T) throws -> Promise<U>) -> Promise<U> {

        let output = Future<U>()

        future.onResolve(onQueue: queue) { result in

            switch result.map(f: f) {

            case .Failure(let error):
                output.resolve(result: .Failure(error))

            case .Success(let promise):
                _ = promise.then(onQueue: queue, f: output.resolve)
            }
        }

        return output.promise()
    }
}

extension Promise {

    //
    // fail
    //
    public func fail(f: (ErrorProtocol) -> Void) {
        fail(onQueue: DefaultQueue, f: f)
    }

    public func fail(onQueue queue: PromiseQueueType, f: (ErrorProtocol) -> Void) {
        return fail(onQueue: queue.queue, f: f)
    }

    public func fail(onQueue queue: OperationQueue, f: (ErrorProtocol) -> Void) {
        return fail(onQueue: Queue(queue), f: f)
    }

    public func fail(onQueue queue: DispatchQueue, f: (ErrorProtocol) -> Void) {
        return fail(onQueue: Queue(queue), f: f)
    }

    private func fail(onQueue queue: Queue, f: (ErrorProtocol) -> Void) {
        return future.onFailure(onQueue: queue, f: f)
    }
}

extension Promise {

    //
    // sequence
    // Wait for multiple promises to complete.
    // Return an array with the results of the promises.
    // Entire sequence fails if any item in the sequence fails.
    //
    public static func sequence(promises: [Promise<T>]) -> Promise<[T]> {
        return sequence(onQueue: .Background, promises: promises)
    }

    public static func sequence(onQueue queue: PromiseQueueType, promises: [Promise<T>]) -> Promise<[T]> {
        return sequence(onQueue: queue.queue, promises: promises)
    }

    public static func sequence(onQueue queue: OperationQueue, promises: [Promise<T>]) -> Promise<[T]> {
        return sequence(onQueue: Queue(queue), promises: promises)
    }

    public static func sequence(onQueue queue: DispatchQueue, promises: [Promise<T>]) -> Promise<[T]> {
        return sequence(onQueue: Queue(queue), promises: promises)
    }

    private static func sequence(onQueue queue: Queue, promises: [Promise<T>]) -> Promise<[T]> {

        let f = Future<[T]>()

        let p = promises
        let v = [T]()

        next(onQueue: queue, promises: p, values: v) { result in
            _ = f.resolve(result: result)
        }

        return f.promise()
    }

    private static func next(onQueue queue: Queue, promises: [Promise<T>], values: [T], completion: (Result<[T]>) -> Void) {

        var p = promises

        guard p.count > 0 else {
            completion(.Success(values))
            return
        }

        let current = p.removeFirst()

        _ = current.map(onQueue: queue) { value in
            var newValues = values
            newValues.append(value)
            next(onQueue: queue, promises: p, values: newValues, completion: completion)
        }

        _ = current.fail(onQueue: queue) { error in

            completion(.Failure(error))
        }
    }
}

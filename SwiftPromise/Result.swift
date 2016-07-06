//
//  Result.swift
//  SwiftPromise
//
//  Created by Luke Van In on 2016/07/05.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import Foundation

public enum Result<T> {

    case Success(T)
    case Failure(ErrorProtocol)

    public var success: Bool {

        switch self {

        case .Success(_):
            return true

        default:
            return false
        }
    }

    public var value: T? {

        switch self {

        case .Success(let value):
            return value

        default:
            return nil

        }
    }

    public var failure: Bool {

        return !success
    }

    public var error: ErrorProtocol? {

        switch self {

        case .Failure(let error):
            return error

        default:
            return nil
        }
    }

    public init(_ error: ErrorProtocol) {

        self = .Failure(error)
    }

    public init(_ value: T) {

        self = .Success(value)
    }

    public init( _ f: @noescape() throws -> T) {

        do {
            self = .Success(try f())
        }
        catch let e {
            self = .Failure(e)
        }
    }
}

extension Result {

    public func map<P>(f: (T) -> P) -> Result<P> {

        switch self {

        case .Success(let value):
            return .Success(f(value))

        case .Failure(let error):
            return .Failure(error)
        }
    }

    public func map<P>(f: (T) throws -> P) -> Result<P> {

        switch self {

        case .Success(let value):

            do {
                return .Success(try f(value))
            }
            catch let error {

                return .Failure(error)
            }

        case .Failure(let error):

            return .Failure(error)
        }
    }

    public func map<P>(f: (T, error: NSErrorPointer) -> P?) -> Result<P> {

        switch self {

        case .Success(let value):

            var error: NSError?

            if let p = f(value, error: &error) {

                return .Success(p)
            }
            else {

                return .Failure(error!)
            }

        case .Failure(let error):
            return .Failure(error)
        }
    }
}

extension Result {

    public func flatMap<P>(f: (T) -> Result<P>) -> Result<P> {

        switch self {

        case .Success(let value):
            return f(value)

        case .Failure(let error):
            return .Failure(error)
        }
    }
}

extension Result {

    public func realize() throws -> T {

        switch self {

        case .Success(let value):
            return value

        case .Failure(let error):
            throw error
        }
    }
}

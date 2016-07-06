//
//  SwiftPromiseTests.swift
//  SwiftPromiseTests
//
//  Created by Luke Van In on 2016/07/05.
//  Copyright © 2016 Luke Van In. All rights reserved.
//

import XCTest

@testable import SwiftPromise

class SwiftPromiseTests: XCTestCase {

    enum Error: ErrorProtocol {
        case Dummy
    }


    // MARK: then() and resolve()

    func testThenResolveSuccess() {

        let x = self.expectation(withDescription: "resolve")

        let f = Future<Int>()

        let p = f.promise()

        var r: Result<Int>!

        _ = p.then() { result in
            r = result
            x.fulfill()
        }

        f.resolve(result: .Success(1))

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertNotNil(r)
        XCTAssertEqual(r.value, 1)
        XCTAssertNil(r.error)
    }

    func testThenResolveFailure() {

        let x = self.expectation(withDescription: "resolve")

        let f = Future<Int>()

        let p = f.promise()

        var r: Result<Int>!

        _ = p.then() { result in
            r = result
            x.fulfill()
        }

        f.resolve(result: .Failure(Error.Dummy))

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertNotNil(r)
        XCTAssertNil(r.value)
        XCTAssertNotNil(r.error)
    }


    // MARK: then() already resolved

    func testThenAlreadyResolvedSuccess() {

        let x = self.expectation(withDescription: "resolve")

        let f = Future<Int>()

        let p = f.promise()

        var r: Result<Int>!

        f.resolve(result: .Success(1))

        _ = p.then() { result in
            r = result
            x.fulfill()
        }

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertNotNil(r)
        XCTAssertEqual(r.value, 1)
        XCTAssertNil(r.error)
    }

    func testThenAlreadyResolvedFailure() {

        let expectation = self.expectation(withDescription: "resolve")

        let f = Future<Int>()

        let p = f.promise()

        var r: Result<Int>!

        f.resolve(result: .Failure(Error.Dummy))

        _ = p.then() { result in
            r = result
            expectation.fulfill()
        }

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertNotNil(r)
        XCTAssertNil(r.value)
        XCTAssertNotNil(r.error)
    }


    // MARK: Resolve

    func testMultipleResolve() {

        let x = expectation(withDescription: "resolve")

        let f = Future<Int>()

        let p = f.promise()

        var r: Result<Int>!

        _ = p.then() { result in
            r = result
            x.fulfill()
        }

        f.resolve(result: .Success(1))

        f.resolve(result: .Success(3))

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertNotNil(r)
        XCTAssertEqual(r.value, 1)
        XCTAssertNil(r.error)
    }


    // MARK: Chain

    func testThenSuccessChain() {

        // Setup
        let x1 = expectation(withDescription: "resolve-1")
        let x2 = expectation(withDescription: "resolve-2")

        let f = Future<Int>()


        // Exercise

        var r1: Result<Int>!
        var r2: Result<String>!

        let p1 = f.promise()

        let p2 = p1.then() { result -> String in
            r1 = result
            x1.fulfill()
            return "abc"
        }

        _ = p2.then() { result in
            r2 = result
            x2.fulfill()
        }

        f.resolve(result: .Success(1))

        waitForExpectations(withTimeout: 0.1, handler: nil)


        // Check
        XCTAssertNotNil(r1)
        XCTAssertEqual(r1.value, 1)
        XCTAssertNil(r1.error)

        XCTAssertNotNil(r2)
        XCTAssertEqual(r2.value, "abc")
        XCTAssertNil(r2.error)

    }

    func testThenFailureChain() {

        // Setup
        let x1 = expectation(withDescription: "resolve-1")
        let x2 = expectation(withDescription: "resolve-2")

        let f = Future<Int>()


        // Exercise

        var r1: Result<Int>!
        var r2: Result<String>!

        let p1 = f.promise()

        let p2 = p1.then() { result -> String in
            r1 = result
            x1.fulfill()
            throw Error.Dummy
        }

        _ = p2.then() { result in
            r2 = result
            x2.fulfill()
        }

        f.resolve(result: .Success(1))

        waitForExpectations(withTimeout: 0.1, handler: nil)


        // Check
        XCTAssertNotNil(r1)
        XCTAssertEqual(r1.value, 1)
        XCTAssertNil(r1.error)

        XCTAssertNotNil(r2)
        XCTAssertNil(r2.value)
        XCTAssertNotNil(r2.error)
    }

    func testThenNested() {

        // Setup
        let x1 = expectation(withDescription: "resolve-1")
        let x2 = expectation(withDescription: "resolve-2")

        let f = Future<Int>()

        // Exercise

        var r1: Result<Int>!
        var r2: Result<Int>!

        let p = f.promise()

        _ = p.then() { result -> String in

            r1 = result
            x1.fulfill()

            _ = p.then() { result -> String in

                r2 = result
                x2.fulfill()

                return "abc"
            }

            return "def"
        }

        f.resolve(result: .Success(1))

        waitForExpectations(withTimeout: 0.1, handler: nil)


        // Check
        XCTAssertNotNil(r1)
        XCTAssertEqual(r1.value, 1)
        XCTAssertNil(r1.error)

        XCTAssertNotNil(r2)
        XCTAssertEqual(r1.value, 1)
        XCTAssertNil(r1.error)
    }


    // MARK: Fail

    func testFail() {

        let x = expectation(withDescription: "resolve")

        let f = Future<Int>()

        let p = f.promise()

        var e: ErrorProtocol!

        p.fail() { error in
            e = error
            x.fulfill()
        }

        f.resolve(result: .Failure(Error.Dummy))

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertNotNil(e)
    }



    // MARK: Map

    func testMapToValue() {

        let f = Future<String>()

        let p1 = f.promise()

        var r1: String!
        var r2: String!

        let x1 = expectation(withDescription: "map-1")

        let p2 = p1.map() { i -> String in
            r1 = i
            x1.fulfill()
            return i + "def"
        }

        let x2 = expectation(withDescription: "map-2")

        _ = p2.map() { i in
            r2 = i
            x2.fulfill()
        }

        f.resolve(result: .Success("abc"))

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertEqual(r1, "abc")
        XCTAssertEqual(r2, "abcdef")
    }


    // MARK: Flat map

    func testFlatMap() {

        let f1 = Future<String>()
        let f2 = Future<String>()

        let p1 = f1.promise()
        let p2 = f2.promise()

        var r1: String!
        var r2: Result<String>!
        var r3: Result<String>!

        // Map returning a promise (p2).
        let x1 = expectation(withDescription: "map-1")
        let p3 = p1.flatMap() { i -> Promise<String> in
            r1 = i
            x1.fulfill()
            return p2
        }

        // Capture result of promise p2. Input should be whatever p2 was resolved with.
        let x2 = expectation(withDescription: "map-2")
        _ = p2.then() { i in
            r2 = i
            x2.fulfill()
        }

        // Take the output of p2 as the input to p3.
        let x3 = expectation(withDescription: "map-3")
        _ = p3.then() { i in
            r3 = i
            x3.fulfill()
        }

        f1.resolve(result: .Success("abc"))
        f2.resolve(result: .Success("def"))

        waitForExpectations(withTimeout: 0.1, handler: nil)

        XCTAssertEqual(r1, "abc") // f1.resolve

        XCTAssertNotNil(r2)
        XCTAssertEqual(r2.value, "def") // f2.resolve

        XCTAssertNotNil(r3)
        XCTAssertEqual(r3.value, "def") // f2.resolve
    }
}

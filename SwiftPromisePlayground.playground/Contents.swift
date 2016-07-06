//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

import SwiftPromise

PlaygroundPage.current.needsIndefiniteExecution = true

let f = Future<String>()

let url = URL(string: "https://api.github.com/zen")!

let task = URLSession.shared().dataTask(with: url) { data, response, error in

    if let data = data {
        let value = String(data: data, encoding: String.Encoding.utf8)
        f.resolve(value: value!)
    }
    else {
        f.resolve(error: error!)
    }
}

task.resume()

f.promise().map() {
    print("Done: \($0)")
}

f.promise().fail() {
    print("Oops, something broke: \($0)")
}


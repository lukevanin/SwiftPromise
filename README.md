# SwiftPromise

Micro framework for using [Futures and Promises][1] in Swift.

More examples and documentation coming soon. Check out `Promise.swift` and the playground example to get started.

Pull requests welcome.

Example:

```
func zen() -> Promise<String> {

    // Create a future.
    let f = Future<String>()

    // Do some asynchronous work.
    let url = URL(string: "https://api.github.com/zen")!

    let task = URLSession.shared().dataTask(with: url) { data, response, error in

        // Resolve the future with a value or error.
        if let data = data {
            let value = String(data: data, encoding: String.Encoding.utf8)
            f.resolve(value: value!)
        }
        else {
            f.resolve(error: error!)
        }
    }

    task.resume()

    // Create the promise.
    return f.promise()
}

// Handle the result.
zen().map() {
    print("Done: \($0)")
}
```

[1]: https://en.wikipedia.org/wiki/Futures_and_promises


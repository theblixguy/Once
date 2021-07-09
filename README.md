# Once

A property wrapper that allows you to enforce that a closure is called exactly once. This is especially useful after the introduction of [SE-0293](https://github.com/apple/swift-evolution/blob/main/proposals/0293-extend-property-wrappers-to-function-and-closure-parameters.md) which makes it legal to place property wrappers on function and closure parameters.

# Motivation

It’s very common to write code where you have a function with a completion handler which must be called with a success or failure value based on the underlying result of the work that the function does. But if you’re not careful, it can be easy to make mistakes where you don’t call the completion handler at all or call it more than once, especially if there’s complicated business logic or error handling.

```swift
func fetchSpecialUser(@Once completion: @escaping (Result<User, Error>) -> Void) {
  fetchUserImpl { user in
    guard let user = user else {
      // oops, forgot to call completion(...) here!
      return
    }
                 
    guard user.isPendingEmailVerification == false else {
      completion(.failure(.userNotVerified))
      return
    }
                 
    if user.hasSubscription {
      switch getSubscriptionType(user) {
        case .ultimate, .premium:
          completion(.success(user))
        case .standard:
          completion(.failure(.noPaidSubscription))
      }
    } else {
      completion(.failure(.userNotSubbed))
    }
                 
    // ... more business logic here
    
    // oops, forgot a 'return' in the if-statement above, 
    // so execution continues and closure is called twice 
    // (and with an invalid result!).
    completion(.failure(.generic))
}
```

## Usage

Simply annotate your function parameters with `@Once` and you will get a runtime error if the closure is not called at all or called more than once.

```swift
func fetchSpecialUser(@Once completion: @escaping (Result<User, Error>) -> Void) {
  fetchUserImpl { user in
    guard let user = user else {
      // runtime error: expected closure to have already been executed once!
      return
    }
                 
    guard user.isPendingEmailVerification == false else {
      completion(.failure(.userNotVerified))
      return
    }
                 
    if user.hasSubscription {
      switch getSubscriptionType(user) {
        case .ultimate, .premium:
          completion(.success(user))
        case .standard:
          completion(.failure(.noPaidSubscription))
      }
    } else {
      completion(.failure(.userNotSubbed))
    }
                 
    // ... more business logic here
    
    // runtime error: closure has already been invoked!
    completion(.failure(.generic))
}
```

#### Note: There's also `@ThrowingOnce` which you can use if the closure throws.

## Requirements

- Swift 5.2 or above

## Limitations

- The property wrapper can only be used with escaping closures. If you want to use it on a non-escaping closure, you will need to annotate it with `@escaping`. This is not ideal, but because the closure is stored inside the property wrapper, there is no way to say to the compiler that the closure does not escape when you know for a fact it doesn't (perhaps because your code is synchronous).

## Installation

Add the following to your project's `Package.swift` file:

```swift
.package(url: "https://github.com/theblixguy/Once", from: "0.0.1")
```

or add this package via the Xcode UI by going to File > Swift Packages > Add Package Dependency.


## License

```
MIT License

Copyright (c) 2021 Suyash Srijan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

/// A property wrapper that wraps a throwing closure which is supposed to be called at least and at most once.
/// If the closure is called more than once or not at all, you will get a runtime error.
@propertyWrapper
public class ThrowingOnce<T, U> {
  fileprivate var state: ClosureState<T, U>

  public var wrappedValue: (T) throws -> U {
    switch state {
      case let .queued(.throws(closure)):
        state = .executed
        return closure
      case let .queued(.nothrows(closure)):
        state = .executed
        return closure
      case .executed:
        fatalError("Closure has already been invoked once!")
    }
  }

  public init(wrappedValue closure: @escaping (T) throws -> U) {
    self.state = .queued(.throws(closure))
  }

  fileprivate init(state closureState: ClosureState<T, U>) {
    self.state = closureState
  }

  deinit {
    switch state {
      case .queued:
        fatalError("Expected closure to have already been executed once!")
      case .executed:
        break
    }
  }
}

/// A property wrapper that wraps a closure which is supposed to be called at least and at most once.
/// If the closure is called more than once or not at all, you will get a runtime error.
@propertyWrapper
public final class Once<T, U>: ThrowingOnce<T, U> {
  public override var wrappedValue: (T) -> U {
    switch state {
      case let .queued(.nothrows(closure)):
        state = .executed
        return closure
      case .queued(.throws):
        fatalError("Unreachable - this property wrapper cannot be initialized with a throwing closure!")
      case .executed:
        fatalError("Closure has already been invoked once!")
    }
  }

  public init(wrappedValue closure: @escaping (T) -> U) {
    super.init(state: .queued(.nothrows(closure)))
  }

  @available(*, unavailable, message: "Use @ThrowingOnce for throwing closures")
  public override init(wrappedValue closure: @escaping (T) throws -> U) {
    fatalError("Unreachable - this function is unavailable!")
  }
}

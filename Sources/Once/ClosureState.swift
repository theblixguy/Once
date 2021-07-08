enum ClosureState<T, U> {
  enum Throwness {
    case `throws`((T) throws -> U)
    case nothrows((T) -> U)
  }
  case queued(Throwness)
  case executed
}

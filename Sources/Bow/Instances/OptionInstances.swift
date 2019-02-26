import Foundation

public class First {}
public class Last {}

/// Wrapper class to represent a constant present first option.
public final class FirstOption<A> {
    public let const: Const<Option<A>, First>

    /// Initializes a constant first option.
    ///
    /// - Parameter value: Value to be wrapped.
    public init(_ value: A) {
        self.const = Const(Option.some(value))
    }

    /// Initializes a constant first option.
    ///
    /// - Parameter value: Option to be wrapped.
    public init(_ value: Option<A>) {
        self.const = Const(value)
    }
}

/// Wrapper class to represent a constant present last option.
public final class LastOption<A> {
    public let const: Const<Option<A>, Last>

    /// Initializes a constant first option.
    ///
    /// - Parameter value: Value to be wrapped.
    public init(_ value: A) {
        self.const = Const(Option.some(value))
    }

    /// Initializes a constant first option.
    ///
    /// - Parameter value: Option to be wrapped.
    public init(_ value: Option<A>) {
        self.const = Const(value)
    }
}

/// Instance of `Semigroup` for `FirstOption`. Keeps the first element that is not `Option.none()`.
extension FirstOption: Semigroup {
    public func combine(_ other: FirstOption<A>) -> FirstOption<A> {
        return self.const.value.fold(constant(false), constant(true)) ? self : other
    }
}

/// Instance of `Monoid` for `FirstOption`. Keeps the first element that is not `Option.none()`.
extension FirstOption: Monoid {
    public static func empty() -> FirstOption<A> {
        return FirstOption(Option.none())
    }
}

/// Instance of `Semigroup` for `LastOption`. Keeps the last element that is not `Option.none()`.
extension LastOption: Semigroup {
    public func combine(_ other: LastOption<A>) -> LastOption<A> {
        return other.const.value.fold(constant(false), constant(true)) ? other : self
    }
}

/// Instance of `Monoid` for `LastOption`. Keeps the first element that is not `Option.none()`.
extension LastOption: Monoid {
    public static func empty() -> LastOption<A> {
        return LastOption(Option.none())
    }
}

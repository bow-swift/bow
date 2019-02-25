import Foundation

public class First {}
public class Last {}

public final class FirstOption<A> {
    public let const: Const<Option<A>, First>

    public init(_ value: A) {
        self.const = Const(Option.some(value))
    }

    public init(_ value: Option<A>) {
        self.const = Const(value)
    }
}

public final class LastOption<A> {
    public let const: Const<Option<A>, Last>

    public init(_ value: A) {
        self.const = Const(Option.some(value))
    }

    public init(_ value: Option<A>) {
        self.const = Const(value)
    }
}

extension FirstOption: Semigroup {
    public func combine(_ other: FirstOption<A>) -> FirstOption<A> {
        return self.const.value.fold(constant(false), constant(true)) ? self : other
    }
}

extension FirstOption: Monoid {
    public static func empty() -> FirstOption<A> {
        return FirstOption(Option.none())
    }
}

extension LastOption: Semigroup {
    public func combine(_ other: LastOption<A>) -> LastOption<A> {
        return other.const.value.fold(constant(false), constant(true)) ? other : self
    }
}

extension LastOption: Monoid {
    public static func empty() -> LastOption<A> {
        return LastOption(Option.none())
    }
}

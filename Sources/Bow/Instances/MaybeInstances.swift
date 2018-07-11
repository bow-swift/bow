import Foundation

public class First {}
public class Last {}

public class FirstMaybeMonoid<B> : Monoid {
    public typealias A = Const<Maybe<B>, First>
    
    public var empty: Const<Maybe<B>, First> {
        return Const(Maybe.none())
    }
    
    public func combine(_ a: Const<Maybe<B>, First>, _ b: Const<Maybe<B>, First>) -> Const<Maybe<B>, First> {
        return a.value.fold(constant(false), constant(true)) ? a : b
    }
}

public class LastMaybeMonoid<B> : Monoid {
    public typealias A = Const<Maybe<B>, Last>
    
    public var empty: Const<Maybe<B>, Last> {
        return Const(Maybe.none())
    }
    
    public func combine(_ a: Const<Maybe<B>, Last>, _ b: Const<Maybe<B>, Last>) -> Const<Maybe<B>, Last> {
        return b.value.fold(constant(false), constant(true)) ? b : a
    }
}

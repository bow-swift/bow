import Foundation

public class First {}
public class Last {}

public class FirstOptionMonoid<B> : Monoid {
    public typealias A = Const<Option<B>, First>
    
    public init() {}
    
    public var empty: Const<Option<B>, First> {
        return Const(Option.none())
    }
    
    public func combine(_ a: Const<Option<B>, First>, _ b: Const<Option<B>, First>) -> Const<Option<B>, First> {
        return a.value.fold(constant(false), constant(true)) ? a : b
    }
}

public class LastOptionMonoid<B> : Monoid {
    public typealias A = Const<Option<B>, Last>
    
    public init() {}
    
    public var empty: Const<Option<B>, Last> {
        return Const(Option.none())
    }
    
    public func combine(_ a: Const<Option<B>, Last>, _ b: Const<Option<B>, Last>) -> Const<Option<B>, Last> {
        return b.value.fold(constant(false), constant(true)) ? b : a
    }
}

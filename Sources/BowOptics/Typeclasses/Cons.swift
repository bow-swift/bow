import Bow

public protocol Cons {
    associatedtype First
    
    static var cons: Prism<Self, (First, Self)> { get }
}

public extension Cons {
    static var firstOption: Optional<Self, First> {
        return cons + Tuple2._0
    }
    
    static var tailOption: Optional<Self, Self> {
        return cons + Tuple2._1
    }
    
    static func cons<B>(_ iso: Iso<B, Self>) -> Prism<B, (First, B)> {
        return iso + cons + iso.reverse().second()
    }
    
    static func cons<B>(_ iso: Iso<First, B>) -> Prism<Self, (B, Self)> {
        return cons + iso.first()
    }
    
    func prepend(_ a: First) -> Self {
        return Self.cons.reverseGet((a, self))
    }
    
    var uncons: Option<(First, Self)> {
        return Self.cons.getOption(self)
    }
}

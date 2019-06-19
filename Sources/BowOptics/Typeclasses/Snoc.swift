import Bow

public protocol Snoc {
    associatedtype Last
    
    static var snoc: Prism<Self, (Self, Last)> { get }
}

public extension Snoc {
    static var initialOption: Optional<Self, Self> {
        return snoc + Tuple2._0
    }
    
    static var lastOption: Optional<Self, Last> {
        return snoc + Tuple2._1
    }
    
    static func snoc<B>(_ iso: Iso<B, Self>) -> Prism<B, (B, Last)> {
        return iso + snoc + iso.reverse().first()
    }
    
    static func snoc<B>(_ iso: Iso<Last, B>) -> Prism<Self, (Self, B)> {
        return snoc + iso.second()
    }
    
    var initial: Option<Self> {
        return Self.initialOption.getOption(self)
    }
    
    func append(_ a: Last) -> Self {
        return Self.snoc.reverseGet((self, a))
    }
    
    var unsnoc: Option<(Self, Last)> {
        return Self.snoc.getOption(self)
    }
}

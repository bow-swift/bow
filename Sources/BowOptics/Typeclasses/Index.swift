public protocol Index {
    associatedtype IndexType
    associatedtype IndexFoci

    static func index(_ i: IndexType) -> Optional<Self, IndexFoci>
}

public extension Index {
    static func index<B>(_ i: IndexType, iso: Iso<B, Self>) -> Optional<B, IndexFoci> {
        return iso + index(i)
    }
    
    static func index<B>(_ i: IndexType, iso: Iso<IndexFoci, B>) -> Optional<Self, B> {
        return index(i) + iso
    }
}

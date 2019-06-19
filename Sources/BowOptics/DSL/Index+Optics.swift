import Bow

public extension Lens where A: Index {
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

public extension Iso where A: Index {
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

public extension Prism where A: Index {
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

public extension Optional where A: Index {
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

public extension Setter where A: Index {
    func index(_ i: A.IndexType) -> Setter<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Setter<S, A.IndexFoci> {
        return self.index(i)
    }
}

public extension Traversal where A: Index {
    func index(_ i: A.IndexType) -> Traversal<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Traversal<S, A.IndexFoci> {
        return self.index(i)
    }
}

public extension Fold where A: Index {
    func index(_ i: A.IndexType) -> Fold<S, A.IndexFoci> {
        return self + A.index(i)
    }
    
    subscript(_ i: A.IndexType) -> Fold<S, A.IndexFoci> {
        return self.index(i)
    }
}

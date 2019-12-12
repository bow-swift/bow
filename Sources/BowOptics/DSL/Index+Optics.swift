import Bow

// MARK: Extension when focus has instance of `Index`
public extension Lens where A: Index, S == T, A == B {
    /// Provides an optional focused on an index of the focus of this lens.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this lens.
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self + A.index(i)
    }
    
    /// Provides an optional focused on an index of the focus of this lens.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this lens.
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

// MARK: Extension when focus has instance of `Index`
public extension Iso where A: Index {
    /// Provides an optional focused on an index of the focus of this iso.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this iso.
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    /// Provides an optional focused on an index of the focus of this iso.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this iso.
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

// MARK: Extension when focus has instance of `Index`
public extension Prism where A: Index {
    /// Provides an optional focused on an index of the focus of this prims.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this prism.
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    /// Provides an optional focused on an index of the focus of this prims.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this prism.
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

// MARK: Extension when focus has instance of `Index`
public extension Optional where A: Index {
    /// Provides an optional focused on an index of the focus of this optional.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this optional.
    func index(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    /// Provides an optional focused on an index of the focus of this optional.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional focused on an index of the focus of this optional.
    subscript(_ i: A.IndexType) -> Optional<S, A.IndexFoci> {
        return self.index(i)
    }
}

// MARK: Extension when focus has instance of `Index`
public extension Setter where A: Index {
    /// Provides a setter focused on an index of the focus of this setter.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A setter focused on an index of the focus of this setter.
    func index(_ i: A.IndexType) -> Setter<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    /// Provides a setter focused on an index of the focus of this setter.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A setter focused on an index of the focus of this setter.
    subscript(_ i: A.IndexType) -> Setter<S, A.IndexFoci> {
        return self.index(i)
    }
}

// MARK: Extension when focus has instance of `Index`
public extension Traversal where A: Index {
    /// Provides a traversal focused on an index of the focus of this traversal.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A traversal focused on an index of the focus of this traversal.
    func index(_ i: A.IndexType) -> Traversal<S, A.IndexFoci> {
        return self.fix + A.index(i)
    }
    
    /// Provides a traversal focused on an index of the focus of this traversal.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A traversal focused on an index of the focus of this traversal.
    subscript(_ i: A.IndexType) -> Traversal<S, A.IndexFoci> {
        return self.index(i)
    }
}

// MARK: Extension when focus has instance of `Index`
public extension Fold where A: Index {
    /// Provides a fold focused on an index of the focus of this fold.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A fold focused on an index of the focus of this fold.
    func index(_ i: A.IndexType) -> Fold<S, A.IndexFoci> {
        return self + A.index(i)
    }
    
    /// Provides a fold focused on an index of the focus of this fold.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A fold focused on an index of the focus of this fold.
    subscript(_ i: A.IndexType) -> Fold<S, A.IndexFoci> {
        return self.index(i)
    }
}

import Foundation
import Bow

// MARK: Extension when focus has `Each` instance
public extension Lens where A: Each, S == T, A == B {
    /// Provides a traversal over all elements of the focus of this lens.
    var every: Traversal<S, A.EachFoci> {
        return self + A.each
    }
}

// MARK: Extension when focus has `Each` instance
public extension Iso where A: Each {
    /// Provides a traversal over all elements of the focus of this iso.
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

// MARK: Extension when focus has `Each` instance
public extension Prism where A: Each {
    /// Provides a traversal over all elements of the focus of this prism.
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

// MARK: Extension when focus has `Each` instance
public extension Optional where A: Each {
    /// Provides a traversal over all elements of the focus of this optional.
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

// MARK: Extension when focus has `Each` instance
public extension Setter where A: Each {
    /// Provides a setter over all elements of the focus of this setter.
    var every: Setter<S, A.EachFoci> {
        return self.fix + A.each
    }
}
// MARK: Extension when focus has `Each` instance
public extension Traversal where A: Each {
    /// Provides a traversal over all elements of the foci of this traversal.
    var every: Traversal<S, A.EachFoci> {
        return self.fix + A.each
    }
}

// MARK: Extension when focus has `Each` instance
public extension Fold where A: Each {
    /// Provides a fold over all elements of the foci of this fold.
    var every: Fold<S, A.EachFoci> {
        return self + A.each
    }
}

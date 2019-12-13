import Foundation
import Bow

// MARK: Extension when focus has `At` Instance
public extension Lens where A: At, S == T, A == B {
    /// Focuses on a specific index of this lens focus.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A composed lens from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Lens<S, A.AtFoci>  {
        return self + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Iso where A: At {
    /// Focuses on a specific index of this iso focus.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A lens from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Lens<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Prism where A: At {
    /// Focuses on a specific index of this prism.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Optional<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Optional where A: At {
    /// Focuses on a specific index of this optional.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: An optional from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Optional<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Getter where A: At {
    /// Focuses on a specific index of this getter.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A getter from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Getter<S, A.AtFoci> {
        return self + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Setter where A: At {
    /// Focuses on a specific index of this setter.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A setter from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Setter<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Traversal where A: At {
    /// Focuses on a specific index of this traversal.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A traversal from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Traversal<S, A.AtFoci> {
        return self.fix + A.at(i)
    }
}

// MARK: Extension when focus has `At` Instance
public extension Fold where A: At {
    /// Focuses on a specific index of this fold.
    ///
    /// - Parameter i: Index to focus.
    /// - Returns: A fold from this structure to the focused index.
    func at(_ i: A.AtIndex) -> Fold<S, A.AtFoci> {
        return self + A.at(i)
    }
}

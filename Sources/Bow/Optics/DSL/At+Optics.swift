import Foundation

public extension Lens {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Lens<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return (self as! Lens<S, A>) + at.at(i)
    }
}

public extension Iso {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Lens<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return (self as! Iso<S, A>) + at.at(i)
    }
}

public extension Prism {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Optional<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return (self as! Prism<S, A>) + at.at(i)
    }
}

public extension Optional {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Optional<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return (self as! Optional<S, A>) + at.at(i)
    }
}

public extension Getter {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Getter<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return self + at.at(i)
    }
}

public extension Setter {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Setter<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return (self as! Setter<S, A>) + at.at(i)
    }
}

public extension Traversal {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Traversal<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return (self as! Traversal<S, A>) + at.at(i)
    }
}

public extension Fold {
    public func at<AtType, I, T>(_ at : AtType, _ i : I) -> Fold<S, T> where AtType : At, AtType.S == A, AtType.I == I, AtType.A == T {
        return self + at.at(i)
    }
}

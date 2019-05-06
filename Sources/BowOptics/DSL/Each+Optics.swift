import Foundation
import Bow

public extension Lens {
    func every<EachType, T>(_ each : EachType) -> Traversal<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return (self as! Lens<S, A>) + each.each()
    }
}

public extension Iso {
    func every<EachType, T>(_ each : EachType) -> Traversal<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return (self as! Iso<S, A>) + each.each()
    }
}

public extension Prism {
    func every<EachType, T>(_ each : EachType) -> Traversal<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return (self as! Prism<S, A>) + each.each()
    }
}

public extension Optional {
    func every<EachType, T>(_ each : EachType) -> Traversal<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return (self as! Optional<S, A>) + each.each()
    }
}

public extension Setter {
    func every<EachType, T>(_ each : EachType) -> Setter<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return (self as! Setter<S, A>) + each.each()
    }
}

public extension Traversal {
    func every<EachType, T>(_ each : EachType) -> Traversal<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return (self as! Traversal<S, A>) + each.each()
    }
}

public extension Fold {
    func every<EachType, T>(_ each : EachType) -> Fold<S, T> where EachType : Each, EachType.S == A, EachType.A == T {
        return self + each.each()
    }
}

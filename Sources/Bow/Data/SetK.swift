import Foundation

public final class ForSetK {}
public typealias SetKOf<A> = Kind<ForSetK, A>

public final class SetK<A: Hashable>: SetKOf<A> {
	fileprivate let set: Set<A>

	public static func +(lhs: SetK<A>, rhs: SetK<A>) -> SetK<A> {
		return SetK(lhs.set.union(rhs.set))
	}
    
	public static func fix(_ fa: SetKOf<A>) -> SetK<A> {
		return fa as! SetK<A>
	}

	public init(_ set: Set<A>) {
		self.set = set
	}

	public var asSet: Set<A> {
		return set
	}

	public func combineK(_ y: SetK<A>) -> SetK<A> {
		return self + y
	}
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to SetK.
public postfix func ^<A>(_ fa: SetKOf<A>) -> SetK<A> {
    return SetK.fix(fa)
}

extension SetK: Semigroup {
    public func combine(_ other: SetK<A>) -> SetK<A> {
        return self + other
    }
}

extension SetK: Monoid {
    public static func empty() -> SetK<A> {
        return SetK(Set([]))
    }
}

public extension Set {
	public func k() -> SetK<Element> {
		return SetK(self)
	}
}

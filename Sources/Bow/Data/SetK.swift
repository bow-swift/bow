import Foundation

public final class ForSetK {}
public typealias SetKOf<A> = Kind<ForSetK, A>

public final class SetK<A: Hashable>: SetKOf<A> {
	fileprivate let set: Set<A>

	public static func +(lhs: SetK<A>, rhs: SetK<A>) -> SetK<A> {
		return SetK(lhs.set.union(rhs.set))
	}

//    public static func pure(_ a: A) -> SetK<A> {
//        return SetK(Set([a]))
//    }

	public static func fix(_ fa: SetKOf<A>) -> SetK<A> {
		return fa as! SetK<A>
	}

	public init(_ set: Set<A>) {
		self.set = set
	}

	public var asSet: Set<A> {
		return set
	}

//    public var isEmpty: Bool {
//        return set.isEmpty
//    }

	public func foldLeft<B>(_ b: B, _ f: (B, A) -> B) -> B {
		return set.reduce(b, f)
	}

//    public func foldRight<B>(_ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
//        func loop(_ skw: SetK<A>) -> Eval<B> {
//            if skw.set.isEmpty {
//                return b
//            } else {
//                return f(skw.set.first!, Eval.deferEvaluation({ loop(Set<A>(skw.set.dropFirst()).k()) }))
//            }
//        }
//        return Eval.deferEvaluation({ loop(self) })
//    }

	public func combineK(_ y: SetK<A>) -> SetK<A> {
		return self + y
	}
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

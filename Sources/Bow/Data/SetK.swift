import Foundation

public final class ForSetK {}
public typealias SetKOf<A> = Kind<ForSetK, A>

public class SetK<A: Hashable> : SetKOf<A> {
	fileprivate let set : Set<A>

	public static func +(lhs : SetK<A>, rhs : SetK<A>) -> SetK<A> {
		return SetK(lhs.set.union(rhs.set))
	}

	public static func pure(_ a : A) -> SetK<A> {
		return SetK(Set([a]))
	}

	public static func empty() -> SetK<A> {
		return SetK(Set([]))
	}

	public static func fix(_ fa : SetKOf<A>) -> SetK<A> {
		return fa.fix()
	}

	public init(_ set : Set<A>) {
		self.set = set
	}

	public var asSet : Set<A> {
		return set
	}

	public var isEmpty : Bool {
		return set.isEmpty
	}

	public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
		return set.reduce(b, f)
	}

	public func foldRight<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
		func loop(_ skw : SetK<A>) -> Eval<B> {
			if skw.set.isEmpty {
				return b
			} else {
				return f(skw.set.first!, Eval.deferEvaluation({ loop(Set<A>(skw.set.dropFirst()).k()) }))
			}
		}
		return Eval.deferEvaluation({ loop(self) })
	}

	public func combineK(_ y : SetK<A>) -> SetK<A> {
		return self + y
	}
}

extension SetK: Fixed {}

public extension Set {
	public func k() -> SetK<Element> {
		return SetK(self)
	}
}

public extension SetK {

	public static func semigroup() -> SemigroupInstance<A> {
		return SemigroupInstance()
	}

	public static func monoid() -> MonoidInstance<A> {
		return MonoidInstance()
	}

	public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, EqA> {
		return EqInstance<A, EqA>(eqa)
	}

    public class SemigroupInstance<R: Hashable>: Semigroup {
        public typealias A = SetKOf<R>

        public func combine(_ a : SetKOf<R>, _ b : SetKOf<R>) -> SetKOf<R>  {
            return SetK<R>.fix(a).combineK(SetK<R>.fix(b))
        }
    }

    public class MonoidInstance<R: Hashable>: SemigroupInstance<R>, Monoid {
        public typealias A = SetKOf<R>

        public var empty: SetKOf<R> {
            return SetK<R>.empty()
        }
    }

    public class EqInstance<R, EqR> : Eq where EqR : Eq, EqR.A == R, EqR.A : Hashable {
        public typealias A = SetKOf<R>

        private let eqr : EqR

        init(_ eqr : EqR) {
            self.eqr = eqr
        }

        public func eqv(_ setA: SetKOf<R>, _ setB: SetKOf<R>) -> Bool {
            let a: SetK<R> = setA.fix()
            let b: SetK<R> = setB.fix()
            if a.set.count != b.set.count {
                return false
            } else {
                return a.set.map { aa in b.set.contains{ bb in self.eqr.eqv(aa, bb) }}.reduce(true, and)
            }
        }
    }
}

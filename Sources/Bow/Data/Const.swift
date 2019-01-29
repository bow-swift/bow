import Foundation

public class ForConst {}
public typealias ConstOf<A, T> = Kind2<ForConst, A, T>
public typealias ConstPartial<A> = Kind<ForConst, A>

public class Const<A, T> : ConstOf<A, T> {
    public let value : A
    
    public static func pure(_ a : A) -> Const<A, T> {
        return Const<A, T>(a)
    }
    
    public static func fix(_ fa : ConstOf<A, T>) -> Const<A, T>{
        return fa as! Const<A, T>
    }
    
    public init(_ value : A) {
        self.value = value
    }
    
    public func retag<U>() -> Const<A, U> {
        return Const<A, U>(value)
    }
    
    public func traverse<F, U, Appl>(_ f : (T) -> Kind<F, U>, _ applicative : Appl) -> Kind<F, ConstOf<A, U>> where Appl : Applicative, Appl.F == F {
        return applicative.pure(retag())
    }
    
    public func traverseFilter<F, U, Appl>(_ f : (T) -> Kind<F, OptionOf<U>>, _ applicative : Appl) -> Kind<F, ConstOf<A, U>> where Appl : Applicative, Appl.F == F {
        return applicative.pure(retag())
    }
    
    public func combine<SemiG>(_ other : Const<A, T>, _ semigroup : SemiG) -> Const<A, T> where SemiG : Semigroup, SemiG.A == A {
        return Const<A, T>(semigroup.combine(self.value, other.value))
    }
    
    public func ap<AA, U, SemiG>(_ fa : Const<A, AA>, _ semigroup : SemiG) -> Const<A, U> where SemiG : Semigroup, SemiG.A == A, T == (AA) -> U {
        return self.retag().combine(fa.retag(), semigroup)
    }
}

extension Const : CustomStringConvertible {
    public var description : String {
        return "Const(\(value))"
    }
}

extension Const : CustomDebugStringConvertible where A : CustomDebugStringConvertible{
    public var debugDescription: String {
        return "Const(\(value.debugDescription))"
    }
}

extension Const : Equatable where A : Equatable {
    public static func ==(lhs : Const<A, T>, rhs : Const<A, T>) -> Bool {
        return lhs.value == rhs.value
    }
}

public extension Const {
    public static func functor() -> FunctorInstance<A> {
        return FunctorInstance<A>()
    }
    
    public static func applicative<Mono>(_ monoid : Mono) -> ApplicativeInstance<A, Mono> {
        return ApplicativeInstance<A, Mono>(monoid)
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> SemigroupInstance<A, T, SemiG> {
        return SemigroupInstance<A, T, SemiG>(semigroup)
    }
    
    public static func monoid<Mono>(_ monoid : Mono) -> MonoidInstance<A, T, Mono> {
        return MonoidInstance<A, T, Mono>(monoid)
    }
    
    public static func foldable() -> FoldableInstance<A> {
        return FoldableInstance<A>()
    }
    
    public static func traverse() -> TraverseInstance<A> {
        return TraverseInstance<A>()
    }
    
    public static func traverseFilter() -> TraverseFilterInstance<A> {
        return TraverseFilterInstance<A>()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, T, EqA> {
        return EqInstance<A, T, EqA>(eqa)
    }

    public class FunctorInstance<R> : Functor {
        public typealias F = ConstPartial<R>
        
        public func map<A, B>(_ fa: ConstOf<R, A>, _ f: @escaping (A) -> B) -> ConstOf<R, B> {
            return Const<R, A>.fix(fa).retag()
        }
    }

    public class ApplicativeInstance<R, Mono> : FunctorInstance<R>, Applicative where Mono : Monoid, Mono.A == R {
        private let monoid : Mono
        
        init(_ monoid : Mono) {
            self.monoid = monoid
        }
        
        public func pure<A>(_ a: A) -> ConstOf<R, A> {
            return MonoidInstance(self.monoid).empty
        }
        
        public func ap<A, B>(_ ff: ConstOf<R, (A) -> B>, _ fa: ConstOf<R, A>) -> ConstOf<R, B> {
            return Const<R, (A) -> B>.fix(ff).ap(Const<R, A>.fix(fa), monoid)
        }
    }

    public class SemigroupInstance<R, S, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
        public typealias A = ConstOf<R, S>
        private let semigroup : SemiG
        
        init(_ semigroup : SemiG) {
            self.semigroup = semigroup
        }
        
        public func combine(_ a: ConstOf<R, S>, _ b: ConstOf<R, S>) -> ConstOf<R, S> {
            return Const<R, S>.fix(a).combine(Const<R, S>.fix(b), semigroup)
        }
    }

    public class MonoidInstance<R, S, Mono> : SemigroupInstance<R, S, Mono>, Monoid where Mono : Monoid, Mono.A == R {
        private let monoid : Mono
        
        override init(_ monoid : Mono) {
            self.monoid = monoid
            super.init(monoid)
        }
        
        public var empty: ConstOf<R, S> {
            return Const<R, S>(monoid.empty)
        }
    }

    public class FoldableInstance<R> : Foldable {
        public typealias F = ConstPartial<R>
        
        public func foldLeft<A, B>(_ fa: ConstOf<R, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return b
        }
        
        public func foldRight<A, B>(_ fa: ConstOf<R, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return b
        }
    }

    public class TraverseInstance<R> : FoldableInstance<R>, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: ConstOf<R, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ConstOf<R, B>> where G == Appl.F, Appl : Applicative {
            return Const<R, A>.fix(fa).traverse(f, applicative)
        }
    }

    public class TraverseFilterInstance<R> : TraverseInstance<R>, TraverseFilter {
        public func traverseFilter<A, B, G, Appl>(_ fa: ConstOf<R, A>, _ f: @escaping (A) -> Kind<G, OptionOf<B>>, _ applicative: Appl) -> Kind<G, ConstOf<R, B>> where G == Appl.F, Appl : Applicative {
            return Const<R, A>.fix(fa).traverseFilter(f, applicative)
        }
    }

    public class EqInstance<R, S, EqR> : Eq where EqR : Eq, EqR.A == R {
        public typealias A = ConstOf<R, S>
        private let eqr : EqR
        
        init(_ eqr : EqR) {
            self.eqr = eqr
        }
        
        public func eqv(_ a: ConstOf<R, S>, _ b: ConstOf<R, S>) -> Bool {
            return eqr.eqv(Const<R, S>.fix(a).value, Const<R, S>.fix(b).value)
        }
    }
}

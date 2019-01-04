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

public extension Const {
    public static func functor() -> ConstFunctor<A> {
        return ConstFunctor<A>()
    }
    
    public static func applicative<Mono>(_ monoid : Mono) -> ConstApplicative<A, Mono> {
        return ConstApplicative<A, Mono>(monoid)
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> ConstSemigroup<A, T, SemiG> {
        return ConstSemigroup<A, T, SemiG>(semigroup)
    }
    
    public static func monoid<Mono>(_ monoid : Mono) -> ConstMonoid<A, T, Mono> {
        return ConstMonoid<A, T, Mono>(monoid)
    }
    
    public static func foldable() -> ConstFoldable<A> {
        return ConstFoldable<A>()
    }
    
    public static func traverse() -> ConstTraverse<A> {
        return ConstTraverse<A>()
    }
    
    public static func traverseFilter() -> ConstTraverseFilter<A> {
        return ConstTraverseFilter<A>()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> ConstEq<A, T, EqA> {
        return ConstEq<A, T, EqA>(eqa)
    }
}

public class ConstFunctor<R> : Functor {
    public typealias F = ConstPartial<R>
    
    public func map<A, B>(_ fa: ConstOf<R, A>, _ f: @escaping (A) -> B) -> ConstOf<R, B> {
        return Const.fix(fa).retag()
    }
}

public class ConstApplicative<R, Mono> : ConstFunctor<R>, Applicative where Mono : Monoid, Mono.A == R {
    private let monoid : Mono
    
    public init(_ monoid : Mono) {
        self.monoid = monoid
    }
    
    public func pure<A>(_ a: A) -> ConstOf<R, A> {
        return ConstMonoid(self.monoid).empty
    }
    
    public func ap<A, B>(_ ff: ConstOf<R, (A) -> B>, _ fa: ConstOf<R, A>) -> ConstOf<R, B> {
        return Const.fix(ff).ap(Const.fix(fa), monoid)
    }
}

public class ConstSemigroup<R, S, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
    public typealias A = ConstOf<R, S>
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: ConstOf<R, S>, _ b: ConstOf<R, S>) -> ConstOf<R, S> {
        return Const.fix(a).combine(Const.fix(b), semigroup)
    }
}

public class ConstMonoid<R, S, Mono> : ConstSemigroup<R, S, Mono>, Monoid where Mono : Monoid, Mono.A == R {
    private let monoid : Mono
    
    override public init(_ monoid : Mono) {
        self.monoid = monoid
        super.init(monoid)
    }
    
    public var empty: ConstOf<R, S> {
        return Const(monoid.empty)
    }
}

public class ConstFoldable<R> : Foldable {
    public typealias F = ConstPartial<R>
    
    public func foldLeft<A, B>(_ fa: ConstOf<R, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return b
    }
    
    public func foldRight<A, B>(_ fa: ConstOf<R, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return b
    }
}

public class ConstTraverse<R> : ConstFoldable<R>, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: ConstOf<R, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ConstOf<R, B>> where G == Appl.F, Appl : Applicative {
        return Const.fix(fa).traverse(f, applicative)
    }
}

public class ConstTraverseFilter<R> : ConstTraverse<R>, TraverseFilter {
    public func traverseFilter<A, B, G, Appl>(_ fa: ConstOf<R, A>, _ f: @escaping (A) -> Kind<G, OptionOf<B>>, _ applicative: Appl) -> Kind<G, ConstOf<R, B>> where G == Appl.F, Appl : Applicative {
        return Const.fix(fa).traverseFilter(f, applicative)
    }
}

public class ConstEq<R, S, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = ConstOf<R, S>
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: ConstOf<R, S>, _ b: ConstOf<R, S>) -> Bool {
        return eqr.eqv(Const.fix(a).value, Const.fix(b).value)
    }
}

extension Const : Equatable where A : Equatable {
    public static func ==(lhs : Const<A, T>, rhs : Const<A, T>) -> Bool {
        return lhs.value == rhs.value
    }
}

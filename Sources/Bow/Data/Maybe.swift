import Foundation

public class ForMaybe {}
public typealias MaybeOf<A> = Kind<ForMaybe, A>

public class Maybe<A> : MaybeOf<A> {
    public static func some(_ a : A) -> Maybe<A> {
        return Some(a)
    }
    
    public static func none() -> Maybe<A> {
        return None()
    }
    
    public static func pure(_ a : A) -> Maybe<A> {
        return some(a)
    }
    
    public static func empty() -> Maybe<A> {
        return None()
    }
    
    public static func fromOption(_ a : A?) -> Maybe<A> {
        if let a = a { return some(a) }
        return none()
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Maybe<Either<A, B>>) -> Maybe<B> {
        return f(a).fold(constant(Maybe<B>.none()),
                         { either in
                            either.fold({ left in tailRecM(left, f) },
                                        Maybe<B>.some)
                         }
        )
    }
    
    public static func fix(_ fa : MaybeOf<A>) -> Maybe<A> {
        return fa.fix()
    }
    
    public var isEmpty : Bool {
        return fold({ true },
                    { _ in false })
    }
    
    internal var isDefined : Bool {
        return !isEmpty
    }
    
    public func fold<B>(_ ifEmpty : () -> B, _ f : (A) -> B) -> B {
        switch self {
            case is Some<A>:
                return f((self as! Some<A>).a)
            case is None<A>:
                return ifEmpty()
            default:
                fatalError("Maybe has only two possible cases")
        }
    }
    
    public func map<B>(_ f : (A) -> B) -> Maybe<B> {
        return fold({ Maybe<B>.none() },
                    { a in Maybe<B>.some(f(a)) })
    }
    
    public func ap<B>(_ ff : Maybe<(A) -> B>) -> Maybe<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> Maybe<B>) -> Maybe<B> {
        return fold(Maybe<B>.none, f)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold({ b },
                    { a in f(b, a) })
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.fold(constant(b),
                         { a in f(a, b) })
    }
    
    public func mapFilter<B>(_ f : (A) -> MaybeOf<B>) -> MaybeOf<B> {
        return self.fold(Maybe<B>.none, f)
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, MaybeOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Maybe<B>.none()) },
                    { a in applicative.map(f(a), Maybe<B>.some)})
    }
    
    public func traverseFilter<G, B, Appl>(_ f : (A) -> Kind<G, MaybeOf<B>>, _ applicative : Appl) -> Kind<G, MaybeOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Maybe<B>.none()) }, f)
    }
    
    public func filter(_ predicate : (A) -> Bool) -> Maybe<A> {
        return fold(constant(Maybe<A>.none()),
                    { a in predicate(a) ? Maybe<A>.some(a) : Maybe<A>.none() })
    }
    
    public func filterNot(_ predicate : @escaping (A) -> Bool) -> Maybe<A> {
        return filter(predicate >>> not)
    }
    
    public func exists(_ predicate : (A) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    public func forall(_ predicate : (A) -> Bool) -> Bool {
        return exists(predicate)
    }
    
    public func getOrElse(_ defaultValue : A) -> A {
        return getOrElse(constant(defaultValue))
    }
    
    public func getOrElse(_ defaultValue : () -> A) -> A {
        return fold(defaultValue, id)
    }
    
    public func orElse(_ defaultValue : Maybe<A>) -> Maybe<A> {
        return orElse(constant(defaultValue))
    }
    
    public func orElse(_ defaultValue : () -> Maybe<A>) -> Maybe<A> {
        return fold(defaultValue, Maybe.some)
    }
    
    public func toOption() -> A? {
        return fold(constant(nil), id)
    }
    
    public func toList() -> [A] {
        return fold(constant([]), { a in [a] })
    }
}

class Some<A> : Maybe<A> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class None<A> : Maybe<A> {}

extension Maybe : CustomStringConvertible {
    public var description : String {
        return fold({ "None" },
                    { a in "Some(\(a))" })
    }
}

extension Maybe : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold(constant("None"),
                    { a in "Some(\(a.debugDescription)" })
    }
}

public extension Kind where F == ForMaybe {
    public func fix() -> Maybe<A> {
        return self as! Maybe<A>
    }
}

public extension Maybe {
    public static func functor() -> MaybeFunctor {
        return MaybeFunctor()
    }
    
    public static func applicative() -> MaybeApplicative {
        return MaybeApplicative()
    }
    
    public static func monad() -> MaybeMonad {
        return MaybeMonad()
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> MaybeSemigroup<A, SemiG> {
        return MaybeSemigroup<A, SemiG>(semigroup)
    }
    
    public static func monoid<SemiG>(_ semigroup : SemiG) -> MaybeMonoid<A, SemiG> {
        return MaybeMonoid<A, SemiG>(semigroup)
    }
    
    public static func monadError() -> MaybeMonadError {
        return MaybeMonadError()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> MaybeEq<A, EqA> {
        return MaybeEq<A, EqA>(eqa)
    }
    
    public static func functorFilter() -> MaybeFunctorFilter {
        return MaybeFunctorFilter()
    }
    
    public static func monadFilter() -> MaybeMonadFilter {
        return MaybeMonadFilter()
    }
    
    public static func foldable() -> MaybeFoldable {
        return MaybeFoldable()
    }
    
    public static func traverse() -> MaybeTraverse {
        return MaybeTraverse()
    }
    
    public static func traverseFilter() -> MaybeTraverseFilter {
        return MaybeTraverseFilter()
    }
}

public class MaybeFunctor : Functor {
    public typealias F = ForMaybe
    
    public func map<A, B>(_ fa: MaybeOf<A>, _ f: @escaping (A) -> B) -> MaybeOf<B> {
        return fa.fix().map(f)
    }
}

public class MaybeApplicative : MaybeFunctor, Applicative {
    public func pure<A>(_ a: A) -> MaybeOf<A> {
        return Maybe.pure(a)
    }
    
    public func ap<A, B>(_ fa: MaybeOf<A>, _ ff: MaybeOf<(A) -> B>) -> MaybeOf<B> {
        return fa.fix().ap(ff.fix())
    }
}

public class MaybeMonad : MaybeApplicative, Monad {
    public func flatMap<A, B>(_ fa: MaybeOf<A>, _ f: @escaping (A) -> MaybeOf<B>) -> MaybeOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> MaybeOf<Either<A, B>>) -> MaybeOf<B> {
        return Maybe<A>.tailRecM(a, { a in f(a).fix() })
    }
}

public class MaybeSemigroup<R, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
    public typealias A = MaybeOf<R>
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: MaybeOf<R>, _ b: MaybeOf<R>) -> MaybeOf<R> {
        let a = Maybe.fix(a)
        let b = Maybe.fix(b)
        return a.fold(constant(b),
                      { aSome in b.fold(constant(a),
                                        { bSome in Maybe.some(semigroup.combine(aSome, bSome)) })
                      })
    }
}

public class MaybeMonoid<R, SemiG> : MaybeSemigroup<R, SemiG>, Monoid where SemiG : Semigroup, SemiG.A == R {
    public var empty : MaybeOf<R>{
        return Maybe<R>.none()
    }
}

public class MaybeMonadError : MaybeMonad, MonadError {
    public typealias E = Unit
    
    public func raiseError<A>(_ e: Unit) -> MaybeOf<A> {
        return Maybe<A>.none()
    }
    
    public func handleErrorWith<A>(_ fa: MaybeOf<A>, _ f: @escaping (Unit) -> MaybeOf<A>) -> MaybeOf<A> {
        return fa.fix().orElse(f(unit).fix())
    }
}

public class MaybeEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = MaybeOf<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: MaybeOf<R>, _ b: MaybeOf<R>) -> Bool {
        let a = Maybe.fix(a)
        let b = Maybe.fix(b)
        return a.fold({ b.fold(constant(true), constant(false)) },
                      { aSome in b.fold(constant(false), { bSome in eqr.eqv(aSome, bSome) })})
    }
}

public class MaybeFunctorFilter : MaybeFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: MaybeOf<A>, _ f: @escaping (A) -> MaybeOf<B>) -> MaybeOf<B> {
        return fa.fix().mapFilter(f)
    }
}

public class MaybeMonadFilter : MaybeMonad, MonadFilter {
    public func empty<A>() -> MaybeOf<A> {
        return Maybe.empty()
    }
    
    public func mapFilter<A, B>(_ fa: Kind<ForMaybe, A>, _ f: @escaping (A) -> Kind<ForMaybe, B>) -> Kind<ForMaybe, B> {
        return fa.fix().mapFilter(f)
    }
}

public class MaybeFoldable : Foldable {
    public typealias F = ForMaybe
    
    public func foldL<A, B>(_ fa: Kind<ForMaybe, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: Kind<ForMaybe, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldR(b, f)
    }
}

public class MaybeTraverse : MaybeFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: Kind<ForMaybe, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<ForMaybe, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class MaybeTraverseFilter : MaybeTraverse, TraverseFilter {
    public func traverseFilter<A, B, G, Appl>(_ fa: Kind<ForMaybe, A>, _ f: @escaping (A) -> Kind<G, MaybeOf<B>>, _ applicative: Appl) -> Kind<G, Kind<ForMaybe, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverseFilter(f, applicative)
    }
}

extension Maybe : Equatable where A : Equatable {
    public static func ==(lhs : Maybe<A>, rhs : Maybe<A>) -> Bool {
        return lhs.fold({ rhs.fold(constant(true), constant(false)) },
                        { a in rhs.fold(constant(false), { b in a == b })})
    }
}

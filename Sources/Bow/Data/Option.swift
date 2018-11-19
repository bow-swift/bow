import Foundation

public class ForOption {}
public typealias OptionOf<A> = Kind<ForOption, A>

public class Option<A> : OptionOf<A> {
    public static func some(_ a : A) -> Option<A> {
        return Some(a)
    }
    
    public static func none() -> Option<A> {
        return None()
    }
    
    public static func pure(_ a : A) -> Option<A> {
        return some(a)
    }
    
    public static func empty() -> Option<A> {
        return None()
    }
    
    public static func fromOption(_ a : A?) -> Option<A> {
        if let a = a { return some(a) }
        return none()
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Option<Either<A, B>>) -> Option<B> {
        return f(a).fold(constant(Option<B>.none()),
                         { either in
                            either.fold({ left in tailRecM(left, f) },
                                        Option<B>.some)
                         }
        )
    }
    
    public static func fix(_ fa : OptionOf<A>) -> Option<A> {
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
                fatalError("Option has only two possible cases")
        }
    }
    
    public func map<B>(_ f : (A) -> B) -> Option<B> {
        return fold({ Option<B>.none() },
                    { a in Option<B>.some(f(a)) })
    }
    
    public func ap<B>(_ ff : Option<(A) -> B>) -> Option<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> Option<B>) -> Option<B> {
        return fold(Option<B>.none, f)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold({ b },
                    { a in f(b, a) })
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.fold(constant(b),
                         { a in f(a, b) })
    }
    
    public func mapFilter<B>(_ f : (A) -> OptionOf<B>) -> OptionOf<B> {
        return self.fold(Option<B>.none, f)
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, OptionOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Option<B>.none()) },
                    { a in applicative.map(f(a), Option<B>.some)})
    }
    
    public func traverseFilter<G, B, Appl>(_ f : (A) -> Kind<G, OptionOf<B>>, _ applicative : Appl) -> Kind<G, OptionOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Option<B>.none()) }, f)
    }
    
    public func filter(_ predicate : (A) -> Bool) -> Option<A> {
        return fold(constant(Option<A>.none()),
                    { a in predicate(a) ? Option<A>.some(a) : Option<A>.none() })
    }
    
    public func filterNot(_ predicate : @escaping (A) -> Bool) -> Option<A> {
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
    
    public func orElse(_ defaultValue : Option<A>) -> Option<A> {
        return orElse(constant(defaultValue))
    }
    
    public func orElse(_ defaultValue : () -> Option<A>) -> Option<A> {
        return fold(defaultValue, Option.some)
    }
    
    public func toOption() -> A? {
        return fold(constant(nil), id)
    }
    
    public func toList() -> [A] {
        return fold(constant([]), { a in [a] })
    }
}

class Some<A> : Option<A> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class None<A> : Option<A> {}

extension Option : CustomStringConvertible {
    public var description : String {
        return fold({ "None" },
                    { a in "Some(\(a))" })
    }
}

extension Option : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold(constant("None"),
                    { a in "Some(\(a.debugDescription)" })
    }
}

public extension Kind where F == ForOption {
    public func fix() -> Option<A> {
        return self as! Option<A>
    }
}

public extension Option {
    public static func functor() -> OptionFunctor {
        return OptionFunctor()
    }
    
    public static func applicative() -> OptionApplicative {
        return OptionApplicative()
    }
    
    public static func monad() -> OptionMonad {
        return OptionMonad()
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> OptionSemigroup<A, SemiG> {
        return OptionSemigroup<A, SemiG>(semigroup)
    }
    
    public static func monoid<SemiG>(_ semigroup : SemiG) -> OptionMonoid<A, SemiG> {
        return OptionMonoid<A, SemiG>(semigroup)
    }
    
    public static func applicativeError() -> OptionMonadError {
        return OptionMonadError()
    }
    
    public static func monadError() -> OptionMonadError {
        return OptionMonadError()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> OptionEq<A, EqA> {
        return OptionEq<A, EqA>(eqa)
    }
    
    public static func functorFilter() -> OptionFunctorFilter {
        return OptionFunctorFilter()
    }
    
    public static func monadFilter() -> OptionMonadFilter {
        return OptionMonadFilter()
    }
    
    public static func foldable() -> OptionFoldable {
        return OptionFoldable()
    }
    
    public static func traverse() -> OptionTraverse {
        return OptionTraverse()
    }
    
    public static func traverseFilter() -> OptionTraverseFilter {
        return OptionTraverseFilter()
    }
}

public class OptionFunctor : Functor {
    public typealias F = ForOption
    
    public func map<A, B>(_ fa: OptionOf<A>, _ f: @escaping (A) -> B) -> OptionOf<B> {
        return fa.fix().map(f)
    }
}

public class OptionApplicative : OptionFunctor, Applicative {
    public func pure<A>(_ a: A) -> OptionOf<A> {
        return Option.pure(a)
    }
    
    public func ap<A, B>(_ fa: OptionOf<A>, _ ff: OptionOf<(A) -> B>) -> OptionOf<B> {
        return fa.fix().ap(ff.fix())
    }
}

public class OptionMonad : OptionApplicative, Monad {
    public func flatMap<A, B>(_ fa: OptionOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> OptionOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> OptionOf<Either<A, B>>) -> OptionOf<B> {
        return Option<A>.tailRecM(a, { a in f(a).fix() })
    }
}

public class OptionSemigroup<R, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
    public typealias A = OptionOf<R>
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: OptionOf<R>, _ b: OptionOf<R>) -> OptionOf<R> {
        let a = Option.fix(a)
        let b = Option.fix(b)
        return a.fold(constant(b),
                      { aSome in b.fold(constant(a),
                                        { bSome in Option.some(semigroup.combine(aSome, bSome)) })
                      })
    }
}

public class OptionMonoid<R, SemiG> : OptionSemigroup<R, SemiG>, Monoid where SemiG : Semigroup, SemiG.A == R {
    public var empty : OptionOf<R>{
        return Option<R>.none()
    }
}

public class OptionMonadError : OptionMonad, MonadError {
    public typealias E = Unit
    
    public func raiseError<A>(_ e: Unit) -> OptionOf<A> {
        return Option<A>.none()
    }
    
    public func handleErrorWith<A>(_ fa: OptionOf<A>, _ f: @escaping (Unit) -> OptionOf<A>) -> OptionOf<A> {
        return fa.fix().orElse(f(unit).fix())
    }
}

public class OptionEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = OptionOf<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: OptionOf<R>, _ b: OptionOf<R>) -> Bool {
        let a = Option.fix(a)
        let b = Option.fix(b)
        return a.fold({ b.fold(constant(true), constant(false)) },
                      { aSome in b.fold(constant(false), { bSome in eqr.eqv(aSome, bSome) })})
    }
}

public class OptionFunctorFilter : OptionFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: OptionOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> OptionOf<B> {
        return fa.fix().mapFilter(f)
    }
}

public class OptionMonadFilter : OptionMonad, MonadFilter {
    public func empty<A>() -> OptionOf<A> {
        return Option.empty()
    }
    
    public func mapFilter<A, B>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<ForOption, B> {
        return fa.fix().mapFilter(f)
    }
}

public class OptionFoldable : Foldable {
    public typealias F = ForOption
    
    public func foldL<A, B>(_ fa: Kind<ForOption, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: Kind<ForOption, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldR(b, f)
    }
}

public class OptionTraverse : OptionFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<ForOption, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class OptionTraverseFilter : OptionTraverse, TraverseFilter {
    public func traverseFilter<A, B, G, Appl>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<G, OptionOf<B>>, _ applicative: Appl) -> Kind<G, Kind<ForOption, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverseFilter(f, applicative)
    }
}

extension Option : Equatable where A : Equatable {
    public static func ==(lhs : Option<A>, rhs : Option<A>) -> Bool {
        return lhs.fold({ rhs.fold(constant(true), constant(false)) },
                        { a in rhs.fold(constant(false), { b in a == b })})
    }
}

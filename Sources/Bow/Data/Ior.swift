import Foundation

public class ForIor {}
public typealias IorOf<A, B> = Kind2<ForIor, A, B>
public typealias IorPartial<A> = Kind<ForIor, A>

public class Ior<A, B> : IorOf<A, B> {
    public static func left(_ a : A) -> Ior<A, B> {
        return IorLeft<A, B>(a)
    }
    
    public static func right(_ b : B) -> Ior<A, B> {
        return IorRight<A, B>(b)
    }
    
    public static func both(_ a : A, _ b : B) -> Ior<A, B> {
        return IorBoth<A, B>(a, b)
    }
    
    public static func fromOptions(_ ma : Option<A>, _ mb : Option<B>) -> Option<Ior<A, B>> {
        return ma.fold({ mb.fold({ Option.none() },
                                 { b in Option.some(Ior.right(b))}) },
                       { a in mb.fold({ Option.some(Ior.left(a)) },
                                      { b in Option.some(Ior.both(a, b))})})
    }
    
    public static func loop<C, SemiG>(_ v : Ior<C, Either<A, B>>,
                                      _ f : @escaping (A) -> Ior<C, Either<A, B>>,
                                      _ semigroup : SemiG) -> Ior<C, B>
        where SemiG : Semigroup, SemiG.A == C {
        return v.fold({ left in Ior<C, B>.left(left) },
                      { right in
                        right.fold({ a in loop(f(a), f, semigroup) },
                                   { b in Ior<C, B>.right(b) })
                      },
                      { left, right in
                        right.fold({ a in
                                      f(a).fold({ aLeft in Ior<C, B>.left(semigroup.combine(aLeft, left)) },
                                                { aRight in loop(Ior<C, Either<A, B>>.both(left, aRight), f, semigroup) },
                                                { aLeft, aRight in loop(Ior<C, Either<A, B>>.both(semigroup.combine(left, aLeft), aRight), f, semigroup)})
                                   },
                                   { b in Ior<C, B>.both(left, b)})
                      })
    }
    
    public static func tailRecM<C, SemiG>(_ a : A, _ f : @escaping (A) -> Kind<IorPartial<C>, Either<A, B>>, _ semigroup : SemiG) -> Ior<C, B> where SemiG : Semigroup, SemiG.A == C {
        return loop(Ior<C, Either<A, B>>.fix(f(a)), { a in Ior<C, Either<A, B>>.fix(f(a)) }, semigroup)
    }
    
    public static func fix(_ fa : IorOf<A, B>) -> Ior<A, B> {
        return fa as! Ior<A, B>
    }
    
    public func fold<C>(_ fa : (A) -> C, _ fb : (B) -> C, _ fab : (A, B) -> C) -> C {
        switch self {
            case is IorLeft<A, B>:
                return (self as! IorLeft<A, B>).a |> fa
            case is IorRight<A, B>:
                return (self as! IorRight<A, B>).b |> fb
            case is IorBoth<A, B>:
                let both = self as! IorBoth<A, B>
                return fab(both.a, both.b)
            default:
                fatalError("Ior must only have left, right or both")
        }
    }
    
    public var isLeft : Bool {
        return fold(constant(true), constant(false), constant(false))
    }
    
    public var isRight : Bool {
        return fold(constant(false), constant(true), constant(false))
    }
    
    public var isBoth : Bool {
        return fold(constant(false), constant(false), constant(true))
    }
    
    public func foldLeft<C>(_ c : C, _ f : (C, B) -> C) -> C {
        return fold(constant(c),
                    { b in f(c, b) },
                    { _, b in f(c, b) })
    }
    
    public func foldRight<C>(_ c : Eval<C>, _ f : (B, Eval<C>) -> Eval<C>) -> Eval<C> {
        return fold(constant(c),
                    { b in f(b, c) },
                    { _, b in f(b, c) })
    }
    
    public func traverse<G, C, Appl>(_ f : (B) -> Kind<G, C>, _ applicative : Appl) -> Kind<G, IorOf<A, C>> where Appl : Applicative, Appl.F == G {
        return fold({ a in applicative.pure(Ior<A, C>.left(a)) },
                    { b in applicative.map(f(b), { c in Ior<A, C>.right(c) }) },
                    { _, b in applicative.map(f(b), { c in Ior<A, C>.right(c) }) })
    }
    
    public func map<C>(_ f : (B) -> C) -> Ior<A, C> {
        return fold(Ior<A, C>.left,
                    { b in Ior<A, C>.right(f(b)) },
                    { a, b in Ior<A, C>.both(a, f(b)) })
    }
    
    public func bimap<C, D>(_ fa : (A) -> C, _ fb : (B) -> D) -> Ior<C, D> {
        return fold({ a in Ior<C, D>.left(fa(a)) },
                    { b in Ior<C, D>.right(fb(b)) },
                    { a, b in Ior<C, D>.both(fa(a), fb(b)) })
    }
    
    public func mapLeft<C>(_ f : (A) -> C) -> Ior<C, B> {
        return fold({ a in Ior<C, B>.left(f(a)) },
                    Ior<C, B>.right,
                    { a, b in Ior<C, B>.both(f(a), b) })
    }
    
    public func flatMap<C, SemiG>(_ f : (B) -> Ior<A, C>, _ semigroup : SemiG) -> Ior<A, C> where SemiG : Semigroup, SemiG.A == A {
        return fold(Ior<A, C>.left,
                    f,
                    { a, b in f(b).fold({ lft in Ior<A, C>.left(semigroup.combine(a, lft)) },
                                        { rgt in Ior<A, C>.right(rgt) },
                                        { lft, rgt in Ior<A, C>.both(semigroup.combine(a, lft), rgt) })
                    })
    }
    
    public func ap<BB, C, SemiG>(_ fa : Ior<A, BB>, _ semigroup : SemiG) -> Ior<A, C> where SemiG : Semigroup, SemiG.A == A, B == (BB) -> C {
        return flatMap(fa.map, semigroup)
    }
    
    public func swap() -> Ior<B, A> {
        return fold(Ior<B, A>.right,
                    Ior<B, A>.left,
                    { a, b in Ior<B, A>.both(b, a) })
    }
    
    public func unwrap() -> Either<Either<A, B>, (A, B)> {
        return fold({ a in Either.left(Either.left(a)) },
                    { b in Either.left(Either.right(b)) },
                    { a, b in Either.right((a, b)) })
    }
    
    public func pad() -> (Option<A>, Option<B>) {
        return fold({ a in (Option.some(a), Option.none()) },
                    { b in (Option.none(), Option.some(b)) },
                    { a, b in (Option.some(a), Option.some(b)) })
    }
    
    public func toEither() -> Either<A, B> {
        return fold(Either.left,
                    Either.right,
                    { _, b in Either.right(b) })
    }
    
    public func toOption() -> Option<B> {
        return fold({ _ in Option<B>.none() },
                    { b in Option<B>.some(b) },
                    { _, b in Option<B>.some(b) })
    }
    
    public func getOrElse(_ defaultValue : B) -> B {
        return fold(constant(defaultValue),
                    id,
                    { _, b in b })
    }
}

class IorLeft<A, B> : Ior<A, B> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class IorRight<A, B> : Ior<A, B> {
    fileprivate let b : B
    
    init(_ b : B) {
        self.b = b
    }
}

class IorBoth<A, B> : Ior<A, B> {
    fileprivate let a : A
    fileprivate let b : B
    
    init(_ a : A, _ b : B) {
        self.a = a
        self.b = b
    }
}

extension Ior : CustomStringConvertible {
    public var description : String {
        return fold({ a in "Left(\(a))" },
                    { b in "Right(\(b))" },
                    { a, b in "Both(\(a),\(b))" })
    }
}

extension Ior : CustomDebugStringConvertible where A : CustomDebugStringConvertible, B : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ a in "Left(\(a.debugDescription))" },
                    { b in "Right(\(b.debugDescription))" },
                    { a, b in "Both(\(a.debugDescription), \(b.debugDescription))" })
    }
}

public extension Ior {
    public static func functor() -> IorFunctor<A> {
        return IorFunctor<A>()
    }
    
    public static func applicative<SemiG>(_ semigroup : SemiG) -> IorApplicative<A, SemiG> {
        return IorApplicative<A, SemiG>(semigroup)
    }
    
    public static func monad<SemiG>(_ semigroup : SemiG) -> IorMonad<A, SemiG> {
        return IorMonad<A, SemiG>(semigroup)
    }
    
    public static func foldable() -> IorFoldable<A> {
        return IorFoldable<A>()
    }
    
    public static func traverse() -> IorTraverse<A> {
        return IorTraverse<A>()
    }
    
    public static func eq<EqA, EqB>(_ eqa : EqA, _ eqb : EqB) -> IorEq<A, B, EqA, EqB> {
        return IorEq<A, B, EqA, EqB>(eqa, eqb)
    }
}

public class IorFunctor<L> : Functor {
    public typealias F = IorPartial<L>
    
    public func map<A, B>(_ fa: IorOf<L, A>, _ f: @escaping (A) -> B) -> IorOf<L, B> {
        return Ior.fix(fa).map(f)
    }
}

public class IorApplicative<L, SemiG> : IorFunctor<L>, Applicative where SemiG : Semigroup, SemiG.A == L {
    fileprivate let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func pure<A>(_ a: A) -> IorOf<L, A> {
        return Ior<L, A>.right(a)
    }
    
    public func ap<A, B>(_ ff: IorOf<L, (A) -> B>, _ fa: IorOf<L, A>) -> IorOf<L, B> {
        return Ior.fix(ff).ap(Ior.fix(fa), semigroup)
    }
}

public class IorMonad<L, SemiG> : IorApplicative<L, SemiG>, Monad where SemiG : Semigroup, SemiG.A == L{
    
    public func flatMap<A, B>(_ fa: IorOf<L, A>, _ f: @escaping (A) -> IorOf<L, B>) -> IorOf<L, B> {
        return Ior.fix(fa).flatMap({ a in Ior.fix(f(a)) }, self.semigroup)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IorOf<L, Either<A, B>>) -> IorOf<L, B> {
        return Ior.tailRecM(a, f, self.semigroup)
    }
}

public class IorFoldable<L> : Foldable {
    public typealias F = IorPartial<L>
    
    public func foldLeft<A, B>(_ fa: IorOf<L, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Ior.fix(fa).foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: IorOf<L, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Ior.fix(fa).foldRight(b, f)
    }
}

public class IorTraverse<L> : IorFoldable<L>, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: IorOf<L, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, IorOf<L, B>> where G == Appl.F, Appl : Applicative {
        return Ior.fix(fa).traverse(f, applicative)
    }
}

public class IorEq<L, R, EqL, EqR> : Eq where EqL : Eq, EqL.A == L, EqR : Eq, EqR.A == R {
    public typealias A = IorOf<L, R>
    
    private let eql : EqL
    private let eqr : EqR
    
    public init(_ eql : EqL, _ eqr : EqR) {
        self.eql = eql
        self.eqr = eqr
    }
    
    public func eqv(_ a: IorOf<L, R>, _ b: IorOf<L, R>) -> Bool {
        let a = Ior.fix(a)
        let b = Ior.fix(b)
        return a.fold({ aLeft in
            b.fold({ bLeft in eql.eqv(aLeft, bLeft) }, constant(false), constant(false))
        },
                      { aRight in
            b.fold(constant(false), { bRight in eqr.eqv(aRight, bRight) }, constant(false))
        },
                      { aLeft, aRight in
            b.fold(constant(false), constant(false), { bLeft, bRight in eql.eqv(aLeft, bLeft) && eqr.eqv(aRight, bRight)})
        })
    }
}

extension Ior : Equatable where A : Equatable, B : Equatable {
    public static func ==(lhs : Ior<A, B>, rhs : Ior<A, B>) -> Bool {
        return lhs.fold({ la in rhs.fold({ ra in la == ra }, constant(false), constant(false)) },
                        { lb in rhs.fold(constant(false), { rb in lb == rb }, constant(false)) },
                        { la, lb in rhs.fold(constant(false), constant(false), { ra, rb in la == ra && lb == rb })})
    }
}

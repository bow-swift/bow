import Foundation

public final class ForIor {}
public final class IorPartial<L>: Kind<ForIor, L> {}
public typealias IorOf<A, B> = Kind<IorPartial<A>, B>

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

    public static func fix(_ fa : IorOf<A, B>) -> Ior<A, B> {
        return fa as! Ior<A, B>
    }
    
    public func fold<C>(_ fa : (A) -> C, _ fb : (B) -> C, _ fab : (A, B) -> C) -> C {
        switch self {
        case let left as IorLeft<A, B>: return fa(left.a)
        case let right as IorRight<A, B>: return fb(right.b)
        case let both as IorBoth<A, B>: return fab(both.a, both.b)
        default: fatalError("Ior must only have left, right or both")
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

public postfix func ^<A, B>(_ fa : IorOf<A, B>) -> Ior<A, B> {
    return Ior.fix(fa)
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

extension Ior: CustomStringConvertible {
    public var description: String {
        return fold({ a in "Left(\(a))" },
                    { b in "Right(\(b))" },
                    { a, b in "Both(\(a),\(b))" })
    }
}

extension Ior: CustomDebugStringConvertible where A: CustomDebugStringConvertible, B: CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ a in "Left(\(a.debugDescription))" },
                    { b in "Right(\(b.debugDescription))" },
                    { a, b in "Both(\(a.debugDescription), \(b.debugDescription))" })
    }
}

extension IorPartial: EquatableK where L: Equatable {
    public static func eq<A>(_ lhs: Kind<IorPartial<L>, A>, _ rhs: Kind<IorPartial<L>, A>) -> Bool where A : Equatable {
        let il = Ior.fix(lhs)
        let ir = Ior.fix(rhs)
        return il.fold({ la in ir.fold({ ra in la == ra }, constant(false), constant(false)) },
                       { lb in ir.fold(constant(false), { rb in lb == rb }, constant(false)) },
                       { la, lb in ir.fold(constant(false), constant(false), { ra, rb in la == ra && lb == rb })})
    }
}

extension IorPartial: Functor {
    public static func map<A, B>(_ fa: Kind<IorPartial<L>, A>, _ f: @escaping (A) -> B) -> Kind<IorPartial<L>, B> {
        let ior = Ior.fix(fa)
        return ior.fold({ a    in Ior.left(a) },
                        { b    in Ior.right(f(b)) },
                        { a, b in Ior.both(a, f(b)) })
    }
}

extension IorPartial: Applicative where L: Semigroup {
    public static func pure<A>(_ a: A) -> Kind<IorPartial<L>, A> {
        return Ior.right(a)
    }
}

extension IorPartial: Monad where L: Semigroup {
    public static func flatMap<A, B>(_ fa: Kind<IorPartial<L>, A>, _ f: @escaping (A) -> Kind<IorPartial<L>, B>) -> Kind<IorPartial<L>, B> {
        return Ior.fix(fa).fold(
            Ior.left,
            f,
            { a, b in Ior.fix(f(b)).fold({ lft in Ior.left(a.combine(lft)) },
                                         { rgt in Ior.right(rgt) },
                                         { lft, rgt in Ior.both(a.combine(lft), rgt) })
        })
    }

    private static func loop<A, B>(_ v : Ior<L, Either<A, B>>,
                                      _ f : @escaping (A) -> Ior<L, Either<A, B>>) -> Ior<L, B> {
            return v.fold({ left in .left(left) },
                          { right in
                            right.fold({ a in loop(f(a), f) },
                                       { b in .right(b) })
            },
                          { left, right in
                            right.fold({ a in
                                f(a).fold({ aLeft in .left(aLeft.combine(left)) },
                                          { aRight in loop(.both(left, aRight), f) },
                                          { aLeft, aRight in loop(.both(left.combine(aLeft), aRight), f) })
                                        },
                                       { b in .both(left, b) })
            })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<IorPartial<L>, Either<A, B>>) -> Kind<IorPartial<L>, B> {
        return loop(Ior.fix(f(a)), { a in Ior.fix(f(a)) })
    }
}

extension IorPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<IorPartial<L>, A>, _ c: B, _ f: @escaping (B, A) -> B) -> B {
        let ior = Ior.fix(fa)
        return ior.fold(constant(c),
                        { b    in f(c, b) },
                        { _, b in f(c, b) })
    }

    public static func foldRight<A, B>(_ fa: Kind<IorPartial<L>, A>, _ c: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let ior = Ior.fix(fa)
        return ior.fold(constant(c),
                        { b    in f(b, c) },
                        { _, b in f(b, c) })
    }
}

extension IorPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<IorPartial<L>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<IorPartial<L>, B>> {
        let ior = Ior.fix(fa)
        return ior.fold({ a    in G.pure(Ior.left(a)) },
                        { b    in f(b).map(Ior.right) },
                        { _, b in f(b).map(Ior.right) })
    }
}

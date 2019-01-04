import Foundation

public class ForEitherT {}
public typealias EitherTOf<F, A, B> = Kind3<ForEitherT, F, A, B>
public typealias EitherTPartial<F, A> = Kind2<ForEitherT, F, A>

public class EitherT<F, A, B> : EitherTOf<F, A, B> {
    fileprivate let value : Kind<F, Either<A, B>>
    
    public static func tailRecM<C, Mon>(_ a : A, _ f : @escaping (A) -> EitherT<F, C, Either<A, B>>, _ monad : Mon) -> EitherT<F, C, B> where Mon : Monad, Mon.F == F {
        return EitherT<F, C, B>(monad.tailRecM(a, { a in
            monad.map(f(a).value, { recursionControl in
                recursionControl.fold({ left in Either.right(Either.left(left)) },
                                      { right in
                                        right.fold({ a in Either.left(a) },
                                                   { b in Either.right(Either.right(b)) })
                })
            })
        }))
    }
    
    public static func left<Appl>(_ a : A, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return EitherT(applicative.pure(Either<A, B>.left(a)))
    }
    
    public static func right<Appl>(_ b : B, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return EitherT(applicative.pure(Either<A, B>.right(b)))
    }
    
    public static func pure<Appl>(_ b : B, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return right(b, applicative)
    }
    
    public static func fromEither<Appl>(_ either : Either<A, B>, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return EitherT(applicative.pure(either))
    }
    
    public static func fix(_ fa : EitherTOf<F, A, B>) -> EitherT<F, A, B> {
        return fa as! EitherT<F, A, B>
    }
    
    public init(_ value : Kind<F, Either<A, B>>) {
        self.value = value
    }
    
    public func fold<C, Func>(_ fa : @escaping (A) -> C, _ fb : @escaping (B) -> C, _ functor : Func) -> Kind<F, C> where Func : Functor, Func.F == F {
        return functor.map(value) { either in either.fold(fa, fb) }
    }
    
    public func map<C, Func>(_ f : @escaping (B) -> C, _ functor : Func) -> EitherT<F, A, C> where Func : Functor, Func.F == F {
        return EitherT<F, A, C>(functor.map(value, { either in either.map(f) }))
    }
    
    public func liftF<C, Func>(_ fc : Kind<F, C>, _ functor : Func) -> EitherT<F, A, C> where Func : Functor, Func.F == F {
        return EitherT<F, A, C>(functor.map(fc, Either<A, C>.right))
    }
    
    public func ap<BB, C, Mon>(_ fa : EitherT<F, A, BB>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F, B == (BB) -> C {
        return flatMap({ f in fa.map(f, monad) }, monad)
    }
    
    public func flatMap<C, Mon>(_ f : @escaping (B) -> EitherT<F, A, C>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return flatMapF({ b in f(b).value }, monad)
    }
    
    public func flatMapF<C, Mon>(_ f : @escaping (B) -> Kind<F, Either<A, C>>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return EitherT<F, A, C>(monad.flatMap(value, { either in
            either.fold({ a in monad.pure(Either<A, C>.left(a)) },
                        { b in f(b) })
        }))
    }
    
    public func cata<C, Func>(_ l : @escaping (A) -> C, _ r : @escaping (B) -> C, _ functor : Func) -> Kind<F, C> where Func : Functor, Func.F == F {
        return fold(l, r, functor)
    }
    
    public func semiflatMap<C, Mon>(_ f : @escaping (B) -> Kind<F, C>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return flatMap({ b in self.liftF(f(b), monad) }, monad)
    }
    
    public func exists<Func>(_ predicate : @escaping (B) -> Bool, _ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { either in either.exists(predicate) })
    }
    
    public func transform<C, D, Func>(_ f : @escaping (Either<A, B>) -> Either<C, D>, _ functor : Func) -> EitherT<F, C, D> where Func : Functor, Func.F == F {
        return EitherT<F, C, D>(functor.map(value, f))
    }
    
    public func subflatpMap<C, Func>(_ f : @escaping (B) -> Either<A, C>, _ functor : Func) -> EitherT<F, A, C> where Func : Functor, Func.F == F {
        return transform({ either in either.flatMap(f) }, functor)
    }
    
    public func toOptionT<Func>(_ functor : Func) -> OptionT<F, B> where Func : Functor, Func.F == F {
        return OptionT<F, B>(functor.map(value, { either in either.toOption() } ))
    }
    
    public func combineK<Mon>(_ y : EitherT<F, A, B>, _ monad : Mon) -> EitherT<F, A, B> where Mon : Monad, Mon.F == F {
        return EitherT<F, A, B>(monad.flatMap(value, { either in
            either.fold(constant(y.value), { b in monad.pure(Either<A, B>.right(b)) })
        }))
    }
}

public extension EitherT {
    public static func functor<Func>(_ functor : Func) -> EitherTFunctor<F, A, Func> {
        return EitherTFunctor<F, A, Func>(functor)
    }
    
    public static func applicative<Mon>(_ monad : Mon) -> EitherTApplicative<F, A, Mon> {
        return EitherTApplicative<F, A, Mon>(monad)
    }
    
    public static func monad<Mon>(_ monad : Mon) -> EitherTMonad<F, A, Mon> {
        return EitherTMonad<F, A, Mon>(monad)
    }
    
    public static func applicativeError<Mon>(_ monad : Mon) -> EitherTMonadError<F, A, Mon> {
        return EitherTMonadError<F, A, Mon>(monad)
    }
    
    public static func monadError<Mon>(_ monad : Mon) -> EitherTMonadError<F, A, Mon> {
        return EitherTMonadError<F, A, Mon>(monad)
    }
    
    public static func semigroupK<Mon>(_ monad : Mon) -> EitherTSemigroupK<F, A, Mon> {
        return EitherTSemigroupK<F, A, Mon>(monad)
    }
    
    public static func eq<EqA, Func>(_ eq : EqA, _ functor : Func) -> EitherTEq<F, A, B, EqA, Func> {
        return EitherTEq<F, A, B, EqA, Func>(eq, functor)
    }
}

public class EitherTFunctor<G, M, Func> : Functor where Func : Functor, Func.F == G {
    public typealias F = EitherTPartial<G, M>
    
    private let functor : Func
    
    public init(_ functor : Func) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: EitherTOf<G, M, A>, _ f: @escaping (A) -> B) -> EitherTOf<G, M, B> {
        return EitherT.fix(fa).map(f, functor)
    }
}

public class EitherTApplicative<G, M, Mon> : EitherTFunctor<G, M, Mon>, Applicative where Mon : Monad, Mon.F == G {
    
    fileprivate let monad : Mon
    
    override public init(_ monad : Mon) {
        self.monad = monad
        super.init(monad)
    }
    
    public func pure<A>(_ a: A) -> EitherTOf<G, M, A> {
        return EitherT<G, M, A>.pure(a, monad)
    }
    
    public func ap<A, B>(_ ff: EitherTOf<G, M, (A) -> B>, _ fa: EitherTOf<G, M, A>) -> EitherTOf<G, M, B> {
        return EitherT.fix(ff).ap(EitherT.fix(fa), monad)
    }
}

public class EitherTMonad<G, M, Mon> : EitherTApplicative<G, M, Mon>, Monad where Mon : Monad, Mon.F == G {
    
    public func flatMap<A, B>(_ fa: EitherTOf<G, M, A>, _ f: @escaping (A) -> EitherTOf<G, M, B>) -> EitherTOf<G, M, B> {
        return EitherT.fix(fa).flatMap({ a in EitherT.fix(f(a)) }, self.monad)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> EitherTOf<G, M, Either<A, B>>) -> EitherTOf<G, M, B> {
        return EitherT.tailRecM(a, { a in EitherT.fix(f(a)) }, self.monad)
    }
}

public class EitherTMonadError<G, M, Mon> : EitherTMonad<G, M, Mon>, MonadError where Mon : Monad, Mon.F == G {
    public typealias E = M
    
    public func raiseError<A>(_ e: M) -> EitherTOf<G, M, A> {
        return EitherT(monad.pure(Either.left(e)))
    }
    
    public func handleErrorWith<A>(_ fa: EitherTOf<G, M, A>, _ f: @escaping (M) -> EitherTOf<G, M, A>) -> EitherTOf<G, M, A> {
        
        return EitherT<G, M, A>(monad.flatMap(EitherT.fix(fa).value, { either in
            either.fold({ left in EitherT.fix(f(left)).value },
                        { right in self.monad.pure(Either<M, A>.right(right)) })
        }))
    }
}

public class EitherTSemigroupK<G, M, Mon> : SemigroupK where Mon : Monad, Mon.F == G {
    public typealias F = EitherTPartial<G, M>
    
    private let monad : Mon
    
    public init(_ monad : Mon) {
        self.monad = monad
    }
    
    public func combineK<A>(_ x: EitherTOf<G, M, A>, _ y: EitherTOf<G, M, A>) -> EitherTOf<G, M, A> {
        return EitherT.fix(x).combineK(EitherT.fix(y), monad)
    }
}

public class EitherTEq<F, L, R, EqA, Func> : Eq where EqA : Eq, EqA.A == Kind<F, EitherOf<L, R>>, Func : Functor, Func.F == F {
    public typealias A = EitherTOf<F, L, R>
    
    private let eq : EqA
    private let functor : Func
    
    public init(_ eq : EqA, _ functor : Func) {
        self.eq = eq
        self.functor = functor
    }
    
    public func eqv(_ a: EitherTOf<F, L, R>, _ b: EitherTOf<F, L, R>) -> Bool {
        let a = EitherT.fix(a)
        let b = EitherT.fix(b)
        return eq.eqv(functor.map(a.value, { a in a as EitherOf<L, R> }),
                      functor.map(b.value, { b in b as EitherOf<L, R> }))
    }
}

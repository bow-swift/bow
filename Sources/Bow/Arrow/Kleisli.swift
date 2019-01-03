import Foundation

public class ForKleisli {}
public typealias ReaderT<F, D, A> = Kleisli<F, D, A>
public typealias KleisliOf<F, D, A> = Kind3<ForKleisli, F, D, A>
public typealias KleisliPartial<F, D> = Kind2<ForKleisli, F, D>

public class Kleisli<F, D, A> : KleisliOf<F, D, A> {
    internal let run : (D) -> Kind<F, A>
    
    public static func fix(_ fa : KleisliOf<F, D, A>) -> Kleisli<F, D, A> {
        return fa as! Kleisli<F, D, A>
    }
    
    public init(_ run : @escaping (D) -> Kind<F, A>) {
        self.run = run
    }
    
    public func ap<AA, B, Appl>(_ fa : Kleisli<F, D, AA>, _ applicative : Appl) -> Kleisli<F, D, B> where Appl : Applicative, Appl.F == F, A == (AA) -> B {
        return Kleisli<F, D, B>({ d in applicative.ap(self.run(d), fa.run(d)) })
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> Kleisli<F, D, B> where Func : Functor, Func.F == F {
        return Kleisli<F, D, B>({ d in functor.map(self.run(d), f) })
    }
    
    public func flatMap<B, Mon>(_ f : @escaping (A) -> Kleisli<F, D, B>, _ monad : Mon)  -> Kleisli<F, D, B> where Mon : Monad, Mon.F == F {
        return Kleisli<F, D, B>({ d in monad.flatMap(self.run(d), { a in f(a).run(d) }) })
    }
    
    public func zip<B, Mon>(_ o : Kleisli<F, D, B>, _ monad : Mon) -> Kleisli<F, D, (A, B)> where Mon : Monad, Mon.F == F {
        return self.flatMap({ a in
            o.map({ b in (a, b) }, monad)
        }, monad)
    }
    
    public func local<DD>(_ f : @escaping (DD) -> D) -> Kleisli<F, DD, A> {
        return Kleisli<F, DD, A>({ dd in self.run(f(dd)) })
    }
    
    public func andThen<C, Mon>(_ f : Kleisli<F, A, C>, _ monad : Mon) -> Kleisli<F, D, C> where Mon : Monad, Mon.F == F {
        return andThen(f.run, monad)
    }
    
    public func andThen<B, Mon>(_ f : @escaping (A) -> Kind<F, B>, _ monad : Mon) -> Kleisli<F, D, B> where Mon : Monad, Mon.F == F {
        return Kleisli<F, D, B>({ d in monad.flatMap(self.run(d), f) })
    }
    
    public func andThen<B, Mon>(_ a : Kind<F, B>, _ monad : Mon) -> Kleisli<F, D, B> where Mon : Monad, Mon.F == F {
        return andThen({ _ in a }, monad)
    }
    
    public func handleErrorWith<E, MonErr>(_ f : @escaping (E) -> Kleisli<F, D, A>, _ monadError : MonErr) -> Kleisli<F, D, A> where MonErr : MonadError, MonErr.F == F, MonErr.E == E {
        return Kleisli<F, D, A>({ d in monadError.handleErrorWith(self.run(d), { e in f(e).run(d) }) })
    }
    
    public static func pure<Appl>(_ a : A, _ applicative : Appl) -> Kleisli<F, D, A> where Appl : Applicative, Appl.F == F {
        return Kleisli<F, D, A>({ _ in applicative.pure(a) })
    }
    
    public static func ask<Appl>(_ applicative : Appl) -> Kleisli<F, D, D> where Appl : Applicative, Appl.F == F {
        return Kleisli<F, D, D>({ d in applicative.pure(d) })
    }
    
    public static func raiseError<E, MonErr>(_ e : E, _ monadError : MonErr) -> Kleisli<F, D, A> where MonErr : MonadError, MonErr.F == F, MonErr.E == E {
        return Kleisli<F, D, A>({ _ in monadError.raiseError(e) })
    }
    
    public static func tailRecM<B, MonF>(_ a : A, _ f : @escaping (A) -> KleisliOf<F, D, Either<A, B>>, _ monad : MonF) -> KleisliOf<F, D, B> where MonF : Monad, MonF.F == F {
        return Kleisli<F, D, B>({ b in monad.tailRecM(a, { a in Kleisli<F, D, Either<A, B>>.fix(f(a)).run(b) })})
    }
    
    public func invoke(_ value : D) -> Kind<F, A> {
        return run(value)
    }
}

public extension Kleisli {
    public static func functor<FuncF>(_ functor : FuncF) -> KleisliFunctor<F, D, FuncF> {
        return KleisliFunctor<F, D, FuncF>(functor)
    }
    
    public static func applicative<ApplF>(_ applicative : ApplF) -> KleisliApplicative<F, D, ApplF> {
        return KleisliApplicative<F, D, ApplF>(applicative)
    }
    
    public static func monad<MonF>(_ monad : MonF) -> KleisliMonad<F, D, MonF> {
        return KleisliMonad<F, D, MonF>(monad)
    }
    
    public static func reader<MonF>(_ monad : MonF) -> KleisliMonadReader<F, D, MonF> {
        return KleisliMonadReader<F, D, MonF>(monad)
    }
    
    public static func applicativeError<E, ApplEF>(_ applicativeError : ApplEF) -> KleisliMonadError<F, D, E, ApplEF> {
        return KleisliMonadError<F, D, E, ApplEF>(applicativeError)
    }
    
    public static func monadError<E, MonEF>(_ monadError : MonEF) -> KleisliMonadError<F, D, E, MonEF> {
        return KleisliMonadError<F, D, E, MonEF>(monadError)
    }
}

public class KleisliFunctor<G, D, FuncG> : Functor where FuncG : Functor, FuncG.F == G {
    public typealias F = KleisliPartial<G, D>
    
    private let functor : FuncG
    
    public init(_ functor : FuncG) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: KleisliOf<G, D, A>, _ f: @escaping (A) -> B) -> KleisliOf<G, D, B> {
        return Kleisli.fix(fa).map(f, functor)
    }
}

public class KleisliApplicative<G, D, ApplG> : KleisliFunctor<G, D, ApplG>, Applicative where ApplG : Applicative, ApplG.F == G {
    
    private let applicative : ApplG
    
    override public init(_ applicative : ApplG) {
        self.applicative = applicative
        super.init(applicative)
    }
    
    public func pure<A>(_ a: A) -> KleisliOf<G, D, A> {
        return Kleisli.pure(a, applicative)
    }
    
    public func ap<A, B>(_ ff: KleisliOf<G, D, (A) -> B>, _ fa: KleisliOf<G, D, A>) -> KleisliOf<G, D, B> {
        return Kleisli.fix(ff).ap(Kleisli.fix(fa), applicative)
    }
}

public class KleisliMonad<G, D, MonG> : KleisliApplicative<G, D, MonG>, Monad where MonG : Monad, MonG.F == G {
    
    fileprivate let monad : MonG
    
    override public init(_ monad : MonG) {
        self.monad = monad
        super.init(monad)
    }
    
    public func flatMap<A, B>(_ fa: KleisliOf<G, D, A>, _ f: @escaping (A) -> KleisliOf<G, D, B>) -> KleisliOf<G, D, B> {
        return Kleisli.fix(fa).flatMap({ a in Kleisli.fix(f(a)) }, monad)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> KleisliOf<G, D, Either<A, B>>) -> KleisliOf<G, D, B> {
        return Kleisli.tailRecM(a, f, monad)
    }
}

public class KleisliMonadReader<G, E, MonG> : KleisliMonad<G, E, MonG>, MonadReader where MonG : Monad, MonG.F == G {
    public typealias D = E
    
    public func ask() -> KleisliOf<G, E, E> {
        return Kleisli<G, E, E>.ask(monad)
    }
    
    public func local<A>(_ f: @escaping (E) -> E, _ fa: KleisliOf<G, E, A>) -> KleisliOf<G, E, A> {
        return Kleisli.fix(fa).local(f)
    }
}

public class KleisliMonadError<G, D, Err, MonErrG> : KleisliMonad<G, D, MonErrG>, MonadError where MonErrG : MonadError, MonErrG.F == G, MonErrG.E == Err {
    public typealias E = Err
    
    private let monadError : MonErrG
    
    override public init(_ monadError : MonErrG) {
        self.monadError = monadError
        super.init(monadError)
    }
    
    public func raiseError<A>(_ e: Err) -> KleisliOf<G, D, A> {
        return Kleisli<G, D, A>.raiseError(e, monadError)
    }
    
    public func handleErrorWith<A>(_ fa: KleisliOf<G, D, A>, _ f: @escaping (Err) -> KleisliOf<G, D, A>) -> KleisliOf<G, D, A> {
        return Kleisli.fix(fa).handleErrorWith({ e in Kleisli.fix(f(e)) }, monadError)
    }
}

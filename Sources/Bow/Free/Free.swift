import Foundation

public class ForFree {}
public typealias FreeOf<S, A> = Kind2<ForFree, S, A>
public typealias FreePartial<S> = Kind<ForFree, S>

public class Free<S, A> : FreeOf<S, A> {
    
    public static func pure(_ a : A) -> Free<S, A> {
        return Pure(a)
    }
    
    public static func liftF(_ fa : Kind<S, A>) -> Free<S, A> {
        return Suspend(fa)
    }
    
    public static func deferFree(_ value : @escaping () -> Free<S, A>) -> Free<S, A> {
        return Free<S, Unit>.pure(unit).flatMap { _ in value() }
    }
    
    internal static func functionKF() -> FunctionKFree<S> {
        return FunctionKFree<S>()
    }
    
    internal static func applicativeF<Appl>(_ applicative : Appl) -> ApplicativeFreePartial<S, Appl> where Appl : Applicative, Appl.F == FreePartial<S> {
        return ApplicativeFreePartial(applicative)
    }
    
    public static func fix(_ fa : FreeOf<S, A>) -> Free<S, A> {
        return fa as! Free<S, A>
    }
    
    public func transform<B, S, O, FuncK>(_ f : @escaping (A) -> B, _ fs : FuncK) -> Free<O, B> where FuncK : FunctionK, FuncK.F == S, FuncK.G == O {
        fatalError("Free.transform must be implemented by subclass")
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Free<S, B> {
        return flatMap { a in Free<S, B>.pure(f(a)) }
    }
    
    public func ap<B>(_ ff : Free<S, (A) -> B>) -> Free<S, B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Free<S, B>) -> Free<S, B> {
        return FlatMapped<S, B, A>(self, f)
    }
    
    public func step() -> Free<S, A> {
        if self is FlatMapped<S, A, A> && (self as! FlatMapped<S, A, A>).c is FlatMapped<S, A, A> {
            let flatMappedSelf = self as! FlatMapped<S, A, A>
            let g = flatMappedSelf.f
            let flatMappedC = flatMappedSelf.c as! FlatMapped<S, A, A>
            let c = flatMappedC.c
            let f = flatMappedC.f
            return c.flatMap { cc in f(cc).flatMap(g) }.step()
        } else if self is FlatMapped<S, A, A> && (self as! FlatMapped<S, A, A>).c is Pure<S, A> {
            let flatMappedSelf = self as! FlatMapped<S, A, A>
            let flatMappedC = flatMappedSelf.c as! Pure<S, A>
            let a = flatMappedC.a
            let f = flatMappedSelf.f
            return f(a).step()
        } else {
            return self
        }
    }
    
    public func foldMap<M, FuncK, Mon>(_ f : FuncK, _ monad : Mon) -> Kind<M, A> where FuncK : FunctionK, FuncK.F == S, FuncK.G == M, Mon : Monad, Mon.F == M {
        return monad.tailRecM(self) { freeSA in
            return freeSA.step().foldMapChild(f, monad)
        }
    }
    
    fileprivate func foldMapChild<M, FuncK, Mon>(_ f : FuncK, _ monad : Mon) -> Kind<M, Either<Free<S, A>,A>> where FuncK : FunctionK, FuncK.F == S, FuncK.G == M, Mon : Monad, Mon.F == M {
        fatalError("foldMapChild must be implemented by subclasses")
    }
    
    public func run<Mon>(_ monad : Mon) -> Kind<S, A> where Mon : Monad, Mon.F == S {
        return self.foldMap(IdFunctionK<S>.id, monad)
    }
}

fileprivate class Pure<S, A> : Free<S, A> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
    
    override fileprivate func foldMapChild<M, FuncK, Mon>(_ f: FuncK, _ monad: Mon) -> Kind<M, Either<Free<S, A>, A>> where S == FuncK.F, M == FuncK.G, FuncK : FunctionK, Mon : Monad, FuncK.G == Mon.F {
        return monad.pure(Either.right(self.a))
    }
    
    override public func transform<B, S, O, FuncK>(_ f: @escaping (A) -> B, _ fs: FuncK) -> Free<O, B> where S == FuncK.F, O == FuncK.G, FuncK : FunctionK {
        return Free<O, B>.pure(f(a))
    }
}

fileprivate class Suspend<S, A> : Free<S, A> {
    fileprivate let a : Kind<S, A>
    
    init(_ a : Kind<S, A>) {
        self.a = a
    }
    
    override fileprivate func foldMapChild<M, FuncK, Mon>(_ f: FuncK, _ monad: Mon) -> Kind<M, Either<Free<S, A>, A>> where S == FuncK.F, M == FuncK.G, FuncK : FunctionK, Mon : Monad, FuncK.G == Mon.F {
        return monad.map(f.invoke(self.a), { a in Either.right(a) })
    }
    
    override public func transform<B, S, O, FuncK>(_ f: @escaping (A) -> B, _ fs: FuncK) -> Free<O, B> where S == FuncK.F, O == FuncK.G, FuncK : FunctionK {
        return Free<O, A>.liftF(fs.invoke(a as! Kind<S, A>)).map(f)
    }
}

fileprivate class FlatMapped<S, A, C> : Free<S, A> {
    fileprivate let c : Free<S, C>
    fileprivate let f : (C) -> Free<S, A>
    
    init(_ c : Free<S, C>, _ f : @escaping (C) -> Free<S, A>) {
        self.c = c
        self.f = f
    }
    
    override fileprivate func foldMapChild<M, FuncK, Mon>(_ f: FuncK, _ monad: Mon) -> Kind<M, Either<Free<S, A>, A>> where S == FuncK.F, M == FuncK.G, FuncK : FunctionK, Mon : Monad, FuncK.G == Mon.F {
        let g = self.f
        let c = self.c
        return monad.map(c.foldMap(f, monad), { cc in Either.left(g(cc)) })
    }
    
    override public func transform<B, S, O, FuncK>(_ fm : @escaping (A) -> B, _ fs: FuncK) -> Free<O, B> where S == FuncK.F, O == FuncK.G, FuncK : FunctionK {
        return FlatMapped<O, B, C>(c.transform(id, fs), { _ in self.c.flatMap(self.f).transform(fm, fs) })
    }
}

internal class FunctionKFree<S> : FunctionK {
    typealias F = S
    typealias G = FreePartial<S>
    
    func invoke<A>(_ fa: Kind<S, A>) -> FreeOf<S, A> {
        return Free.liftF(fa)
    }
}

internal class ApplicativeFreePartial<S, Appl> : Applicative where Appl : Applicative, Appl.F == FreePartial<S> {
    typealias F = FreePartial<S>
    private let applicative : Appl
    
    init(_ applicative : Appl) {
        self.applicative = applicative
    }
    
    func pure<A>(_ a: A) -> FreeOf<S, A> {
        return Free.pure(a)
    }

    func ap<A, B>(_ fa: FreeOf<S, A>, _ ff: FreeOf<S, (A) -> B>) -> FreeOf<S, B> {
        return applicative.ap(fa, ff)
    }
}

public extension Free {
    public static func functor() -> FreeFunctor<S> {
        return FreeFunctor<S>()
    }
    
    public static func applicative() -> FreeApplicativeInstance<S> {
        return FreeApplicativeInstance<S>()
    }
    
    public static func monad() -> FreeMonad<S> {
        return FreeMonad<S>()
    }
    
    public static func eq<G, FuncK, Mon, EqGB>(_ functionK : FuncK, _ monad : Mon, _ eq : EqGB) -> FreeEq<S, G, A, FuncK, Mon, EqGB> {
        return FreeEq<S, G, A, FuncK, Mon, EqGB>(functionK, monad, eq)
    }
}

public class FreeFunctor<S> : Functor {
    public typealias F = FreePartial<S>
    
    public func map<A, B>(_ fa: FreeOf<S, A>, _ f: @escaping (A) -> B) -> FreeOf<S, B> {
        return Free.fix(fa).map(f)
    }
}

public class FreeApplicativeInstance<S> : FreeFunctor<S>, Applicative {
    public func pure<A>(_ a: A) -> FreeOf<S, A> {
        return Free.pure(a)
    }
    
    public func ap<A, B>(_ fa: FreeOf<S, A>, _ ff: FreeOf<S, (A) -> B>) -> FreeOf<S, B> {
        return Free.fix(fa).ap(Free.fix(ff))
    }
}

public class FreeMonad<S> : FreeApplicativeInstance<S>, Monad {
    public func flatMap<A, B>(_ fa: FreeOf<S, A>, _ f: @escaping (A) -> FreeOf<S, B>) -> FreeOf<S, B> {
        return Free.fix(fa).flatMap({ a in Free.fix(f(a)) })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> FreeOf<S, Either<A, B>>) -> FreeOf<S, B> {
        return flatMap(f(a)) { either in
            either.fold({ left in self.tailRecM(left, f) },
                        { right in self.pure(right) })
        }
    }
}

public class FreeEq<F, G, B, FuncKFG, MonG, EqGB> : Eq where FuncKFG : FunctionK, FuncKFG.F == F, FuncKFG.G == G, MonG : Monad, MonG.F == G, EqGB : Eq, EqGB.A == Kind<G, B> {
    public typealias A = FreeOf<F, B>
    
    private let functionK : FuncKFG
    private let monad : MonG
    private let eq : EqGB
    
    public init(_ functionK : FuncKFG, _ monad : MonG, _ eq : EqGB) {
        self.functionK = functionK
        self.monad = monad
        self.eq = eq
    }
    
    public func eqv(_ a: FreeOf<F, B>, _ b: FreeOf<F, B>) -> Bool {
        return eq.eqv(Free.fix(a).foldMap(functionK, monad),
                      Free.fix(b).foldMap(functionK, monad))
    }
}

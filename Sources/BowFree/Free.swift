import Foundation
import Bow

public final class ForFree {}
public final class FreePartial<S>: Kind<ForFree, S> {}
public typealias FreeOf<S, A> = Kind<FreePartial<S>, A>

public class Free<S, A>: FreeOf<S, A> {
    public static func liftF(_ fa: Kind<S, A>) -> Free<S, A> {
        return Suspend(fa)
    }
    
    public static func deferFree(_ value: @escaping () -> Free<S, A>) -> Free<S, A> {
        return Free.fix(Free<S, ()>.pure(unit).flatMap { _ in value() })
    }
    
    internal static func functionKF() -> FunctionKFree<S> {
        return FunctionKFree<S>()
    }

    public static func fix(_ fa : FreeOf<S, A>) -> Free<S, A> {
        return fa as! Free<S, A>
    }
    
    public func transform<B, S, O, FuncK>(_ f : @escaping (A) -> B, _ fs : FuncK) -> Free<O, B> where FuncK : FunctionK, FuncK.F == S, FuncK.G == O {
        fatalError("Free.transform must be implemented by subclass")
    }
    
    public func step() -> Free<S, A> {
        if self is FlatMapped<S, A, A> && (self as! FlatMapped<S, A, A>).c is FlatMapped<S, A, A> {
            let flatMappedSelf = self as! FlatMapped<S, A, A>
            let g = flatMappedSelf.f
            let flatMappedC = flatMappedSelf.c as! FlatMapped<S, A, A>
            let c = flatMappedC.c
            let f = flatMappedC.f
            return Free.fix(c.flatMap { cc in f(cc).flatMap(g) }).step()
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
    
    public func foldMapK<M: Monad, FuncK>(_ f: FuncK) -> Kind<M, A> where FuncK: FunctionK, FuncK.F == S, FuncK.G == M {
        return M.tailRecM(self) { freeSA in
            return freeSA.step().foldMapChild(f)
        }
    }
    
    fileprivate func foldMapChild<M: Monad, FuncK>(_ f: FuncK) -> Kind<M, Either<Free<S, A>,A>> where FuncK: FunctionK, FuncK.F == S, FuncK.G == M {
        fatalError("foldMapChild must be implemented by subclasses")
    }
}

public extension Free where S: Monad {
    public func run() -> Kind<S, A> {
        return self.foldMapK(IdFunctionK<S>.id)
    }
}

fileprivate class Pure<S, A> : Free<S, A> {
    fileprivate let a: A
    
    init(_ a : A) {
        self.a = a
    }
    
    override fileprivate func foldMapChild<M: Monad, FuncK>(_ f: FuncK) -> Kind<M, Either<Free<S, A>, A>> where S == FuncK.F, M == FuncK.G, FuncK: FunctionK {
        return M.pure(Either.right(self.a))
    }
    
    override public func transform<B, S, O, FuncK>(_ f: @escaping (A) -> B, _ fs: FuncK) -> Free<O, B> where S == FuncK.F, O == FuncK.G, FuncK : FunctionK {
        return Free.fix(Free.pure(f(a)))
    }
}

fileprivate class Suspend<S, A> : Free<S, A> {
    fileprivate let a: Kind<S, A>
    
    init(_ a : Kind<S, A>) {
        self.a = a
    }
    
    override fileprivate func foldMapChild<M: Monad, FuncK>(_ f: FuncK) -> Kind<M, Either<Free<S, A>, A>> where S == FuncK.F, M == FuncK.G, FuncK: FunctionK {
        return M.map(f.invoke(self.a), { a in Either.right(a) })
    }
    
    override public func transform<B, S, O, FuncK>(_ f: @escaping (A) -> B, _ fs: FuncK) -> Free<O, B> where S == FuncK.F, O == FuncK.G, FuncK: FunctionK {
        return Free.fix(Free<O, A>.liftF(fs.invoke(a as! Kind<S, A>)).map(f))
    }
}

fileprivate class FlatMapped<S, A, C> : Free<S, A> {
    fileprivate let c: Free<S, C>
    fileprivate let f: (C) -> Free<S, A>
    
    init(_ c : Free<S, C>, _ f : @escaping (C) -> Free<S, A>) {
        self.c = c
        self.f = f
    }
    
    override fileprivate func foldMapChild<M: Monad, FuncK>(_ f: FuncK) -> Kind<M, Either<Free<S, A>, A>> where S == FuncK.F, M == FuncK.G, FuncK : FunctionK {
        let g = self.f
        let c = self.c
        return M.map(c.foldMapK(f), { cc in Either.left(g(cc)) })
    }
    
    override public func transform<B, S, O, FuncK>(_ fm: @escaping (A) -> B, _ fs: FuncK) -> Free<O, B> where S == FuncK.F, O == FuncK.G, FuncK : FunctionK {
        return FlatMapped<O, B, C>(c.transform(id, fs), { _ in Free.fix(self.c.flatMap(self.f)).transform(fm, fs) })
    }
}

internal class FunctionKFree<S> : FunctionK {
    typealias F = S
    typealias G = FreePartial<S>
    
    func invoke<A>(_ fa: Kind<S, A>) -> FreeOf<S, A> {
        return Free.liftF(fa)
    }
}

extension FreePartial: Functor {
    public static func map<A, B>(_ fa: Kind<FreePartial<S>, A>, _ f: @escaping (A) -> B) -> Kind<FreePartial<S>, B> {
        return Free.fix(fa).flatMap { a in Free<S, B>.pure(f(a)) }
    }
}

extension FreePartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<FreePartial<S>, A> {
        return Pure(a)
    }
}

extension FreePartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<FreePartial<S>, A>, _ f: @escaping (A) -> Kind<FreePartial<S>, B>) -> Kind<FreePartial<S>, B> {
        return FlatMapped(Free.fix(fa), { a in Free.fix(f(a)) })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<FreePartial<S>, Either<A, B>>) -> Kind<FreePartial<S>, B> {
        return flatMap(f(a)) { either in
            either.fold({ left in tailRecM(left, f) },
                        { right in pure(right) })
        }
    }
}

//public extension Free {
//    public class EqInstance<F, G, B, FuncKFG, MonG, EqGB> : Eq where FuncKFG : FunctionK, FuncKFG.F == F, FuncKFG.G == G, MonG : Monad, MonG.F == G, EqGB : Eq, EqGB.A == Kind<G, B> {
//        public typealias A = FreeOf<F, B>
//
//        private let functionK : FuncKFG
//        private let monad : MonG
//        private let eq : EqGB
//
//        init(_ functionK : FuncKFG, _ monad : MonG, _ eq : EqGB) {
//            self.functionK = functionK
//            self.monad = monad
//            self.eq = eq
//        }
//
//        public func eqv(_ a: FreeOf<F, B>, _ b: FreeOf<F, B>) -> Bool {
//            return eq.eqv(Free<F, B>.fix(a).foldMap(functionK, monad),
//                          Free<F, B>.fix(b).foldMap(functionK, monad))
//        }
//    }
//}

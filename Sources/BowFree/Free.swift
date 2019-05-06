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

    public static func fix(_ fa: FreeOf<S, A>) -> Free<S, A> {
        return fa as! Free<S, A>
    }

    public func transform<B, S, O>(_ f: @escaping (A) -> B, _ fs: FunctionK<S, O>) -> Free<O, B> {
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

    public func foldMapK<M: Monad>(_ f: FunctionK<S, M>) -> Kind<M, A> {
        return M.tailRecM(self) { freeSA in
            return freeSA.step().foldMapChild(f)
        }
    }

    fileprivate func foldMapChild<M: Monad>(_ f: FunctionK<S, M>) -> Kind<M, Either<Free<S, A>,A>> {
        fatalError("foldMapChild must be implemented by subclasses")
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Free.
public postfix func ^<S, A>(_ fa: FreeOf<S, A>) -> Free<S, A> {
    return Free.fix(fa)
}

public extension Free where S: Monad {
    func run() -> Kind<S, A> {
        return self.foldMapK(FunctionK<S, S>.id)
    }
}

private class Pure<S, A>: Free<S, A> {
    fileprivate let a: A

    init(_ a: A) {
        self.a = a
    }

    override fileprivate func foldMapChild<M: Monad>(_ f: FunctionK<S, M>) -> Kind<M, Either<Free<S, A>, A>> {
        return M.pure(Either.right(self.a))
    }

    override public func transform<B, S, O>(_ f: @escaping (A) -> B, _ fs: FunctionK<S, O>) -> Free<O, B> {
        return Free.fix(Free.pure(f(a)))
    }
}

private class Suspend<S, A>: Free<S, A> {
    fileprivate let a: Kind<S, A>
    
    init(_ a: Kind<S, A>) {
        self.a = a
    }

    override fileprivate func foldMapChild<M: Monad>(_ f: FunctionK<S, M>) -> Kind<M, Either<Free<S, A>, A>> {
        return M.map(f.invoke(self.a), { a in Either.right(a) })
    }

    override public func transform<B, S, O>(_ f: @escaping (A) -> B, _ fs: FunctionK<S, O>) -> Free<O, B> {
        return Free.fix(Free<O, A>.liftF(fs.invoke(a as! Kind<S, A>)).map(f))
    }
}

private class FlatMapped<S, A, C>: Free<S, A> {
    fileprivate let c: Free<S, C>
    fileprivate let f: (C) -> Free<S, A>

    init(_ c: Free<S, C>, _ f: @escaping (C) -> Free<S, A>) {
        self.c = c
        self.f = f
    }

    override fileprivate func foldMapChild<M: Monad>(_ f: FunctionK<S, M>) -> Kind<M, Either<Free<S, A>, A>> {
        let g = self.f
        let c = self.c
        return M.map(c.foldMapK(f), { cc in Either.left(g(cc)) })
    }

    override public func transform<B, S, O>(_ fm: @escaping (A) -> B, _ fs: FunctionK<S, O>) -> Free<O, B> {
        return FlatMapped<O, B, C>(c.transform(id, fs), { _ in Free.fix(self.c.flatMap(self.f)).transform(fm, fs) })
    }
}

internal class FunctionKFree<S>: FunctionK<S, FreePartial<S>> {
    override func invoke<A>(_ fa: Kind<S, A>) -> Kind<FreePartial<S>, A> {
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

// MARK: Instance of `Selective` for `Free`
extension FreePartial: Selective {}

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

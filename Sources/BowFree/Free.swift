import Foundation
import Bow

public final class ForFree {}
public final class FreePartial<F: Functor>: Kind<ForFree, F> {}
public typealias FreeOf<F: Functor, A> = Kind<FreePartial<F>, A>

public final class Free<F: Functor, A>: FreeOf<F, A> {
    public enum _Free<F: Functor, A> {
        case pure(A)
        case free(Kind<F, Free<F, A>>)
    }
    
    public let value: _Free<F, A>
    
    fileprivate init(_ value: _Free<F, A>) {
        self.value = value
    }
    
    public static func free(_ fa: Kind<F, Free<F, A>>) -> Free<F, A> {
        Free(.free(fa))
    }
    
    public static func liftF(_ fa: Kind<F, A>) -> Free<F, A> {
        Free(.free(fa.map { a in Free.pure(a)^ }))
    }

    public static func fix(_ fa: FreeOf<F, A>) -> Free<F, A> {
        fa as! Free<F, A>
    }

    public func foldMapK<M: Monad>(_ f: FunctionK<F, M>) -> Kind<M, A> {
        return M.tailRecM(self) { free in
            switch free.value {
            case .pure(let a):
                return M.pure(.right(a))
                
            case .free(let fa):
                return f.invoke(fa.map(Either.left))
            }
        }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Free.
public postfix func ^<S, A>(_ fa: FreeOf<S, A>) -> Free<S, A> {
    Free.fix(fa)
}

public extension Free where F: Monad {
    func run() -> Kind<F, A> {
        self.foldMapK(FunctionK<F, F>.id)
    }
}

// MARK: Instance of Functor for Free
extension FreePartial: Functor {
    public static func map<A, B>(
        _ fa: FreeOf<F, A>,
        _ f: @escaping (A) -> B
    ) -> FreeOf<F, B> {
        switch fa^.value {
        case .pure(let a):
            return Free.pure(f(a))
        case .free(let fa):
            return Free(.free(fa.map { free in free.map(f)^ }))
        }
    }
}

// MARK: Instance of Applicative for Free
extension FreePartial: Applicative {
    public static func pure<A>(_ a: A) -> FreeOf<F, A> {
        Free(.pure(a))
    }
}

// MARK: Instance of Selective for Free
extension FreePartial: Selective {}

// MARK: Instance of Monad for Free
extension FreePartial: Monad {
    public static func flatMap<A, B>(
        _ fa: FreeOf<F, A>,
        _ f: @escaping (A) -> FreeOf<F, B>
    ) -> FreeOf<F, B> {
        switch fa^.value {
        
        case .pure(let a):
            return f(a)
        
        case .free(let fa):
            return Free(.free(fa.map { free in free.flatMap(f)^ }))
        }
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> FreeOf<F, Either<A, B>>
    ) -> FreeOf<F, B> {
        _tailRecM(f(a), f).run()
    }
    
    private static func _tailRecM<A, B>(
        _ fa: FreeOf<F, Either<A, B>>,
        _ f: @escaping (A) -> FreeOf<F, Either<A, B>>
    ) -> Trampoline<FreeOf<F, B>> {
        switch fa^.value {
        
        case .pure(let either):
            return either.fold(
                { a in .defer { _tailRecM(f(a), f) } },
                { b in .done(.pure(b)) })
            
        case .free(let fa):
            return .done(Free(.free(fa.map { free in
                _tailRecM(free, f).run()^
            })))
        }
    }
}

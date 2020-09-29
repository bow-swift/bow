import Foundation
import Bow

/// Witness for the `Free<F, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForFree {}

/// Partial application of the Free type constructor, omitting the last parameter.
public final class FreePartial<F: Functor>: Kind<ForFree, F> {}

/// Higher Kinded Type alias to improve readability.
public typealias FreeOf<F: Functor, A> = Kind<FreePartial<F>, A>

/// Free is a type that, given any Functor, is able to provide a Monad instance, that can be interpreted into a more restrictive one.
public final class Free<F: Functor, A>: FreeOf<F, A> {
    /// Internal representation of a Free value
    public enum _Free<F: Functor, A> {
        case pure(A)
        case free(Kind<F, Free<F, A>>)
    }
    
    public let value: _Free<F, A>
    
    fileprivate init(_ value: _Free<F, A>) {
        self.value = value
    }
    
    /// Creates a Free value.
    ///
    /// - Parameter fa: Value to be embedded in Free.
    /// - Returns: A Free value.
    public static func free(_ fa: Kind<F, Free<F, A>>) -> Free<F, A> {
        Free(.free(fa))
    }
    
    /// Lifts a value in the context of the Functor into the Free context.
    ///
    /// - Parameter fa: A value in the context of the provided Functor.
    /// - Returns: A Free value.
    public static func liftF(_ fa: Kind<F, A>) -> Free<F, A> {
        Free(.free(fa.map { a in Free.pure(a)^ }))
    }
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Free.
    public static func fix(_ fa: FreeOf<F, A>) -> Free<F, A> {
        fa as! Free<F, A>
    }
    
    /// Interprets this Free value into the provided Monad.
    ///
    /// - Parameter f: A natural transformation from the internal Functor into the desired Monad.
    /// - Returns: A value in the interpreted Monad.
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
    /// Folds this free structure using the same Monad.
    ///
    /// - Returns: Folded value.
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

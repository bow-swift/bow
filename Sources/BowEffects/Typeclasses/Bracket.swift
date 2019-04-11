import Bow

public enum ExitCase<E> {
    case completed
    case canceled
    case error(E)

    public func fold<A>(_ ifCompleted: () -> A, _ ifCanceled: () -> A, _ ifError: (E) -> A) -> A {
        switch self {
        case .completed: return ifCompleted()
        case .canceled: return ifCanceled()
        case let .error(e): return ifError(e)
        }
    }
}

extension ExitCase: CustomStringConvertible {
    public var description: String {
        return fold(constant("ExitCase.Completed"),
                    constant("ExitCase.Canceled"),
                    { e in "ExitCase.Error(\(e))" })
    }
}

public protocol Bracket: MonadError {
    static func bracketCase<A, B>(_ fa: Kind<Self, A>,
                                  _ release: @escaping (A, ExitCase<Self.E>) -> Kind<Self, ()>,
                                  _ use: @escaping (A) -> Kind<Self, B>) -> Kind<Self, B>
}

// MARK: Related functions

public extension Bracket {
    public static func bracket<A, B>(_ fa: Kind<Self, A>,
                                     _ release: @escaping (A) -> Kind<Self, ()>,
                                     _ use: @escaping (A) -> Kind<Self, B>) -> Kind<Self, B> {
        return bracketCase(fa, { a, _ in release(a) }, use)
    }

    public static func uncancelable<A>(_ fa: Kind<Self, A>) -> Kind<Self, A> {
        return bracket(fa, constant(pure(())), { x in pure(x) })
    }

    public static func guarantee<A>(_ fa: Kind<Self, A>,
                                    _ finalizer: Kind<Self, ()>) -> Kind<Self, A> {
        return bracket(fa, constant(finalizer), constant(fa))
    }

    public static func guaranteeCase<A>(_ fa: Kind<Self, A>,
                                        _ finalizer: @escaping (ExitCase<Self.E>) -> Kind<Self, ()>) -> Kind<Self, A> {
        return bracketCase(fa, { _, e in finalizer(e) }, constant(fa))
    }
}

// MARK: Syntax for Bracket

public extension Kind where F: Bracket {
    public func bracketCase<B>(_ release: @escaping (A, ExitCase<F.E>) -> Kind<F, ()>,
                               _ use: @escaping (A) -> Kind<F, B>) -> Kind<F, B> {
        return F.bracketCase(self, release, use)
    }

    public func bracket<B>(_ release: @escaping (A) -> Kind<F, ()>,
                           _ use: @escaping (A) -> Kind<F, B>) -> Kind<F, B> {
        return F.bracket(self, release, use)
    }

    public func uncancelable() -> Kind<F, A> {
        return F.uncancelable(self)
    }

    public func guarantee(_ finalizer: Kind<F, ()>) -> Kind<F, A> {
        return F.guarantee(self, finalizer)
    }

    public func guaranteeCase(_ finalizer: @escaping (ExitCase<F.E>) -> Kind<F, ()>) -> Kind<F, A> {
        return F.guaranteeCase(self, finalizer)
    }
}

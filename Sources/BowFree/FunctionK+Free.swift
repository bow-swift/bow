import Bow

public extension FunctionK where F: Functor, G: Functor {
    /// Obtains a natural transformation for the Free Monads of the Functors from this natural transformation.
    ///
    /// - Returns: A natural transformation for the Free Monads.
    func free() -> FunctionK<FreePartial<F>, FreePartial<G>> {
        FreeFunctionK(self)
    }
}

public extension FunctionK where F == FreePartial<G>, G: Monad {
    /// Obtains a natural transformation from a Free Monad to the underlying Monad.
    ///
    /// - Returns: A natural transformation from a Free Monad to its underlying Monad.
    static func monad() -> FunctionK<FreePartial<G>, G> {
        MonadFunctionK()
    }
}

private class FreeFunctionK<F: Functor, G: Functor>: FunctionK<FreePartial<F>, FreePartial<G>> {
    private let f: FunctionK<F, G>
    
    init(_ f: FunctionK<F, G>) {
        self.f = f
    }
    
    override func invoke<A>(
        _ fa: FreeOf<F, A>
    ) -> FreeOf<G, A> {
        switch fa^.value {
        case let .pure(a):
            return Free<G, A>.pure(a)
        case let .free(fa):
            return Free<G, A>.free(f.invoke(fa.map { free in
                self.invoke(free)^
            }))
        }
    }
}

private class MonadFunctionK<F: Monad>: FunctionK<FreePartial<F>, F> {
    override func invoke<A>(
        _ fa: FreeOf<F, A>
    ) -> Kind<F, A> {
        switch fa^.value {
        case let .pure(a):
            return F.pure(a)
        case let .free(fa):
            return fa.flatMap(self.invoke)
        }
    }
}

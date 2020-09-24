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

public extension FunctionK where F: Functor, G: Monad {
    /// Obtains an interpreter for Free Monads from this Natural Transformation.
    ///
    /// - Returns: A Natural Transformation to interpret the Free Monad given by the Functor `F`, into the Monad `G`.
    func interpreter() -> FunctionK<FreePartial<F>, G> {
        InterpreterFunctionK(self)
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

private class InterpreterFunctionK<F: Functor, G: Monad>: FunctionK<FreePartial<F>, G> {
    private let f: FunctionK<F, G>
    
    init(_ f: FunctionK<F, G>) {
        self.f = f
    }
    
    override func invoke<A>(
        _ fa: FreeOf<F, A>
    ) -> Kind<G, A> {
        FunctionK<FreePartial<G>, G>.monad()
            .invoke(f.free().invoke(fa))
    }
}

import Bow

public extension FunctionK where F: Functor, G: Functor {
    /// Obtains a natural transformation for the Free Monads of the Functors from this natural transformation.
    ///
    /// - Returns: A natural transformation for the Free Monads.
    func free() -> FunctionK<FreePartial<F>, FreePartial<G>> {
        FreeFunctionK(self)
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

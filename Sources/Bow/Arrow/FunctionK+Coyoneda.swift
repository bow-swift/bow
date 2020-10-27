extension FunctionK {

    /// Obtain a natural transformation from `Coyoneda<F>` to `Coyoneda<G>`
    public var coyoneda: FunctionK<CoyonedaPartial<F>, CoyonedaPartial<G>> {
        CoyonedaNaturalTransformation(self)
    }
}

extension FunctionK where G: Functor {

    /// Obtains a natural transformation that reduces a coyoneda value of a type constructor F
    /// even if F is not a functor, provided that you have a way to transform `F` into a functor `G`.
    ///
    /// The natural transformation from `Coyoneda<F>` to a functor `G`
    /// works by transforming `Coyoneda<F>` to `Coyoneda<G>` and then reducing the
    /// new coyoneda value.
    public var transformAndReduce: FunctionK<CoyonedaPartial<F>, G> {
        CoyonedaFToGNaturalTransformation(f: self)
    }
}

/// Represents a function with the signature `Coyoneda<F, T> -> G<T>`
/// that is polymorphic on `T`, where `F` and `G` are fixed.
fileprivate class CoyonedaFToGNaturalTransformation<F, G>: FunctionK<CoyonedaPartial<F>, G> where G: Functor {
    internal init(f: FunctionK<F, G>) {
        self.f = f
    }

    private let f: FunctionK<F, G>
    override func invoke<A>(_ fa: Kind<CoyonedaPartial<F>, A>) -> Kind<G, A> {
        f.coyoneda(fa)^.lower()
    }
}

/// Represents a function with the signature `Coyoneda<F, T> -> Coyoneda<G, T>`
/// that is polymorphic on `T`, where `F` and `G` are fixed.
fileprivate class CoyonedaNaturalTransformation<F, G>: FunctionK<CoyonedaPartial<F>, CoyonedaPartial<G>> {
    init(_ f: FunctionK<F, G>) {
        self.f = f
    }

    let f: FunctionK<F, G>

    override func invoke<A>(_ fa: CoyonedaOf<F, A>) -> CoyonedaOf<G, A> {
        fa^.coyonedaF.run(TransformCoyoneda(f))
    }
}

/// Represents a function with the signature `CoyonedaF<F, A, T> -> Coyoneda<G, A>`
/// that is polymorphic on `T`, where `F`, `G` and `A` are fixed.
///
/// It basically maps the inner value of a `Coyoneda<F, A>` to a `Coyoneda<G, A>`
fileprivate class TransformCoyoneda<F, G, A>: CokleisliK<CoyonedaFPartial<F, A>, Coyoneda<G, A>> {
    init(_ f: FunctionK<F, G>) {
        self.f = f
    }

    let f: FunctionK<F, G>

    override func invoke<T>(_ fa: CoyonedaFOf<F, A, T>) -> Coyoneda<G, A> {
        return Coyoneda<G, A>(coyonedaF: Exists(fa^.transform(f)))
    }
}

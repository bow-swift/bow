import Bow

// MARK: Extensions for Traverse where inner effect is Concurrent

public extension Traverse {
    /// Maps each element of a structure to an effect, evaluates in parallel and collects the results.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func parTraverse<G: Concurrent, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<Self, B>> {
        let ff = f >>> ParApplicative.init
        return fa.traverse(ff)^.fa
    }
    
    /// Evaluate each effect in a structure of values in parallel and collects the results.
    ///
    /// - Parameter fga: A structure of values.
    /// - Returns: Results collected under the context of the effects.
    static func parSequence<G: Concurrent, A>(_ fa: Kind<Self, Kind<G, A>>) -> Kind<G, Kind<Self, A>> {
        parTraverse(fa, id)
    }
}

// MARK: Extensions for Traverse and Monad where inner effect is Concurrent

public extension Traverse where Self: Monad {
    /// A parallel traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    static func parFlatTraverse<G: Concurrent, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, Kind<Self, B>>) -> Kind<G, Kind<Self, B>> {
        G.map(parTraverse(fa, f), Self.flatten)
    }
}

// MARK: Syntax for Kind where F is Traverse and inner effect is Concurrent

public extension Kind where F: Traverse {
    /// Maps each element of this structure to an effect, evaluates them in parallel and collects the results.
    ///
    /// - Parameters:
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func parTraverse<G: Concurrent, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<F, B>> {
        F.parTraverse(self, f)
    }
    
    /// Evaluate each effect in this structure of values in parallel and collects the results.
    ///
    /// - Returns: Results collected under the context of the effects.
    func parSequence<G: Concurrent, AA>() -> Kind<G, Kind<F, AA>> where A == Kind<G, AA> {
        F.parSequence(self)
    }
}

// MARK: Syntax for Kind where F is Traverse and Monad and inner effect is Concurrent

public extension Kind where F: Traverse & Monad {
    /// A parallel traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    func parFlatTraverse<G: Concurrent, B>(_ f: @escaping (A) -> Kind<G, Kind<F, B>>) -> Kind<G, Kind<F, B>> {
        return F.parFlatTraverse(self, f)
    }
}

fileprivate final class ForParApplicative {}
fileprivate final class ParApplicativePartial<F: Concurrent>: Kind<ForParApplicative, F> {}
fileprivate typealias ParApplicativeOf<F: Concurrent, A> = Kind<ParApplicativePartial<F>, A>

fileprivate final class ParApplicative<F: Concurrent, A>: ParApplicativeOf<F, A> {
    let fa: Kind<F, A>
    
    init(_ fa: Kind<F, A>) {
        self.fa = fa
    }
}

fileprivate postfix func ^<F, A>(_ value: ParApplicativeOf<F, A>) -> ParApplicative<F, A> {
    value as! ParApplicative<F, A>
}

extension ParApplicativePartial: Functor {
    static func map<A, B>(_ fa: Kind<ParApplicativePartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<ParApplicativePartial<F>, B> {
        ParApplicative(fa^.fa.map(f))
    }
}

extension ParApplicativePartial: Applicative {
    static func pure<A>(_ a: A) -> Kind<ParApplicativePartial<F>, A> {
        ParApplicative(F.pure(a))
    }
    
    static func ap<A, B>(_ ff: Kind<ParApplicativePartial<F>, (A) -> B>, _ fa: Kind<ParApplicativePartial<F>, A>) -> Kind<ParApplicativePartial<F>, B> {
        ParApplicative(F.parMap(ff^.fa, fa^.fa) { f, a in f(a) })
    }
}

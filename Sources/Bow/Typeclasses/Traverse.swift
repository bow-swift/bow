import Foundation

/// Traverse provides a type with the ability to traverse a structure with an effect.
public protocol Traverse: Functor, Foldable {
    /// Maps each element of a structure to an effect, evaluates them from left to right and collects the results.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func traverse<G: Applicative, A, B>(
        _ fa: Kind<Self, A>,
        _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<Self, B>>
}

public extension Traverse {
    /// Evaluate each effect in a structure of values and collects the results.
    ///
    /// - Parameter fga: A structure of values.
    /// - Returns: Results collected under the context of the effects.
    static func sequence<G: Applicative, A, B>(_ fga: Kind<Self, B>) -> Kind<G, Kind<Self, A>>
        where B: Kind<G, A> {
        traverse(fga, id)
    }
}

public extension Traverse where Self: Monad {
    /// A traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    static func flatTraverse<G: Applicative, A, B>(
        _ fa: Kind<Self, A>,
        _ f: @escaping (A) -> Kind<G, Kind<Self, B>>) -> Kind<G, Kind<Self, B>> {
        G.map(traverse(fa, f), Self.flatten)
    }
}

// MARK: Syntax for Traverse

public extension Kind where F: Traverse {
    /// Maps each element of this structure to an effect, evaluates them from left to right and collects the results.
    ///
    /// - Parameters:
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func traverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<F, B>> {
        F.traverse(self, f)
    }

    /// Evaluate each effect in this structure of values and collects the results.
    ///
    /// - Returns: Results collected under the context of the effects.
    func sequence<G: Applicative, AA>() -> Kind<G, Kind<F, AA>>
        where A: Kind<G, AA>{
        F.sequence(self)
    }
}

public extension Kind where F: Traverse & Monad {
    /// A traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    func flatTraverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, Kind<F, B>>) -> Kind<G, Kind<F, B>> {
        F.flatTraverse(self, f)
    }
}

// MARK: Scan

public extension Traverse {
    /// Maps each element of a structure using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function.
    /// - Returns: A new structure with the results of the function.
    static func scanLeft<A, B, S>(
        _ fa: Kind<Self, A>,
        _ initialState: S,
        _ f: @escaping (A) -> State<S, B>) -> Kind<Self, B> {

        Self.traverse(fa, f)^.runA(initialState)
    }

    /// Maps each element of a structure using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function that returns the new state, which will be included in the returned structure.
    /// - Returns: A new structure with the results of the function.
    static func scanLeft<A, B>(
        _ fa: Kind<Self, A>,
        _ initialState: B,
        _ f: @escaping (B, A) -> B) -> Kind<Self, B> {

        let stateStep: (A) -> State<B, B> = { a in
            let previousValue = State<B, B>.var()
            let nextValue = State<B, B>.var()

            return binding(
                previousValue <- .get(),
                nextValue     <- .pure(f(previousValue.get, a)),
                              |<-.set(nextValue.get),
                yield: nextValue.get)^
        }

        return scanLeft(fa, initialState, stateStep)
    }

    /// Maps each element of a structure to an effect using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func scanLeftM<M: Monad, A, B, S>(
        _ fa: Kind<Self, A>,
        _ initialState: Kind<M, S>,
        _ f: @escaping (A) -> StateT<M, S, B>) -> Kind<M, Kind<Self, B>> {

        initialState.flatMap(traverse(fa, f)^.runA)
    }

    /// Maps each element of a structure to an effect using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect, which will be included in the returned structure.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func scanLeftM<M: Monad, A, B>(
        _ fa: Kind<Self, A>,
        _ initialState: Kind<M, B>,
        _ f: @escaping (B, A) -> Kind<M, B>) -> Kind<M, Kind<Self, B>> {

        let stateStep: (A) -> StateT<M, B, B> = { a in
            let previousValue = StateT<M, B, B>.var()
            let nextValue = StateT<M, B, B>.var()

            return binding(
                previousValue <- .get(),
                nextValue     <- StateT.liftF(f(previousValue.get, a)),
                             |<-.set(nextValue.get),
                yield: nextValue.get)^
        }
        return scanLeftM(fa, initialState, stateStep)
    }
}

public extension Kind where F: Traverse {

    /// Maps each element of this structure using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function.
    /// - Returns: A new structure with the results of the function.
    func scanLeft<B, S>(
        initialState: S,
        f: @escaping (A) -> State<S, B>) -> Kind<F, B> {

        F.scanLeft(self, initialState, f)
    }

    /// Maps each element of this structure using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function that returns the new state, which will be included in the returned structure.
    /// - Returns: A new structure with the results of the function.
    func scanLeft<B>(
        initialState: B,
        f: @escaping (B, A) -> B) -> Kind<F, B> {

        F.scanLeft(self, initialState, f)
    }

    /// Maps each element of this structure to an effect using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func scanLeftM<M: Monad, B, S>(
        initialState: Kind<M, S>,
        f: @escaping (A) -> StateT<M, S, B>) -> Kind<M, Kind<F, B>> {

        F.scanLeftM(self, initialState, f)
    }

    /// Maps each element of this structure to an effect using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect, which will be included in the returned structure.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func scanLeftM<M: Monad, B>(
        initialState: Kind<M, B>,
        f: @escaping (B, A) -> Kind<M, B>) -> Kind<M, Kind<F, B>> {

        F.scanLeftM(self, initialState, f)
    }
}


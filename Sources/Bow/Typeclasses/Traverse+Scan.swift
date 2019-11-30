import Foundation

public extension Traverse {
    /// Maps each element of a structure using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function.
    /// - Returns: A new structure with the results of the function.
    static func scanLeft<A, B, S>(
        _ fa: Kind<Self, A>,
        initialState: S,
        f: @escaping (A) -> State<S, B>) -> Kind<Self, B> {

        return Self.traverse(fa, f)^.runA(initialState)
    }

    /// Maps each element of a structure using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function that returns the new state, which will be included in the returned structure.
    /// - Returns: A new structure with the results of the function.
    static func scanLeft<A, B>(
        _ fa: Kind<Self, A>,
        initialState: B,
        f: @escaping (B, A) -> B) -> Kind<Self, B> {

        let stateStep: (A) -> State<B, B> = { a in
            let previousValue = State<B, B>.var()
            let nextValue = State<B, B>.var()

            return binding(
                previousValue <- StateTPartial<ForId, B>.get(),
                nextValue     <- StateTPartial<ForId, B>.pure(f(previousValue.get, a)),
                              |<-StateTPartial<ForId, B>.set(nextValue.get),
                yield: nextValue.get)^
        }

        return scanLeft(fa, initialState: initialState, f: stateStep)
    }

    /// Maps each element of a structure to an effect using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func scanLeftM<M: Monad, A, B, S>(
        _ fa: Kind<Self, A>,
        initialState: Kind<M, S>,
        f: @escaping (A) -> StateT<M, S, B>) -> Kind<M, Kind<Self, B>> {

        return initialState.flatMap(traverse(fa, f)^.runA)
    }

    /// Maps each element of a structure to an effect using a stateful function.
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect, which will be included in the returned structure.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func scanLeftM<M: Monad, A, B>(
        _ fa: Kind<Self, A>,
        initialState: Kind<M, B>,
        f: @escaping (B, A) -> Kind<M, B>) -> Kind<M, Kind<Self, B>> {

        let stateStep: (A) -> StateT<M, B, B> = { a in
            let previousValue = StateT<M, B, B>.var()
            let nextValue = StateT<M, B, B>.var()

            return binding(
                previousValue <- StateT<M, B, B>.get(),
                nextValue     <- StateT<M, B, B>.liftF(f(previousValue.get, a)),
                             |<-StateTPartial<M, B>.set(nextValue.get),
                yield: nextValue.get)^
        }
        return scanLeftM(fa, initialState: initialState, f: stateStep)
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

        F.scanLeft(self, initialState: initialState, f: f)
    }

    /// Maps each element of this structure using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function that returns the new state, which will be included in the returned structure.
    /// - Returns: A new structure with the results of the function.
    func scanLeft<B>(
        initialState: B,
        f: @escaping (B, A) -> B) -> Kind<F, B> {

        F.scanLeft(self, initialState: initialState, f: f)
    }

    /// Maps each element of this structure to an effect using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func scanLeftM<M: Monad, B, S>(
        initialState: Kind<M, S>,
        f: @escaping (A) -> StateT<M, S, B>) -> Kind<M, Kind<F, B>> {

        F.scanLeftM(self, initialState: initialState, f: f)
    }

    /// Maps each element of this structure to an effect using a stateful function.
    /// - Parameters:
    ///   - initialState: The state that will be passed to f initially.
    ///   - f: A stateful function producing an effect, which will be included in the returned structure.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func scanLeftM<M: Monad, B>(
        initialState: Kind<M, B>,
        f: @escaping (B, A) -> Kind<M, B>) -> Kind<M, Kind<F, B>> {

        F.scanLeftM(self, initialState: initialState, f: f)
    }
}

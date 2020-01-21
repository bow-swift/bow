import Foundation

/// Witness for the `StateT<F, S, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForStateT {}

/// Partial application of the StateT type constructor, omitting the last type argument.
public final class StateTPartial<F, S>: Kind2<ForStateT, F, S> {}

/// Higher Kinded Type alias to improve readability over `Kind<StateTPartial<F, S>, A>`
public typealias StateTOf<F, S, A> = Kind<StateTPartial<F, S>, A>

/// StateT transformer represents operations that need to write and read a state through a computation or effect.
///
/// Some computations may not require the full power of this transformer:
///     - For read-only state, see `ReaderT` / `Kleisli`.
///     - To accumulate a value without using it on the way, see `WriterT`.
public final class StateT<F, S, A>: StateTOf<F, S, A> {
    fileprivate let runF: (S) -> Kind<F, (S, A)>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to StateT.
    public static func fix(_ fa: StateTOf<F, S, A>) -> StateT<F, S, A> {
        fa as! StateT<F, S, A>
    }

    /// Initializes a `StateT`.
    ///
    /// - Parameter runF: An effect describing a function that receives a state and produces an effect that updates the state and productes a value.
    public init(_ runF: @escaping (S) -> Kind<F, (S, A)>) {
        self.runF = runF
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to StateT.
public postfix func ^<F, S, A>(_ fa : StateTOf<F, S, A>) -> StateT<F, S, A> {
    StateT.fix(fa)
}

/// Partial application of the `StateT` type constructor, omitting the last parameter.
public typealias StatePartial<S> = StateTPartial<ForId, S>

/// Higher Kinded Type alias to improve readability over `StateT<ForId, S, A>`.
public typealias StateOf<S, A> = StateT<ForId, S, A>

/// State is a convenience data type over the `StateT` transformer, when the effect is `Id`.
public typealias State<S, A> = StateOf<S, A>

// MARK: Convenience functions when the effect is `Id`
public extension StateT where F == ForId {
    /// Initializes a `State` value.
    ///
    /// - Parameter run: A function that depends on a state and produces a new state and a value.
    convenience init(_ run: @escaping (S) -> (S, A)) {
        self.init { s in Id(run(s)) }
    }
    
    /// Runs this computation provided an initial state.
    ///
    /// - Parameter initialState: Initial state for this computation.
    /// - Returns: A pair with the updated state and the produced value.
    func run(_ initialState: S) -> (S, A) {
        Id.fix(self.runM(initialState)).value
    }

    /// Runs this computation provided an initial state.
    ///
    /// - Parameter s: Initial state for this computation.
    /// - Returns: Produced value from this computation.
    func runA(_ s: S) -> A {
        run(s).1
    }

    /// Runs this computation provided an initial state.
    ///
    /// - Parameter s: Initial state for this computation.
    /// - Returns: Updated state after running the computation.
    func runS(_ s: S) -> S {
        run(s).0
    }
}

// MARK: Functions for `StateT` when the effect has an instance of `Functor`
extension StateT where F: Functor {
    /// Transforms the return value and final state of a computation using a provided function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `StateT` where the final state and produced value have been transformed using the provided function.
    public func transform<B>(_ f: @escaping (S, A) -> (S, B)) -> StateT<F, S, B> {
        return StateT<F, S, B>(
            runF >>> F.lift(f)
        )
    }
}

// MARK: Functions for `StateT` when the effect has an instance of `Functor`

extension StateT where F: Functor {
    /// Lifts an effect by wrapping the contained value into a function that depends on some state.
    ///
    /// - Parameter fa: Value to be lifted.
    /// - Returns: A `StateT` that produces the contained value in the original effect, preserving the state.
    public static func liftF(_ fa: Kind<F, A>) -> StateT<F, S, A> {
        StateT { s in fa.map { a in (s, a) } }
    }

    /// Runs this computation using the provided initial state.
    ///
    /// - Parameter s: Initial state to run this computation.
    /// - Returns: Result of running this computation with the provided state, wrapped in the effect.
    public func runA(_ s: S) -> Kind<F, A> {
        runM(s).map{ (_, a) in a }
    }

    /// Runs this computation using the provided initial state.
    ///
    /// - Parameter s: Initial state to run this computation.
    /// - Returns: New state after running this computation with the provided state, wrapped in the effect.
    public func runS(_ s: S) -> Kind<F, S> {
        runM(s).map { (s, _) in s }
    }

    /// Runs this computation using the provided initial state.
    ///
    /// - Parameter initial: Initial state to run this computation.
    /// - Returns: A pair with the new state and produced value, wrapped in the effect.
    public func runM(_ initial: S) -> Kind<F, (S, A)> {
        runF(initial)
    }
    
    /// Modifies the state with a function and returns unit.
    ///
    /// - Parameter f: Function to modify the state.
    /// - Returns: A StateT value with a modified state and unit as result value.
    public func modifyF(_ f: @escaping (S) -> Kind<F, S>) -> StateT<F, S, ()> {
        StateT<F, S, ()> { s in f(s).map { ss in (ss, ()) } }
    }
    
    /// Sets the state to a specific value and returns unit.
    ///
    /// - Parameter fs: Value to set the state.
    /// - Returns: A StateT value with a modified state and unit as result value.
    public func setF(_ fs: Kind<F, S>) -> StateT<F, S, ()> {
        self.modifyF { _ in fs }
    }
}

// MARK: Functions for `StateT` when the effect has an instance of `Functor`

extension StateT where F: Monad {
    /// Flatmaps a function that produces an effect and lifts if back to `StateT`.
    ///
    /// - Parameter f: A function producing an effect.
    /// - Returns: Result of flatmapping and lifting the function to this value.
    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> StateT<F, S, B> {
        StateT<F, S, B>(
            runF >>> { fsa in
                fsa.flatMap { (s, a) in
                    f(a).map { b in (s, b) }
                }
            }
        )
    }
}

// MARK: Instance of `Invariant` for `StateT`
extension StateTPartial: Invariant where F: Functor {}

// MARK: Instance of `Functor` for `StateT`
extension StateTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<StateTPartial<F, S>, A>, _ f: @escaping (A) -> B) -> Kind<StateTPartial<F, S>, B> {
        fa^.transform({ (s, a) in (s, f(a)) })
    }
}

// MARK: Instance of `Applicative` for `StateT`
extension StateTPartial: Applicative where F: Monad {
    public static func pure<A>(_ a: A) -> Kind<StateTPartial<F, S>, A> {
        StateT { s in F.pure((s, a)) }
    }
}

// MARK: Instance of `Selective` for `StateT`
extension StateTPartial: Selective where F: Monad {}

// MARK: Instance of `Monad` for `StateT`
extension StateTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<StateTPartial<F, S>, A>, _ f: @escaping (A) -> Kind<StateTPartial<F, S>, B>) -> Kind<StateTPartial<F, S>, B> {
        StateT<F, S, B>(
            fa^.runF >>> { fsa in
                fsa.flatMap { (s, a) in
                    f(a)^.runM(s)
                }
            })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<StateTPartial<F, S>, Either<A, B>>) -> Kind<StateTPartial<F, S>, B> {
        StateT<F, S, B> { s in
            F.tailRecM((s, a), { pair in
                F.map(StateT.fix(f(pair.1)).runM(pair.0), { sss, ab in
                    ab.bimap({ left in (sss, left) }, { right in (sss, right) })
                })
            })
        }
    }
}

// MARK: Instance of `MonadState` for `StateT`
extension StateTPartial: MonadState where F: Monad {
    public static func get() -> Kind<StateTPartial<F, S>, S> {
        StateT { s in F.pure((s, s)) }
    }

    public static func set(_ s: S) -> Kind<StateTPartial<F, S>, ()> {
        StateT { _ in F.pure((s, ())) }
    }
}

// MARK: Instance of `SemigroupK` for `StateT`
extension StateTPartial: SemigroupK where F: Monad & SemigroupK {
    public static func combineK<A>(_ x: Kind<StateTPartial<F, S>, A>, _ y: Kind<StateTPartial<F, S>, A>) -> Kind<StateTPartial<F, S>, A> {
        StateT { s in x^.runM(s).combineK(y^.runM(s)) }
    }
}

// MARK: Instance of `MonoidK` for `StateT`
extension StateTPartial: MonoidK where F: MonadCombine {
    public static func emptyK<A>() -> Kind<StateTPartial<F, S>, A> {
        StateT.liftF(F.empty())
    }
}

// MARK: Instance of `Alternative` for `StateT`
extension StateTPartial: Alternative where F: MonadCombine {}

// MARK: Instance of `FunctiorFilter` for `StateT`
extension StateTPartial: FunctorFilter where F: MonadCombine {}

// MARK: Instance of `MonadFilter` for `StateT`
extension StateTPartial: MonadFilter where F: MonadCombine {}

// MARK: Instance of `MonadCombine` for `StateT`
extension StateTPartial: MonadCombine where F: MonadCombine {
    public static func empty<A>() -> Kind<StateTPartial<F, S>, A> {
        StateT.liftF(F.empty())
    }
}

// MARK: Instance of `ApplicativeError` for `StateT`
extension StateTPartial: ApplicativeError where F: MonadError {
    public typealias E = F.E

    public static func raiseError<A>(_ e: F.E) -> Kind<StateTPartial<F, S>, A> {
        StateT.liftF(F.raiseError(e))
    }

    public static func handleErrorWith<A>(_ fa: Kind<StateTPartial<F, S>, A>, _ f: @escaping (F.E) -> Kind<StateTPartial<F, S>, A>) -> Kind<StateTPartial<F, S>, A> {
        StateT { s in
            StateT.fix(fa).runM(s).handleErrorWith { e in
                StateT.fix(f(e)).runM(s)
            }
        }
    }
}

// MARK: Instance of `MonadError` for `StateT`
extension StateTPartial: MonadError where F: MonadError {}

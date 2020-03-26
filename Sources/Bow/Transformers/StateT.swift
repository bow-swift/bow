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

/// Witness for the `State<S, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForState = ForStateT

/// Partial application of the `StateT` type constructor, omitting the last parameter.
public typealias StatePartial<S> = StateTPartial<ForId, S>

/// Higher Kinded Type alias to improve readability over `StateT<ForId, S, A>`.
public typealias StateOf<S, A> = StateTOf<ForId, S, A>

/// State is a convenience data type over the `StateT` transformer, when the effect is `Id`.
public typealias State<S, A> = StateT<ForId, S, A>

// MARK: Convenience functions when the effect is Id
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
        self.runM(initialState)^.value
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

// MARK: Functions for StateT when the effect has an instance of Functor
extension StateT where F: Functor {
    /// Transforms the return value and final state of a computation using a provided function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `StateT` where the final state and produced value have been transformed using the provided function.
    public func transform<B>(_ f: @escaping (S, A) -> (S, B)) -> StateT<F, S, B> {
        StateT<F, S, B>(runF >>> F.lift(f))
    }
    
    /// Transforms the wrapped value using a provided function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `StateT` where the final state and produced value have been transformed using the provided function.
    public func transformT<G, B>(_ f: @escaping (Kind<F, (S, A)>) -> Kind<G, (S, B)>) -> StateT<G, S, B> {
        StateT<G, S, B>(self.runF >>> f)
    }
    
    /// Generalizes this StateT to a parent state, given functions to get and set the inner state into the general state.
    ///
    /// - Parameters:
    ///   - getter: Function to get the state from the parent.
    ///   - setter: Function to set the state into the parent.
    /// - Returns: An `StateT` that produces the same computation but updates the state in a parent state.
    public func focus<SS>(_ getter: @escaping (SS) -> S, _ setter: @escaping (SS, S) -> SS) -> StateT<F, SS, A> {
        StateT<F, SS, A> { state in
            self.runF(getter(state)).map { pair in (setter(state, pair.0), pair.1) }
        }
    }
}

// MARK: Functions for StateT when the effect has an instance of Functor

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

// MARK: Functions for StateT when the effect has an instance of Functor

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

// MARK: Instance of Invariant for StateT
extension StateTPartial: Invariant where F: Functor {}

// MARK: Instance of Functor for StateT
extension StateTPartial: Functor where F: Functor {
    public static func map<A, B>(
        _ fa: StateTOf<F, S, A>,
        _ f: @escaping (A) -> B) -> StateTOf<F, S, B> {
        fa^.transform({ (s, a) in (s, f(a)) })
    }
}

// MARK: Instance of Applicative for StateT
extension StateTPartial: Applicative where F: Monad {
    public static func pure<A>(_ a: A) -> StateTOf<F, S, A> {
        StateT { s in F.pure((s, a)) }
    }
}

// MARK: Instance of Selective for StateT
extension StateTPartial: Selective where F: Monad {}

// MARK: Instance of Monad for StateT
extension StateTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: StateTOf<F, S, A>,
        _ f: @escaping (A) -> StateTOf<F, S, B>) -> StateTOf<F, S, B> {
        StateT<F, S, B>(
            fa^.runF >>> { fsa in
                fsa.flatMap { (s, a) in
                    f(a)^.runM(s)
                }
            })
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> StateTOf<F, S, Either<A, B>>) -> StateTOf<F, S, B> {
        StateT<F, S, B> { s in
            F.tailRecM((s, a), { pair in
                F.map(f(pair.1)^.runM(pair.0), { sss, ab in
                    ab.bimap({ left in (sss, left) }, { right in (sss, right) })
                })
            })
        }
    }
}

// MARK: Instance of MonadState for StateT
extension StateTPartial: MonadState where F: Monad {
    public static func get() -> StateTOf<F, S, S> {
        StateT { s in F.pure((s, s)) }
    }

    public static func set(_ s: S) -> StateTOf<F, S, ()> {
        StateT { _ in F.pure((s, ())) }
    }
}

// MARK: Instance of SemigroupK for StateT
extension StateTPartial: SemigroupK where F: Monad & SemigroupK {
    public static func combineK<A>(
        _ x: StateTOf<F, S, A>,
        _ y: StateTOf<F, S, A>) -> StateTOf<F, S, A> {
        StateT { s in x^.runM(s).combineK(y^.runM(s)) }
    }
}

// MARK: Instance of MonoidK for StateT
extension StateTPartial: MonoidK where F: MonadCombine {
    public static func emptyK<A>() -> StateTOf<F, S, A> {
        StateT.liftF(F.empty())
    }
}

// MARK: Instance of Alternative for StateT
extension StateTPartial: Alternative where F: MonadCombine {}

// MARK: Instance of FunctiorFilter for StateT
extension StateTPartial: FunctorFilter where F: MonadCombine {}

// MARK: Instance of MonadFilter for StateT
extension StateTPartial: MonadFilter where F: MonadCombine {}

// MARK: Instance of MonadCombine for StateT
extension StateTPartial: MonadCombine where F: MonadCombine {
    public static func empty<A>() -> StateTOf<F, S, A> {
        StateT.liftF(F.empty())
    }
}

// MARK: Instance of ApplicativeError for StateT
extension StateTPartial: ApplicativeError where F: MonadError {
    public typealias E = F.E

    public static func raiseError<A>(_ e: F.E) -> StateTOf<F, S, A> {
        StateT.liftF(F.raiseError(e))
    }

    public static func handleErrorWith<A>(
        _ fa: StateTOf<F, S, A>,
        _ f: @escaping (F.E) -> StateTOf<F, S, A>) -> StateTOf<F, S, A> {
        StateT { s in
            fa^.runM(s).handleErrorWith { e in
                f(e)^.runM(s)
            }
        }
    }
}

// MARK: Instance of MonadError for StateT
extension StateTPartial: MonadError where F: MonadError {}

// MARK: Instance of MonadReader for StateT
extension StateTPartial: MonadReader where F: MonadReader {
    public typealias D = F.D
    
    public static func ask() -> StateTOf<F, S, F.D> {
        StateT.liftF(F.ask())
    }
    
    public static func local<A>(
        _ fa: StateTOf<F, S, A>,
        _ f: @escaping (F.D) -> F.D) -> StateTOf<F, S, A> {
        fa^.transformT { a in F.local(a, f) }
    }
}

// MARK: Instance of MonadWriter for StateT
extension StateTPartial: MonadWriter where F: MonadWriter {
    public typealias W = F.W
    
    public static func writer<A>(_ aw: (F.W, A)) -> StateTOf<F, S, A> {
        StateT.liftF(F.writer(aw))
    }
    
    public static func listen<A>(_ fa: StateTOf<F, S, A>) -> StateTOf<F, S, (F.W, A)> {
        StateT { s in
            fa^.runM(s).listen().map { result in
                let (w, (s, a)) = result
                return (s, (w, a))
            }
        }
    }
    
    public static func pass<A>(_ fa: StateTOf<F, S, ((F.W) -> F.W, A)>) -> StateTOf<F, S, A> {
        StateT { s in
            F.pass(fa^.runM(s).map { result in
                let (f, (s, a)) = result
                return (s, (f, a))
            })
        }
    }
}

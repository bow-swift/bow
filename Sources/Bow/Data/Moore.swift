import Foundation

/// Witness for the `Moore<E, V>` data type. To be used in simulated Higher Kinded Types.
public final class ForMoore {}

/// Partial application of the Moore type constructor, omitting the last parameter.
public final class MoorePartial<E>: Kind<ForMoore, E> {}

/// Higher Kinded Type alias to improve readability of `Kind<MoorePartial<E>, V>`.
public typealias MooreOf<E, V> = Kind<MoorePartial<E>, V>

/// Moore represents Moore machines that hold values of type `V` and handle inputs of type `E`.
public final class Moore<E, V>: MooreOf<E, V> {
    /// Value hold in this Moore machine.
    public let view: V
    
    /// Function to handle inputs to the Moore machine.
    public let handle: (E) -> Moore<E, V>
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to Moore.
    public static func fix(_ value: MooreOf<E, V>) -> Moore<E, V> {
        value as! Moore<E, V>
    }
    
    /// Creates a Moore machine from a hidden initial state and a function that provides the next value and handling function.
    ///
    /// - Parameters:
    ///   - state: Initial state.
    ///   - next: Function to determine the next value and handling function.
    /// - Returns: A Moore machine described from the input values.
    public static func unfold<S>(
        _ state: S,
        _ next: @escaping (S) -> (V, (E) -> S)) -> Moore<E, V> {
        let (a, transition) = next(state)
        return Moore(view: a) { input in
            unfold(transition(input), next)
        }
    }
    
    /// Creates a Moore machine from an initial state, a rendering function and an update function.
    ///
    /// - Parameters:
    ///   - initialState: Initial state.
    ///   - render: Rendering function.
    ///   - update: Update function.
    /// - Returns: A Moore machine described from the input functions.
    public static func from<S>(
        initialState: S,
        render: @escaping (S) -> V,
        update: @escaping (S, E) -> S) -> Moore<E, V> {
        unfold(initialState) { state in
            (render(state), { input in update(state, input) })
        }
    }
    
    /// Creates a Moore machine from an initial state, a rendering function and an update function.
    ///
    /// - Parameters:
    ///   - initialState: Initial state.
    ///   - render: Rendering function.
    ///   - update: Update function.
    /// - Returns: A Moore machine described from the input functions.
    public static func from<S>(
        initialState: S,
        render: @escaping (S) -> V,
        update: @escaping (E) -> State<S, S>) -> Moore<E, V> {
        from(initialState: initialState, render: render, update: { s, e in update(e).run(s).0 })
    }
    
    /// Initializes a Moore machine.
    ///
    /// - Parameters:
    ///   - view: Value wrapped in the machine.
    ///   - handle: Function to handle inputs to the machine.
    public init(view: V, handle: @escaping (E) -> Moore<E, V>) {
        self.view = view
        self.handle = handle
    }
    
    /// Transforms the inputs this machine is able to handle.
    ///
    /// - Parameter f: Transforming funtion.
    /// - Returns: A Moore machine that works on the new type of inputs.
    public func contramapInput<EE>(_ f: @escaping (EE) -> E) -> Moore<EE, V> {
        Moore<EE, V>(view: self.view, handle: f >>> { x in self.handle(x).contramapInput(f) })
    }
}

public extension Moore where E == V, E: Monoid {
    /// Creates a Moore machine that logs the inputs it receives.
    static var log: Moore<E, E> {
        func h(_ m: E) -> Moore<E, E> {
            Moore(view: m) { a in h(m.combine(a)) }
        }
        return h(.empty())
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Moore.
public postfix func ^<E, V>(_ value: MooreOf<E, V>) -> Moore<E, V> {
    Moore.fix(value)
}

// MARK: Instance of Functor for Moore

extension MoorePartial: Functor {
    public static func map<A, B>(
        _ fa: MooreOf<E, A>,
        _ f: @escaping (A) -> B) -> MooreOf<E, B> {
        Moore<E, B>(view: f(fa^.view),
                    handle: { update in fa^.handle(update).map(f)^ })
    }
}

// MARK: Instance of Comonad for Moore

extension MoorePartial: Comonad {
    public static func coflatMap<A, B>(
        _ fa: MooreOf<E, A>,
        _ f: @escaping (MooreOf<E, A>) -> B) -> MooreOf<E, B> {
        Moore<E, B>(view: f(fa^),
                    handle: { update in fa^.handle(update).coflatMap(f)^ })
    }

    public static func extract<A>(_ fa: MooreOf<E, A>) -> A {
        fa^.view
    }
}

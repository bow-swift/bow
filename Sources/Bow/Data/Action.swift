/// Action is the dual pairing Monad of Moore, obtained automatically using the Co type.
public typealias Action<I, A> = Co<MoorePartial<I>, A>

/// Higher Kinded Type alias to improve readability of `CoOf<MoorePartial<I>, A>`.
public typealias ActionOf<I, A> = CoOf<MoorePartial<I>, A>

/// Witness for the `Action<I, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForAction = ForCo

/// Partial application of the Action type constructor, omitting the last parameter.
public typealias ActionPartial<I> = CoPartial<MoorePartial<I>>

// MARK: Methods for Action

public extension Action where M == ForId {
    /// Creates an Action from an input and a value.
    ///
    /// - Parameters:
    ///   - input: Input.
    ///   - a: Value.
    /// - Returns: An Action that supplies the input to a Moore machine and evaluates it with the value.
    static func liftAction<I>(_ input: I, _ a: A) -> Action<I, A> where W == MoorePartial<I> {
        Action { moore in
            moore^.handle(input).extract()(a)
        }
    }
    
    /// Creates an Action from an input.
    ///
    /// - Parameter input: Input.
    /// - Returns: An Action that supplies the input to a Moore machine.
    static func from<I>(_ input: I) -> Action<I, Void> where W == MoorePartial<I>, A == Void {
        liftAction(input, ())
    }
    
    /// Transform the input of an action.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A new Action with the transformed input.
    func mapAction<I, J>(_ f: @escaping (I) -> J) -> Action<J, A> where W == MoorePartial<I> {
        Action<J, A> { moore in self.cow(moore^.contramapInput(f)) }
    }
}

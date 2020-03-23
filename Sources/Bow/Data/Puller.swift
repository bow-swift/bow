/// Witness for the `Puller<A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForPuller = CoPartial<ForZipper>

/// Partial application of the Puller type constructor, omitting the last type parameter.
public typealias PullerPartial = ForPuller

/// Higher Kinded Type alias to improve readability of `CoOf<ForZipper, A>`.
public typealias PullerOf<A> = CoOf<ForZipper, A>

/// A Puller is the dual Monad of a Zipper, obtained automatically from the Co type.
public typealias Puller<A> = Co<ForZipper, A>

// MARK: Methods for Puller

public extension Puller where M == ForId, W == ForZipper, A == Void  {
    /// Creates a Puller that can move a Zipper focus to the left.
    ///
    /// - Returns: A Puller that can move a Zipper focus to the left.
    static func moveLeft() -> Puller<Void> {
        Puller { cow in cow^.moveLeft().extract()(()) }
    }
    
    /// Creates a Puller that can move a Zipper focus to the right.
    ///
    /// - Returns: A Puller that can move a Zipper focus to the right.
    static func moveRight() -> Puller<Void> {
        Puller { cow in cow^.moveRight().extract()(()) }
    }
    
    /// Creates a Puller that can move a Zipper focus to the leftmost position.
    ///
    /// - Returns: A Puller that can move a Zipper focus to the leftmost position.
    static func moveToFirst() -> Puller<Void> {
        Puller { cow in cow^.moveToFirst().extract()(()) }
    }
    
    /// Creates a Puller that can move a Zipper focus to the rightmost position.
    ///
    /// - Returns: A Puller that can move a Zipper focus to the rightmost position.
    static func moveToLast() -> Puller<Void> {
        Puller { cow in cow^.moveToLast().extract()(()) }
    }
}

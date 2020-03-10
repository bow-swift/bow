/// Partial application of the CoSum type constructor, omitting the last parameter.
public typealias CoSumPartial<F: Comonad, G: Comonad> = CoPartial<SumPartial<F, G>>

/// Higher Kinded Type alias to improve readability of `CoOf<SumPartial<F, G>, A>`.
public typealias CoSumOf<F: Comonad, G: Comonad, A> = CoOf<SumPartial<F, G>, A>

/// CoSum is the dual Monad of the Sum Comonad, obtained automatically from the Co data type.
public typealias CoSum<F: Comonad, G: Comonad, A> = Co<SumPartial<F, G>, A>

/// Partial application of the CoSumOpt type constructor, omitting the last parameter.
public typealias CoSumOptPartial<G: Comonad> = CoSumPartial<ForId, G>

/// Higher Kinded Type alias to improve readability of `Co<SumOptPartial<G>, A>`.
public typealias CoSumOptOf<G: Comonad, A> = CoSumOf<ForId, G, A>

/// CoSumOpt is the dual Monad of the SumOpt Comonad, obtained automatically from the Co data type.
public typealias CoSumOpt<G: Comonad, A> = CoSum<ForId, G, A>

// MARK: Methods for CoSum

public extension CoSum where M == ForId {
    /// Creates a CoSum that can select the left side of a Sum.
    ///
    /// - Returns: A CoSum that selects the left side of a Sum.
    static func moveLeft<F, G>() -> CoSum<F, G, Void> where W == SumPartial<F, G>, A == Void {
        CoSum { cow in cow^.lowerLeft().extract()(()) }
    }
    
    /// Creates a CoSum that can select the right side of a Sum.
    ///
    /// - Returns: A CoSum that selects the right side of a Sum.
    static func moveRight<F, G>() -> CoSum<F, G, Void> where W == SumPartial<F, G>, A == Void {
        CoSum { cow in cow^.lowerRight().extract()(()) }
    }
}

// MARK: Methods to lift Co into CoSum

public extension Co where M == ForId {
    /// Lifts this Co value into a left value of CoSum
    ///
    /// - Returns: A CoSum left value.
    func liftLeft<G>() -> CoSum<W, G, A> {
        CoSum(self.run <<< { sum in sum^.lowerLeft() })
    }
    
    /// Lifts this Co value into a right value of CoSum
    ///
    /// - Returns: A CoSum right value.
    func liftRight<F>() -> CoSum<F, W, A> {
        CoSum(self.run <<< { sum in sum^.lowerRight() })
    }
}

// MARK: Methods for CoSumOpt

public extension CoSumOpt where M == ForId {
    /// Creates a CoSumOpt that can select the hidden side of a SumOpt.
    ///
    /// - Returns: A CoSum that selects the hidden side of a SumOpt.
    static func hide<G>() -> CoSumOpt<G, Void> where W == SumOptPartial<G>, A == Void {
        moveLeft()
    }
    
    /// Creates a CoSumOpt that can select the visible side of a SumOpt.
    ///
    /// - Returns: A CoSum that selects the visible side of a SumOpt.
    static func show<G>() -> CoSumOpt<G, Void> where W == SumOptPartial<G>, A == Void {
        moveRight()
    }
    
    /// Creates a CoSumOpt that can toggle the side of a SumOpt.
    ///
    /// - Returns: A CoSum that toggles side of a SumOpt.
    static func toggle<G>() -> CoSumOpt<G, Void> where W == SumOptPartial<G>, A == Void {
        CoSumOpt { cow in cow^.extractOther()(()) }
    }
}

// MARK: Methods to lift Co into CoSumOpt

public extension Co where M == ForId {
    /// Lifts this Co value into the visible value of CoSumOpt.
    ///
    /// - Returns: A CoSumOpt visible value.
    func liftSumOpt() -> CoSumOpt<W, A> {
        self.liftRight()
    }
}

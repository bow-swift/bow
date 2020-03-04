public typealias CoSumPartial<F: Comonad, G: Comonad> = CoPartial<SumPartial<F, G>>
public typealias CoSumOf<F: Comonad, G: Comonad, A> = CoOf<SumPartial<F, G>, A>
public typealias CoSum<F: Comonad, G: Comonad, A> = Co<SumPartial<F, G>, A>

public typealias CoSumOptPartial<G: Comonad> = CoSumPartial<ForId, G>
public typealias CoSumOptOf<G: Comonad, A> = CoSumOf<ForId, G, A>
public typealias CoSumOpt<G: Comonad, A> = CoSum<ForId, G, A>

public extension CoSum where M == ForId {
    static func moveLeft<F, G>() -> CoSum<F, G, Void> where W == SumPartial<F, G>, A == Void {
        CoSum { cow in cow^.lowerLeft().extract()(()) }
    }
    
    static func moveRight<F, G>() -> CoSum<F, G, Void> where W == SumPartial<F, G>, A == Void {
        CoSum { cow in cow^.lowerRight().extract()(()) }
    }
}

public extension Co where M == ForId {
    func liftLeft<G>() -> CoSum<W, G, A> {
        CoSum(self.run <<< { sum in sum^.lowerLeft() })
    }
    
    func liftRight<F>() -> CoSum<F, W, A> {
        CoSum(self.run <<< { sum in sum^.lowerRight() })
    }
}

public extension CoSumOpt where M == ForId {
    static func hide<G>() -> CoSumOpt<G, Void> where W == SumOptPartial<G>, A == Void {
        moveLeft()
    }
    
    static func show<G>() -> CoSumOpt<G, Void> where W == SumOptPartial<G>, A == Void {
        moveRight()
    }
    
    static func toggle<G>() -> CoSumOpt<G, Void> where W == SumOptPartial<G>, A == Void {
        CoSumOpt { cow in cow^.extractOther()(()) }
    }
}

public extension Co where M == ForId {
    func liftSumOpt() -> CoSumOpt<W, A> {
        self.liftRight()
    }
}

public typealias CoSumPartial<F: Comonad, G: Comonad> = CoPartial<SumPartial<F, G>>
public typealias CoSumOf<F: Comonad, G: Comonad, A> = CoOf<SumPartial<F, G>, A>
public typealias CoSum<F: Comonad, G: Comonad, A> = Co<SumPartial<F, G>, A>

public extension CoSum {
    static func moveLeft<F, G>() -> CoSum<F, G, Void> where W == SumPartial<F, G>, A == Void {
        CoSum { cow in cow^.lowerLeft().extract()(()) }
    }
    
    static func moveRight<F, G>() -> CoSum<F, G, Void> where W == SumPartial<F, G>, A == Void {
        CoSum { cow in cow^.lowerRight().extract()(()) }
    }
}

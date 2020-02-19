// Action is the dual pairing monad of Moore
public typealias Action<I, A> = Co<MoorePartial<I>, A>
public typealias ActionOf<I, A> = CoOf<MoorePartial<I>, A>
public typealias ForAction = ForCo
public typealias ActionPartial<I> = CoPartial<MoorePartial<I>>

public extension Co {
    static func liftAction<I>(_ input: I, _ a: A) -> Action<I, A> where W == MoorePartial<I>, M == ForId {
        Action { moore in
            moore^.handle(input).extract()(a)
        }
    }
    
    static func from<I>(_ input: I) -> Action<I, Void> where W == MoorePartial<I>, M == ForId, A == Void {
        liftAction(input, ())
    }
    
    func mapAction<I, J>(_ f: @escaping (I) -> J) -> Action<J, A> where W == MoorePartial<I>, M == ForId {
        Action<J, A> { moore in self.cow(moore^.contramapInput(f)) }
    }
}

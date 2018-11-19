import Foundation

public typealias StatePartial<S> = StateTPartial<ForId, S>
public typealias StateOf<S, A> = StateT<ForId, S, A>

public class State<S, A> : StateOf<S, A> {
    
    public init(_ run : @escaping (S) -> (S, A)) {
        super.init(Id.pure({ s in Id.pure(run(s)) }))
    }
    
    public func run(_ initial : S) -> (S, A) {
        return self.runM(initial, Id<S>.monad()).fix().extract()
    }
    
    public func runA(_ s : S) -> A {
        return run(s).1
    }
    
    public func runS(_ s : S) -> S {
        return run(s).0
    }
}

public extension State {
    public static func functor() -> StateTFunctor<ForId, S, IdFunctor> {
        return StateT<ForId, S, A>.functor(Id<A>.functor())
    }
    
    public static func applicative() -> StateTApplicative<ForId, S, IdMonad> {
        return StateT<ForId, S, A>.applicative(Id<A>.monad())
    }
    
    public static func monad() -> StateTMonad<ForId, S, IdMonad> {
        return StateT<ForId, S, A>.monad(Id<A>.monad())
    }
    
    public static func monadState() -> StateTMonadState<ForId, S, IdMonad> {
        return StateT<ForId, S, A>.monadState(Id<A>.monad())
    }
}

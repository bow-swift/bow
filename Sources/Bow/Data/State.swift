import Foundation

public typealias StatePartial<S> = StateTPartial<ForId, S>
public typealias StateOf<S, A> = StateT<ForId, S, A>

public class State<S, A> : StateOf<S, A> {
    public static func fix(_ value : StateOf<S, A>) -> State<S, A> {
        return value as! State<S, A>
    }
    
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
    
    public func map<B>(_ f : @escaping (A) -> B) -> StateOf<S, B> {
        return self.map(f, Id<A>.functor())
    }
    
    public func ap<B>(_ ff : StateOf<S, (A) -> B>) -> StateOf<S, B> {
        return self.ap(ff, Id<A>.monad())
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> StateOf<S, B>) -> StateOf<S, B> {
        return self.flatMap(f, Id<A>.monad())
    }
    
    public func product<B>(_ sb : State<S, B>) -> StateOf<S, (A, B)> {
        return self.product(sb, Id<A>.monad())
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

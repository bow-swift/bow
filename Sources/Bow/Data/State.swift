import Foundation

public class State<S, A> : StateT<ForId, S, A> {
    
    public init(_ run : @escaping (S) -> (S, A)) {
        super.init(Id.pure({ s in Id.pure(run(s)) }))
    }
    
    public func run(_ initial : S) -> (S, A) {
        return self.run(initial, Id<S>.monad()).fix().extract()
    }
    
    public func runA(_ s : S) -> A {
        return run(s).1
    }
    
    public func runS(_ s : S) -> S {
        return run(s).0
    }
}

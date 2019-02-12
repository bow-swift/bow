import Foundation

public typealias StatePartial<S> = StateTPartial<ForId, S>
public typealias StateOf<S, A> = StateT<ForId, S, A>

public class State<S, A>: StateOf<S, A> {
    public static func fix(_ value: StateOf<S, A>) -> State<S, A> {
        return value as! State<S, A>
    }
    
    public init(_ run: @escaping (S) -> (S, A)) {
        super.init(Id.pure({ s in Id.pure(run(s)) }))
    }
}

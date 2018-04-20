import Foundation

public protocol FunctionK {
    associatedtype F
    associatedtype G
    
    func invoke<A>(_ fa : Kind<F, A>) -> Kind<G, A>
}

public class IdFunctionK<M> : FunctionK {
    public typealias F = M
    public typealias G = M
    
    public static var id : IdFunctionK<M> {
        return IdFunctionK<M>()
    }
    
    public func invoke<A>(_ fa: Kind<M, A>) -> Kind<M, A> {
        return fa
    }
}

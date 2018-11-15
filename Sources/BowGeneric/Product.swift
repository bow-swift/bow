import Foundation
import Bow

public protocol Product : Typeclass {
    associatedtype C
    
    func product<H, T : HList>(_ ch : Kind<C, H>, _ ct : Kind<C, T>) -> Kind<C, HCons<H, T>>
    
    func emptyProduct() -> Kind<C, HNil>
    
    func project<F, G>(_ instance : @escaping () -> Kind<C, G>, _ to : @escaping (F) -> G, _ from : (G) -> F) -> Kind<C, F>
}

public protocol LabeledProduct : Typeclass {
    associatedtype C
    
    func product<H, T : HList>(name : String, _ ch : Kind<C, H>, _ ct : Kind<C, T>) -> Kind<C, HCons<H, T>>
    
    func emptyProduct() -> Kind<C, HNil>
    
    func project<F, G>(_ instance : @escaping () -> Kind<C, G>, _ to : @escaping (F) -> G, _ from : (G) -> F) -> Kind<C, F>
}

public protocol ProductCompanion {
    associatedtype A
    associatedtype P where P : Product, P.C == A
    
    var typeclass : P { get }
}

public extension ProductCompanion {
    public func deriveHNil() -> Kind<A, HNil> {
        return typeclass.emptyProduct()
    }
    
    public func deriveHCons<H, T : HList>(_ ch : Kind<A, H>, _ ct : Kind<A, T>) -> Kind<A, HCons<H, T>> {
        return typeclass.product(ch, ct)
    }
    
    public func deriveInstance<F, G, Gener>(_ generic : Gener, _ cg : Kind<A, G>) -> Kind<A, F> where Gener : Generic, Gener.T == F, Gener.Repr == G {
        return typeclass.project(constant(cg), generic.to, generic.from)
    }
}

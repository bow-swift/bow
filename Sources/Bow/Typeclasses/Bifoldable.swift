import Foundation

public protocol Bifoldable : Typeclass {
    associatedtype F
    
    func bifoldLeft<A, B, C>(_ fab : Kind2<F, A, B>, _ c : C, _ f : (C, A) -> C, _ g : (C, B) -> C) -> C
    func bifoldRight<A, B, C>(_ fab : Kind2<F, A, B>, _ c : Eval<C>, _ f : (A, Eval<C>) -> Eval<C>, _ g : (B, Eval<C>) -> Eval<C>) -> Eval<C>
}

public extension Bifoldable {
    public func bifoldMap<A, B, C, Mono>(_ fab : Kind2<F, A, B>, _ f : (A) -> C, _ g : (B) -> C, _ monoid : Mono) -> C where Mono : Monoid, Mono.A == C {
        return bifoldLeft(fab, monoid.empty, { c, a in monoid.combine(c, f(a)) }, { c, b in monoid.combine(c, g(b)) })
    }
}

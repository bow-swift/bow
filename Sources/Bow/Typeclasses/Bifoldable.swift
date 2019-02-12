import Foundation

public protocol Bifoldable {
    associatedtype F
    
    func bifoldLeft<A, B, C>(_ fab : Kind2<F, A, B>, _ c : C, _ f : (C, A) -> C, _ g : (C, B) -> C) -> C
    func bifoldRight<A, B, C>(_ fab : Kind2<F, A, B>, _ c : Eval<C>, _ f : (A, Eval<C>) -> Eval<C>, _ g : (B, Eval<C>) -> Eval<C>) -> Eval<C>
}

public extension Bifoldable {
    public func bifoldMap<A, B, C: Monoid>(_ fab : Kind2<F, A, B>, _ f : (A) -> C, _ g : (B) -> C) -> C {
        return bifoldLeft(fab, C.empty(), { c, a in c.combine(f(a)) }, { c, b in c.combine(g(b)) })
    }
}

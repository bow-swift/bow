import Foundation
import Bow

public typealias Algebra<F, A> = (Kind<F, A>) -> A
public typealias Coalgebra<F, A> = (A) -> Kind<F, A>

public extension Functor {
    static func hylo<A, B>(_ algebra : @escaping Algebra<Self, Eval<B>>,
                           _ coalgebra : @escaping Coalgebra<Self, A>,
                           _ a : A) -> B {
        func h(_ a : A) -> Eval<B> {
            return algebra(map(coalgebra(a), { x in Eval.defer({ h(x) }) }))
        }
        return h(a).value()
    }
}

// MARK: Syntax for F-Algebras
public extension Kind where F: Functor {
    static func hylo<B>(_ algebra: @escaping Algebra<F, Eval<B>>,
                        _ coalgebra: @escaping Coalgebra<F, A>,
                        _ a: A) -> B {
        return F.hylo(algebra, coalgebra, a)
    }
}

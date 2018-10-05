import Foundation

public typealias Algebra<F, A> = (Kind<F, A>) -> A
public typealias Coalgebra<F, A> = (A) -> Kind<F, A>

public extension Functor {
    public func hylo<A, B>(_ algebra : @escaping Algebra<F, Eval<B>>,
                           _ coalgebra : @escaping Coalgebra<F, A>,
                           _ a : A) -> B {
        func h(_ a : A) -> Eval<B> {
            return algebra(map(coalgebra(a), { x in Eval.deferEvaluation({ h(x) }) }))
        }
        return h(a).value()
    }
}

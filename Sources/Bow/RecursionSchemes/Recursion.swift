import Foundation

public typealias Algebra<F, A> = (Kind<F, A>) -> A
public typealias Coalgebra<F, A> = (A) -> Kind<F, A>

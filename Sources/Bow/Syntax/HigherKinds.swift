import Foundation

open class Kind<F, A> {
    public init() {}
}
public typealias Kind2<F, A, B> = Kind<Kind<F, A>, B>
public typealias Kind3<F, A, B, C> = Kind<Kind2<F, A, B>, C>
public typealias Kind4<F, A, B, C, D> = Kind<Kind3<F, A, B, C>, D>
public typealias Kind5<F, A, B, C, D, E> = Kind<Kind4<F, A, B, C, D>, E>

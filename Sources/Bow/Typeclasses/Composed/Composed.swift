import Foundation

public typealias Nested<F, G> = (F, G)

public typealias NestedType<F, G, A> = Kind<Nested<F, G>, A>
public typealias UnnestedType<F, G, A> = Kind<F, Kind<G, A>>

public func unnest<F, G, A>(_ nested : NestedType<F, G, A>) -> Kind<F, Kind<G, A>> {
    return nested as! UnnestedType<F, G, A>
}

public func nest<F, G, A>(_ unnested : UnnestedType<F, G, A>) -> NestedType<F, G, A> {
    return unnested as! Kind<Nested<F, G>, A>
}

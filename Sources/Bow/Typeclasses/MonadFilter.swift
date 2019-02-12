import Foundation

public protocol MonadFilter: Monad, FunctorFilter {
    static func empty<A>() -> Kind<Self, A>
}

public extension MonadFilter {
    public static func mapFilter<A, B>(_ fa : Kind<Self, A>, _ f : @escaping (A) -> OptionOf<B>) -> Kind<Self, B>{
        return flatMap(fa, { a in
            Option<B>.fix(f(a)).fold(self.empty, self.pure)
        })
    }
}

// MARK: Syntax for MonadFilter

public extension Kind where F: MonadFilter {
    public static var empty: Kind<F, A> {
        return F.empty()
    }
}

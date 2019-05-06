import Foundation

/// A MonadFilter is a `Monad` with `FunctorFilter` capabilities. It also provides functionality to create a value that represents an empty element in the context implementing an instance of this typeclass.
///
/// Implementing this typeclass automatically derives an implementation for `FunctorFilter.mapFilter`.
public protocol MonadFilter: Monad, FunctorFilter {
    /// Obtains an empty element in the context implementing this instance.
    ///
    /// - Returns: Empty element.
    static func empty<A>() -> Kind<Self, A>
}

// MARK: Related functions

public extension MonadFilter {
    // Docs inherited from `FunctorFilter`
    static func mapFilter<A, B>(_ fa : Kind<Self, A>, _ f : @escaping (A) -> OptionOf<B>) -> Kind<Self, B>{
        return flatMap(fa, { a in
            Option<B>.fix(f(a)).fold(self.empty, self.pure)
        })
    }
}

// MARK: Syntax for MonadFilter

public extension Kind where F: MonadFilter {
    /// Obtains an empty element in this context.
    ///
    /// - Returns: Empty element.
    static var empty: Kind<F, A> {
        return F.empty()
    }
}

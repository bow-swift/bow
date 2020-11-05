import Foundation

/// Encodes the notion of existential type. `Exists<F>` is a wrapper around a `Kind<F, X>` value, where `X` is some type that is not exposed on `Exists` signature.
///
/// You provide a value of type `Kind<F, X>` when constructing an `Exists<F>`instance but the specific type `X` that you provide is hidden inside `Exists`.
/// The only way to interact with the content of `Exists<F>` is with a function of type `Kind<F, X> -> R` that is polymorphic on `X` (represented by the `CokleisliK<F, R` class).
/// You pass a `CokleisliK<F, R>` to an `Exists<F>` and the function is called with the specific type that is hidden inside the `Exists`.
/// This is done with the `run` method.
public final class Exists<F> {
    /// Construct and `Exists` from a value of type `Kind<F, A>` and hide it's type parameter `A`.
    public init<A>(_ fa: Kind<F, A>) {
        self.fa = ExistsPrivate(fa)
    }

    private let fa: AnyExistsPrivate<F>

    /// Process the contents of this `Exists` with a function of type `Kind<F, X> -> R` that is polymorphic on `X`.
    public func run<R>(_ f: CokleisliK<F, R>) -> R {
        fa.run(f)
    }
}

/// `AnyExistsPrivate` represents an `ExistsPrivate<F, A>` for which we have forgotten its specific type `A`.
///
/// AnyExistsPrivate needs to be a class because a protocol with an associated type F
/// couldn't be stored inside Exists as an existential.
/// We'll be able to use a protocol when this gets done:
/// https://forums.swift.org/t/lifting-the-self-or-associated-type-constraint-on-existentials/18025
fileprivate class AnyExistsPrivate<F> {
    open func run<R>(_ f: CokleisliK<F, R>) -> R {
        fatalError("This method should be implemented by ExistsPrivate")
    }
}

/// We use this class to "remember" how to call a `CokleisliK<F, R>` with our `Kind<F, A>` once we have erased the type parameter `A` under `AnyExistsPrivate<F>`
fileprivate final class ExistsPrivate<F, A>: AnyExistsPrivate<F> {
    init(_ fa: Kind<F, A>) {
        self.fa = fa
    }

    let fa: Kind<F, A>

    public override func run<R>(_ f: CokleisliK<F, R>) -> R {
        f.invoke(fa)
    }
}

extension Exists: CustomStringConvertible {
    public var description: String {
        (fa as! CustomStringConvertible).description
    }
}

extension ExistsPrivate: CustomStringConvertible {
    var description: String {
        (fa as? CustomStringConvertible)?.description ?? "\(fa)"
    }
}

extension Exists: CustomDebugStringConvertible {
    public var debugDescription: String {
        (fa as! CustomDebugStringConvertible).debugDescription
    }
}

extension ExistsPrivate: CustomDebugStringConvertible {
    var debugDescription: String {
        (fa as? CustomDebugStringConvertible)?.debugDescription ?? "\(fa)"
    }
}

import Foundation
import Bow

public final class Exists<F> {
    public init<A>(_ fa: Kind<F, A>) {
        self.fa = ExistsPrivate(fa)
    }

    private let fa: AnyExistsPrivate<F>

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

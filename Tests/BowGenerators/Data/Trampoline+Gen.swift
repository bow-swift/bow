import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Trampoline: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Trampoline<A>> {
        Gen.sized(arbitraryTrampoline)
    }

    static func arbitraryTrampoline<T: Arbitrary>(_ depth: Int) -> Gen<Trampoline<T>> {
        guard depth > 0 else { return arbitraryDone() }
        return Gen<Trampoline<T>>.one(of: [arbitraryDone(), arbitraryDefer(depth/2), arbitraryFlatMap(depth/2)])
    }

    static func arbitraryDone<T: Arbitrary>() -> Gen<Trampoline<T>> {
        T.arbitrary.map(Trampoline<T>.done)
    }

    static func arbitraryDefer<T: Arbitrary>(_ depth: Int) -> Gen<Trampoline<T>> {
        arbitraryTrampoline(depth).map { t in
            Trampoline<T>.defer(constant(t))
        }
    }

    static func arbitraryFlatMap<T: Arbitrary>(_ depth: Int) -> Gen<Trampoline<T>> {
        let nestedTrampoline: Gen<Trampoline<Trampoline<T>>> = arbitraryTrampoline(depth)
        return nestedTrampoline.map { $0.flatMap(id)^ }
    }
}

// MARK: Instance of ArbitraryK for Function1

extension TrampolinePartial: ArbitraryK {
    public static func generate<A: Arbitrary>() -> TrampolineOf<A> {
        Trampoline.arbitrary.generate
    }
}

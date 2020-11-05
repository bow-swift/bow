import XCTest
import SwiftCheck
import BowLaws
import Bow

public final class ForStream {}
public final class StreamFPartial<A>: Kind<ForStream, A> {}
public typealias StreamFOf<A, S> = Kind<StreamFPartial<A>, S>
public final class StreamF<A, S>: StreamFOf<A, S> {
    internal init(s: S, next: @escaping (S) -> (S, A)) {
        self.s = s
        self.next = next
    }

    let s: S
    let next: (S) -> (S, A)

    static func fix(_ fa: StreamFOf<A, S>) -> StreamF<A, S> {
        fa as! StreamF<A, S>
    }
}

public postfix func ^<A, S>(_ fa: StreamFOf<A, S>) -> StreamF<A, S> {
    StreamF.fix(fa)
}

typealias Stream<A> = Exists<StreamFPartial<A>>

let nats: Stream<String> = Stream(
    StreamF<String, Int>(s: 0, next: { (n: Int) -> (Int, String) in
        (n+1, "\(n)")
    })
)

class HeadF<A>: CokleisliK<StreamFPartial<A>, A> {
    override init() {
        super.init()
    }

    override func invoke<T>(_ fa: Kind<StreamFPartial<A>, T>) -> A {
        let s = StreamF.fix(fa).s
        let next = StreamF.fix(fa).next

        return next(s).1
    }
}

func head<R>(_ s: Stream<R>) -> R {
    s.run(HeadF())
}

class EnumerateF<A>: CokleisliK<StreamFPartial<A>, [A]> {
    init(n: Int) {
        self.n = n
        super.init()
    }

    let n: Int

    override func invoke<S>(_ fa: Kind<StreamFPartial<A>, S>) -> [A] {
        typealias P = (s: S, aa: [A])

        let initialState = fa^.s
        let next: State<P, A> = State<S, A>(fa^.next)
            .focus({ $0.0 }, { ($1, $0.1) })

        let f: State<P, Void> = StatePartial<P>.tailRecM(n) { (i: Int) -> State<P, Either<Int, Void>> in
            let r = State<P, A>.var()
            return binding(
                r <-- next,
                |<-StatePartial<P>.modify { oldState in
                    (oldState.s, oldState.aa + [r.get])
                },
                yield: (i == 1) ? Either.right(()) : Either.left(i-1))^
        }^

        return f.runS((initialState, [])).1
    }
}

func enumerate<R>(_ s: Stream<R>, n: Int) -> [R] {
    s.run(EnumerateF(n: n))
}

class ExistsTests: XCTestCase {

    func testImplementationOfDataTypeBasedOnExists() {
        XCTAssertEqual(head(nats), "0")
        XCTAssertEqual(enumerate(nats, n: 4), ["0", "1", "2", "3"])
    }

    /// Given a function `f: Kind<F, A> -> R` polymorphic on `A`,
    /// assert that wrapping a value `fa: Kind<F, A>` in an `Exists<F>`
    /// does not change the result of `f`, i.e `f(fa) == Exists(fa).run(f)`.
    func testFunctionApplicationTransparency() {
        property("Function application transparency") <~ forAll { (fa: ArrayK<Int>) in
            Exists(fa).run(F()) == F()(fa)
        }
    }

    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Exists<ForArrayK>>.check()
        CustomStringConvertibleLaws<Exists<ForId>>.check()
        CustomStringConvertibleLaws<Exists<ForOption>>.check()
    }

    func testDescriptionMatchesInnerTypeDescription() {
        property("""
            Description matches inner type's description
            when the inner type conforms to CustomStringConvertible
        """) <~ forAll { (array: ArrayK<Int>) in
            
            Exists(array).description == array.description
        }
    }

    func testDescriptionDefaultsToStringInterpolation() {
        property("""
            Description defaults to string interpolation
            when the inner type does not conform to CustomStringConvertible
        """) <~ forAll { (array: ArrayK<Function0<Int>>) in

            return Exists(array).description == "\(array)"
        }
    }

    func testCustomDebugStringConvertibleWhenInnerTypeIs() {
        property("""
            Description matches inner type's description
            when the inner type conforms to CustomStringConvertible
        """) <~ forAll { (array: ArrayK<String>) in
            return Exists(array).debugDescription == array.debugDescription
        }
    }

    func testDebugDescriptionDefaultsToStringInterpolation() {
        property("""
            Description defaults to string interpolation
            when the inner type does not conform to CustomStringConvertible
        """) <~ forAll { (array: ArrayK<Function0<Int>>) in

            return Exists(array).debugDescription == "\(array)"
        }
    }

    class F: CokleisliK<ArrayKPartial, Int64> {
        override func invoke<A>(_ fa: ArrayKOf<A>) -> Int64 {
            fa^.count
        }
    }
}

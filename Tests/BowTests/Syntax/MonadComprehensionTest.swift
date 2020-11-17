import XCTest
import SwiftCheck
import Bow
import BowLaws

class MonadComprehensionTest: XCTestCase {
    func testMonadComprehesionsDontEraseToAny() {
        let fa = IdCrashingOnAnyPartial.pure(1)
        let fb = IdCrashingOnAnyPartial.pure(2)
        let fc = IdCrashingOnAnyPartial.pure(3)
        let fd = IdCrashingOnAnyPartial.pure(4)

        let x = IdCrashingOnAnyOf<Int>.var()
        let y = IdCrashingOnAnyOf<Int>.var()
        let z = IdCrashingOnAnyOf<Int>.var()
        let w = IdCrashingOnAnyOf<Int>.var()

        let result = binding(
            x <-- fa,
            y <-- fb,
            z <-- fc,
            w <-- fd,
            yield: x.get + y.get + z.get + w.get)

        XCTAssertEqual(result^.value, 10)
    }
}

fileprivate final class ForIdCrashingOnAny {}
fileprivate typealias IdCrashingOnAnyPartial = ForIdCrashingOnAny
fileprivate typealias IdCrashingOnAnyOf<A> = Kind<IdCrashingOnAnyPartial, A>
fileprivate final class IdCrashingOnAny<A>: IdCrashingOnAnyOf<A> {
    let value: A

    init(_ value: A) {
        self.value = value
    }

    static func fix(_ fa: IdCrashingOnAnyOf<A>) -> IdCrashingOnAny<A> {
        fa as! IdCrashingOnAny<A>
    }
}

fileprivate postfix func ^<A>(_ fa: IdCrashingOnAnyOf<A>) -> IdCrashingOnAny<A> {
    IdCrashingOnAny.fix(fa)
}

extension IdCrashingOnAnyPartial: Functor {
    public static func map<A, B>(_ fa: IdCrashingOnAnyOf<A>, _ f: @escaping (A) -> B) -> Kind<IdCrashingOnAnyPartial, B> {
        IdCrashingOnAny<B>(f(fa^.value))
    }
}

extension IdCrashingOnAnyPartial: Applicative {
    static func pure<A>(_ a: A) -> Kind<IdCrashingOnAnyPartial, A> {
        IdCrashingOnAny(a)
    }
}

extension IdCrashingOnAnyPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: IdCrashingOnAnyOf<A>,
        _ f: @escaping (A) -> IdCrashingOnAnyOf<B>) -> IdCrashingOnAnyOf<B> {
        XCTAssertNotEqual(
            String(describing: A.self),
            "Any",
            "Monad comprehensions should not erase `Kind<F, A>` to `Kind<F, Any>`"
        )
        return f(fa^.value)
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> IdCrashingOnAnyOf<Either<A, B>>) -> IdCrashingOnAnyOf<B> {
        _tailRecM(a, f).run()
    }

    private static func _tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> IdCrashingOnAnyOf<Either<A, B>>) -> Trampoline<IdCrashingOnAnyOf<B>> {
        .defer {
            f(a)^.value.fold(
                { left in _tailRecM(left, f) },
                { right in .done(IdCrashingOnAny(right)) })
        }
    }
}

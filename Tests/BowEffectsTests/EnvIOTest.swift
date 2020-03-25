import XCTest
import SwiftCheck
@testable import BowLaws
import Bow
import BowEffects
import BowEffectsGenerators
import BowEffectsLaws

extension KleisliPartial: EquatableK where F: EquatableK, D == Int {
    public static func eq<A: Equatable>(
        _ lhs: KleisliOf<F, D, A>,
        _ rhs: KleisliOf<F, D, A>) -> Bool {
        lhs^.run(1) == rhs^.run(1)
    }
}

class EnvIOTest: XCTestCase {
    func testMonadDeferLaws() {
        MonadDeferLaws<EnvIOPartial<Int, CategoryError>>.check()
    }
    
    func testAsyncLaws() {
        AsyncLaws<EnvIOPartial<Int, CategoryError>>.check()
    }
}

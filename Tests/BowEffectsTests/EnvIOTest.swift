import XCTest
import SwiftCheck
@testable import BowLaws
import Bow
import BowEffects
import BowEffectsGenerators
import BowEffectsLaws

class EnvIOTest: XCTestCase {
    func testMonadDeferLaws() {
        MonadDeferLaws<EnvIOPartial<Int, CategoryError>>.check()
    }
    
    func testAsyncLaws() {
        AsyncLaws<EnvIOPartial<Int, CategoryError>>.check()
    }
}

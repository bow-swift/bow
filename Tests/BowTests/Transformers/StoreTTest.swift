import XCTest
import BowLaws
import Bow

extension StoreTPartial: EquatableK where W: Comonad & EquatableK {
    public static func eq<A: Equatable>(_ lhs: StoreTOf<S, W, A>,
                                        _ rhs: StoreTOf<S, W, A>) -> Bool {
        lhs^.extract() == rhs^.extract()
    }
}

class StoreTTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<StorePartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<StorePartial<Int>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<StorePartial<Int>>.check()
    }

    func testComonadTransLaws() {
        ComonadTransLaws<StoreTPartial<Int, ForId>, String, Int>.check()
        ComonadTransLaws<StoreTPartial<Int, ForFunction0>, String, Int>.check()
    }
    
    func testComonadStoreLaws() {
        ComonadStoreLaws<StorePartial<Int>, Int>.check()
    }
    
    func testComonadTracedLaws() {
        ComonadTracedLaws<StoreTPartial<Int, TracedPartial<Int>>, Int>.check()
    }
    
    func testComonadEnvLaws() {
        ComonadEnvLaws<StoreTPartial<Int, EnvPartial<Int>>, Int>.check()
    }
    
    let greetingStore = { (name: String) in Store(name, { name in "Hi \(name)!"}) }
    
    func testExtractRendersCurrentState() {
        let result = greetingStore("Bow")
        XCTAssertEqual(result.extract(), "Hi Bow!")
    }
    
    func testCoflatMapCreatesNewStore() {
        let result = greetingStore("Bow").coflatMap { (store) -> String in
            if Store.fix(store).state == "Bow" {
                return "This is my master"
            } else {
                return "This is not my master"
            }
        }
        XCTAssertEqual(result.extract(), "This is my master")
    }
    
    func testMapModifiesRenderResult() {
        let result = greetingStore("Bow").map { str in str.uppercased() }
        XCTAssertEqual(result.extract(), "HI BOW!")
    }
}

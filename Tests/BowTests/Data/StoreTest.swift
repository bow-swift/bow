import XCTest
import Nimble
@testable import BowLaws
import Bow

extension StorePartial: EquatableK {
    public static func eq<A>(_ lhs: Kind<StorePartial<S>, A>, _ rhs: Kind<StorePartial<S>, A>) -> Bool where A: Equatable {
        return Store.fix(lhs).extract() == Store.fix(rhs).extract()
    }
}

class StoreTest: XCTestCase {
    let intStore = { (x: Int) in Store(state: x, render: id) }

    func testFunctorLaws() {
        FunctorLaws<StorePartial<Int>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<StorePartial<Int>>.check()
    }
    
    let greetingStore = { (name : String) in Store(state: name, render: { name in "Hi \(name)!"}) }
    
    func testExtractRendersCurrentState() {
        let result = greetingStore("Bow")
        expect(result.extract()).to(equal("Hi Bow!"))
    }
    
    func testCoflatMapCreatesNewStore() {
        let result = greetingStore("Bow").coflatMap { (store) -> String in
            if Store.fix(store).state == "Bow" {
                return "This is my master"
            } else {
                return "This is not my master"
            }
        }
        expect(result.extract()).to(equal("This is my master"))
    }
    
    func testMapModifiesRenderResult() {
        let result = greetingStore("Bow").map { str in str.uppercased() }
        expect(result.extract()).to(equal("HI BOW!"))
    }
}

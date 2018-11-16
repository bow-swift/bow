import XCTest
import Nimble
@testable import BowLaws
@testable import Bow

class StoreTest : XCTestCase {
    let intStore = { (x : Int) in Store(state: x, render: id) }
    
    class StoreEq : Eq {
        typealias A = StoreOf<Int, Int>
        
        func eqv(_ a: StoreOf<Int, Int>, _ b: StoreOf<Int, Int>) -> Bool {
            return Store<Int, Int>.fix(a).extract() == Store<Int, Int>.fix(b).extract()
        }
    }
    
    class StoreEqUnit : Eq {
        typealias A = StoreOf<Int, ()>
        
        func eqv(_ a: StoreOf<Int, ()>, _ b: StoreOf<Int, ()>) -> Bool {
            return Store<Int, ()>.fix(a).extract() == Store<Int, ()>.fix(b).extract()
        }
    }
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: Store<Int, Int>.functor(), generator: intStore, eq: StoreEq(), eqUnit: StoreEqUnit())
    }
    
    func testComonadLaws() {
        ComonadLaws.check(comonad: Store<Int, Int>.comonad(), generator: intStore, eq: StoreEq())
    }
    
    let greetingStore = { (name : String) in Store(state: name, render: { name in "Hi \(name)!"}) }
    
    func testExtractRendersCurrentState() {
        let result = greetingStore("Bow")
        expect(result.extract()).to(equal("Hi Bow!"))
    }
    
    func testCoflatMapCreatesNewStore() {
        let result = greetingStore("Bow").coflatMap { (store) -> String in
            if store.state == "Bow" {
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

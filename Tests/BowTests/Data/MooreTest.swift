import XCTest
import Nimble
@testable import Bow

class MooreTest : XCTestCase {
    func handle(_ x : Int) -> Moore<Int, Int> {
        return Moore(view: x, handle: handle)
    }
    
    class MooreEq : Eq {
        typealias A = MooreOf<Int, Int>
        
        func eqv(_ a: MooreOf<Int, Int>, _ b: MooreOf<Int, Int>) -> Bool {
            return Moore<Int, Int>.fix(a).extract() == Moore<Int, Int>.fix(b).extract()
        }
    }
    
    class MooreEqUnit : Eq {
        typealias A = MooreOf<Int, ()>
        
        func eqv(_ a: MooreOf<Int, ()>, _ b: MooreOf<Int, ()>) -> Bool {
            return Moore<Int, ()>.fix(a).extract() == Moore<Int, ()>.fix(b).extract()
        }
    }
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: Moore<Int, Int>.functor(), generator: handle, eq: MooreEq(), eqUnit: MooreEqUnit())
    }
    
    func testComonadLaws() {
        ComonadLaws.check(comonad: Moore<Int, Int>.comonad(), generator: handle, eq: MooreEq())
    }
    
    func handleRoute(_ route : String) -> Moore<String, Id<String>> {
        switch route {
        case "About": return Moore(view: Id("About"), handle: handleRoute)
        case "Home": return Moore(view: Id("Home"), handle: handleRoute)
        default: return Moore(view: Id("???"), handle: handleRoute)
        }
    }
    
    var routerMoore : Moore<String, Id<String>>!
    
    override func setUp() {
         routerMoore = Moore(view: Id("???"), handle: handleRoute)
    }
    
    func testViewAfterHandle() {
        let currentRoute = routerMoore.handle("About").extract().extract()
        expect(currentRoute).to(equal("About"))
    }
    
    func testViewAfterSeveralHandle() {
        let currentRoute = routerMoore.handle("About").handle("Home").extract().extract()
        expect(currentRoute).to(equal("Home"))
    }
    
    func testViewAfterCoflatMap() {
        let currentRoute = routerMoore!.coflatMap { (view) -> Int in
            switch view.extract().extract() {
            case "About": return 1
            case "Home": return 2
            default: return 0
            }
        }.extract()
        
        expect(currentRoute).to(equal(0))
    }
    
    func testViewAfterMap() {
        let currentRoute = routerMoore.map { (view : Id<String>) -> Int in
            switch view.extract() {
            case "About": return 1
            case "Home": return 2
            default: return 0
            }
        }.extract()
        expect(currentRoute).to(equal(0))
    }
}

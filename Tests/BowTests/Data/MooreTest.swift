import XCTest
import Nimble
import BowLaws
import Bow

extension MoorePartial: EquatableK {
    public static func eq<A>(_ lhs: Kind<MoorePartial<E>, A>, _ rhs: Kind<MoorePartial<E>, A>) -> Bool where A : Equatable {
        return Moore.fix(lhs).extract() == Moore.fix(rhs).extract()
    }
}

class MooreTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<MoorePartial<Int>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<MoorePartial<Int>>.check()
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

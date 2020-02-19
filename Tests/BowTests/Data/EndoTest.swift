import XCTest
import SwiftCheck
import BowLaws
import Bow

extension ForEndo: EquatableK {
    public static func eq<A>(_ a: EndoOf<A>, _ b: EndoOf<A>) -> Bool where A : Equatable {
        return a^.run(1 as! A) == b^.run(1 as! A)
    }
}

class EndoTest: XCTestCase {
    
    func testSemigroupLaws() {
        SemigroupLaws<Endo<Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Endo<Int>>.check()
    }
}

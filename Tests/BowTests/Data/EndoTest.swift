import XCTest
import SwiftCheck
import BowLaws
import Bow

extension EndoPartial: EquatableK {
    public static func eq<A: Equatable>(_ a: EndoOf<A>, _ b: EndoOf<A>) -> Bool {
        a^.run(1 as! A) == b^.run(1 as! A)
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

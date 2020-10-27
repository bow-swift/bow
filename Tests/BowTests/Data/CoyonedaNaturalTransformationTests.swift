import XCTest
import SwiftCheck
import BowLaws
import Bow

class CoyonedaNaturalTransformationTests: XCTestCase {

    func testNaturality() {
        let n = ArrayKPartial.firstOrNone.coyoneda
        let f: (Int) -> String = { "\($0)" }

        property("Naturality") <~ forAll { (fa: Coyoneda<ArrayKPartial, Int>) in
            n(fa).map(f) == n(fa.map(f))
        }
    }
}

import XCTest
import SwiftCheck
@testable import Bow

class ShowLaws {
    
    static func check<Sh, A>(show : Sh, generator : @escaping (Int) -> A) where Sh : Show, Sh.A == A {
        equality(show, generator)
    }
    
    private static func equality<Sh, A>(_ show : Sh, _ generator : @escaping (Int) -> A) where Sh : Show, Sh.A == A {
        property("Equal objects must show equal content") <- forAll { (a : Int) in
            let x1 = generator(a)
            let x2 = generator(a)
            return show.show(x1) == show.show(x2)
        }
    }
    
}

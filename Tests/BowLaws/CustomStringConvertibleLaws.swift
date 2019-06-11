import SwiftCheck
@testable import Bow

class CustomStringConvertibleLaws<A: CustomStringConvertible & Arbitrary> {
    static func check(){
        equality()
    }
    
    private static func equality() {
        property("Equal objects must show equal content") <- forAll { (a: A) in
            let x1 = a
            let x2 = a
            return x1.description == x2.description
        }
    }
    
}

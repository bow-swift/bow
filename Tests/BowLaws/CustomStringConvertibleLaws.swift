import SwiftCheck
@testable import Bow

class CustomStringConvertibleLaws<A: CustomStringConvertible> {
    static func check(generator : @escaping (Int) -> A){
        equality(generator)
    }
    
    private static func equality(_ generator: @escaping (Int) -> A) {
        property("Equal objects must show equal content") <- forAll { (a : Int) in
            let x1 = generator(a)
            let x2 = generator(a)
            return x1.description == x2.description
        }
    }
    
}

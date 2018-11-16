import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class NumberInstancesTest: XCTestCase {
    
    func testIntEqLaws() {
        EqLaws.check(eq: Int.order, generator: id)
    }
    
    func testIntOrderLaws() {
        OrderLaws.check(order: Int.order, generator: id)
    }
    
    func testInt8EqLaws() {
        EqLaws.check(eq: Int8.order, generator: id)
    }
    
    func testInt8OrderLaws() {
        OrderLaws.check(order: Int8.order, generator: id)
    }
    
    func testInt16EqLaws() {
        EqLaws.check(eq: Int16.order, generator: id)
    }
    
    func testInt16OrderLaws() {
        OrderLaws.check(order: Int16.order, generator: id)
    }
    
    func testInt32EqLaws() {
        EqLaws.check(eq: Int32.order, generator: id)
    }
    
    func testInt32OrderLaws() {
        OrderLaws.check(order: Int32.order, generator: id)
    }
    
    func testInt64EqLaws() {
        EqLaws.check(eq: Int64.order, generator: id)
    }
    
    func testInt64OrderLaws() {
        OrderLaws.check(order: Int64.order, generator: id)
    }
    
    func testUIntEqLaws() {
        EqLaws.check(eq: Int.order, generator: id)
    }
    
    func testUIntOrderLaws() {
        OrderLaws.check(order: UInt.order, generator: id)
    }
    
    func testUInt8EqLaws() {
        EqLaws.check(eq: Int8.order, generator: id)
    }
    
    func testUInt8OrderLaws() {
        OrderLaws.check(order: UInt8.order, generator: id)
    }
    
    func testUInt16EqLaws() {
        EqLaws.check(eq: Int16.order, generator: id)
    }
    
    func testUInt16OrderLaws() {
        OrderLaws.check(order: UInt16.order, generator: id)
    }
    
    func testUInt32EqLaws() {
        EqLaws.check(eq: Int32.order, generator: id)
    }
    
    func testUInt32OrderLaws() {
        OrderLaws.check(order: UInt32.order, generator: id)
    }
    
    func testUInt64EqLaws() {
        EqLaws.check(eq: Int64.order, generator: id)
    }
    
    func testUInt64OrderLaws() {
        OrderLaws.check(order: UInt64.order, generator: id)
    }
    
    func testFloatEqLaws() {
        EqLaws.check(eq: Float.order, generator: id)
    }
    
    func testFloatOrderLaws() {
        OrderLaws.check(order: Float.order, generator: id)
    }
    
    func testDoubleEqLaws() {
        EqLaws.check(eq: Double.order, generator: id)
    }
    
    func testDoubleOrderLaws() {
        OrderLaws.check(order: Double.order, generator: id)
    }
    
    func testIntSemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(semigroup: Int.sumMonoid, a: a, b: b, c: c, eq: Int.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(semigroup: Int.productMonoid, a: a, b: b, c: c, eq: Int.order)
        }
    }
    
    func testInt8SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : Int8, b : Int8, c : Int8) in
            return SemigroupLaws.check(semigroup: Int8.sumMonoid, a: a, b: b, c: c, eq: Int8.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : Int8, b : Int8, c : Int8) in
            return SemigroupLaws.check(semigroup: Int8.productMonoid, a: a, b: b, c: c, eq: Int8.order)
        }
    }
    
    func testInt16SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : Int16, b : Int16, c : Int16) in
            return SemigroupLaws.check(semigroup: Int16.sumMonoid, a: a, b: b, c: c, eq: Int16.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : Int16, b : Int16, c : Int16) in
            return SemigroupLaws.check(semigroup: Int16.productMonoid, a: a, b: b, c: c, eq: Int16.order)
        }
    }
    
    func testInt32SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : Int32, b : Int32, c : Int32) in
            return SemigroupLaws.check(semigroup: Int32.sumMonoid, a: a, b: b, c: c, eq: Int32.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : Int32, b : Int32, c : Int32) in
            return SemigroupLaws.check(semigroup: Int32.productMonoid, a: a, b: b, c: c, eq: Int32.order)
        }
    }
    
    func testInt64SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : Int64, b : Int64, c : Int64) in
            return SemigroupLaws.check(semigroup: Int64.sumMonoid, a: a, b: b, c: c, eq: Int64.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : Int64, b : Int64, c : Int64) in
            return SemigroupLaws.check(semigroup: Int64.productMonoid, a: a, b: b, c: c, eq: Int64.order)
        }
    }
    
    func testUIntSemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : UInt, b : UInt, c : UInt) in
            return SemigroupLaws.check(semigroup: UInt.sumMonoid, a: a, b: b, c: c, eq: UInt.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : UInt, b : UInt, c : UInt) in
            return SemigroupLaws.check(semigroup: UInt.productMonoid, a: a, b: b, c: c, eq: UInt.order)
        }
    }
    
    func testUInt8SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : UInt8, b : UInt8, c : UInt8) in
            return SemigroupLaws.check(semigroup: UInt8.sumMonoid, a: a, b: b, c: c, eq: UInt8.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : UInt8, b : UInt8, c : UInt8) in
            return SemigroupLaws.check(semigroup: UInt8.productMonoid, a: a, b: b, c: c, eq: UInt8.order)
        }
    }
    
    func testUInt16SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : UInt16, b : UInt16, c : UInt16) in
            return SemigroupLaws.check(semigroup: UInt16.sumMonoid, a: a, b: b, c: c, eq: UInt16.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : UInt16, b : UInt16, c : UInt16) in
            return SemigroupLaws.check(semigroup: UInt16.productMonoid, a: a, b: b, c: c, eq: UInt16.order)
        }
    }
    
    func testUInt32SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : UInt32, b : UInt32, c : UInt32) in
            return SemigroupLaws.check(semigroup: UInt32.sumMonoid, a: a, b: b, c: c, eq: UInt32.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : UInt32, b : UInt32, c : UInt32) in
            return SemigroupLaws.check(semigroup: UInt32.productMonoid, a: a, b: b, c: c, eq: UInt32.order)
        }
    }
    
    func testUInt64SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a : UInt64, b : UInt64, c : UInt64) in
            return SemigroupLaws.check(semigroup: UInt64.sumMonoid, a: a, b: b, c: c, eq: UInt64.order)
        }
        
        property("Product semigroup laws") <- forAll { (a : UInt64, b : UInt64, c : UInt64) in
            return SemigroupLaws.check(semigroup: UInt64.productMonoid, a: a, b: b, c: c, eq: UInt64.order)
        }
    }
    
    func testIntMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Int) in
            return MonoidLaws.check(monoid: Int.sumMonoid, a: a, eq: Int.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Int) in
            return MonoidLaws.check(monoid: Int.productMonoid, a: a, eq: Int.order)
        }
    }
    
    func testInt8MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Int8) in
            return MonoidLaws.check(monoid: Int8.sumMonoid, a: a, eq: Int8.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Int8) in
            return MonoidLaws.check(monoid: Int8.productMonoid, a: a, eq: Int8.order)
        }
    }
    
    func testInt16MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Int16) in
            return MonoidLaws.check(monoid: Int16.sumMonoid, a: a, eq: Int16.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Int16) in
            return MonoidLaws.check(monoid: Int16.productMonoid, a: a, eq: Int16.order)
        }
    }
    
    func testInt32MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Int32) in
            return MonoidLaws.check(monoid: Int32.sumMonoid, a: a, eq: Int32.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Int32) in
            return MonoidLaws.check(monoid: Int32.productMonoid, a: a, eq: Int32.order)
        }
    }
    
    func testInt64MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Int64) in
            return MonoidLaws.check(monoid: Int64.sumMonoid, a: a, eq: Int64.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Int64) in
            return MonoidLaws.check(monoid: Int64.productMonoid, a: a, eq: Int64.order)
        }
    }
    
    func testUIntMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : UInt) in
            return MonoidLaws.check(monoid: UInt.sumMonoid, a: a, eq: UInt.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : UInt) in
            return MonoidLaws.check(monoid: UInt.productMonoid, a: a, eq: UInt.order)
        }
    }
    
    func testUInt8MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : UInt8) in
            return MonoidLaws.check(monoid: UInt8.sumMonoid, a: a, eq: UInt8.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : UInt8) in
            return MonoidLaws.check(monoid: UInt8.productMonoid, a: a, eq: UInt8.order)
        }
    }
    
    func testUInt16MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : UInt16) in
            return MonoidLaws.check(monoid: UInt16.sumMonoid, a: a, eq: UInt16.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : UInt16) in
            return MonoidLaws.check(monoid: UInt16.productMonoid, a: a, eq: UInt16.order)
        }
    }
    
    func testUInt32MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : UInt32) in
            return MonoidLaws.check(monoid: UInt32.sumMonoid, a: a, eq: UInt32.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : UInt32) in
            return MonoidLaws.check(monoid: UInt32.productMonoid, a: a, eq: UInt32.order)
        }
    }
    
    func testUInt64MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : UInt64) in
            return MonoidLaws.check(monoid: UInt64.sumMonoid, a: a, eq: UInt64.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : UInt64) in
            return MonoidLaws.check(monoid: UInt64.productMonoid, a: a, eq: UInt64.order)
        }
    }
    
    func testFloatMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Float) in
            return MonoidLaws.check(monoid: Float.sumMonoid, a: a, eq: Float.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Float) in
            return MonoidLaws.check(monoid: Float.productMonoid, a: a, eq: Float.order)
        }
    }
    
    func testDoubleMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a : Double) in
            return MonoidLaws.check(monoid: Double.sumMonoid, a: a, eq: Double.order)
        }
        
        property("Product Monoid laws") <- forAll { (a : Double) in
            return MonoidLaws.check(monoid: Double.productMonoid, a: a, eq: Double.order)
        }
    }
}

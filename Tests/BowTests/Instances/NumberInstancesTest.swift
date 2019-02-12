import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class NumberInstancesTest: XCTestCase {

    func testIntEqLaws() {
        EquatableLaws<Int>.check()
    }
    
    func testIntOrderLaws() {
        ComparableLaws<Int>.check()
    }
    
    func testInt8EqLaws() {
        EquatableLaws<Int8>.check()
    }
    
    func testInt8OrderLaws() {
        ComparableLaws<Int8>.check()
    }
    
    func testInt16EqLaws() {
        EquatableLaws<Int16>.check()
    }
    
    func testInt16OrderLaws() {
        ComparableLaws<Int16>.check()
    }
    
    func testInt32EqLaws() {
        EquatableLaws<Int32>.check()
    }
    
    func testInt32OrderLaws() {
        ComparableLaws<Int32>.check()
    }
    
    func testInt64EqLaws() {
        EquatableLaws<Int64>.check()
    }
    
    func testInt64OrderLaws() {
        ComparableLaws<Int64>.check()
    }
    
    func testUIntEqLaws() {
        EquatableLaws<UInt>.check()
    }
    
    func testUIntOrderLaws() {
        ComparableLaws<UInt>.check()
    }
    
    func testUInt8EqLaws() {
        EquatableLaws<UInt8>.check()
    }
    
    func testUInt8OrderLaws() {
        ComparableLaws<UInt8>.check()
    }
    
    func testUInt16EqLaws() {
        EquatableLaws<UInt16>.check()
    }
    
    func testUInt16OrderLaws() {
        ComparableLaws<UInt16>.check()
    }
    
    func testUInt32EqLaws() {
        EquatableLaws<UInt32>.check()
    }
    
    func testUInt32OrderLaws() {
        ComparableLaws<UInt32>.check()
    }
    
    func testUInt64EqLaws() {
        EquatableLaws<UInt64>.check()
    }
    
    func testUInt64OrderLaws() {
        ComparableLaws<UInt64>.check()
    }
    
    func testFloatEqLaws() {
        EquatableLaws<Float>.check()
    }
    
    func testFloatOrderLaws() {
        ComparableLaws<Float>.check()
    }
    
    func testDoubleEqLaws() {
        EquatableLaws<Double>.check()
    }
    
    func testDoubleOrderLaws() {
        ComparableLaws<Double>.check()
    }
    
    func testIntSemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: Int, b: Int, c: Int) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testInt8SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: Int8, b: Int8, c: Int8) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testInt16SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: Int16, b: Int16, c: Int16) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testInt32SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: Int32, b: Int32, c: Int32) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testInt64SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: Int64, b: Int64, c: Int64) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testUIntSemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: UInt, b: UInt, c: UInt) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testUInt8SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: UInt8, b: UInt8, c: UInt8) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testUInt16SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: UInt16, b: UInt16, c: UInt16) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testUInt32SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: UInt32, b: UInt32, c: UInt32) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testUInt64SemigroupLaws() {
        property("Sum semigroup laws") <- forAll { (a: UInt64, b: UInt64, c: UInt64) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testIntMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Int) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testInt8MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Int8) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testInt16MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Int16) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testInt32MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Int32) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testInt64MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Int64) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testUIntMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: UInt) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testUInt8MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: UInt8) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testUInt16MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: UInt16) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testUInt32MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: UInt32) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testUInt64MonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: UInt64) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testFloatMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Float) in
            return MonoidLaws.check(a: a)
        }
    }
    
    func testDoubleMonoidLaws() {
        property("Sum Monoid laws") <- forAll { (a: Double) in
            return MonoidLaws.check(a: a)
        }
    }
}

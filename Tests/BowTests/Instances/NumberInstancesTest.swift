import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

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
        SemigroupLaws<Int>.check()
    }
    
    func testInt8SemigroupLaws() {
        SemigroupLaws<Int8>.check()
    }
    
    func testInt16SemigroupLaws() {
        SemigroupLaws<Int16>.check()
    }
    
    func testInt32SemigroupLaws() {
        SemigroupLaws<Int32>.check()
    }
    
    func testInt64SemigroupLaws() {
        SemigroupLaws<Int64>.check()
    }
    
    func testUIntSemigroupLaws() {
        SemigroupLaws<UInt>.check()
    }
    
    func testUInt8SemigroupLaws() {
        SemigroupLaws<UInt8>.check()
    }
    
    func testUInt16SemigroupLaws() {
        SemigroupLaws<UInt16>.check()
    }
    
    func testUInt32SemigroupLaws() {
        SemigroupLaws<UInt32>.check()
    }
    
    func testUInt64SemigroupLaws() {
        SemigroupLaws<UInt64>.check()
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

import XCTest
import BowLaws
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
        MonoidLaws<Int>.check()
    }
    
    func testInt8MonoidLaws() {
        MonoidLaws<Int8>.check()
    }
    
    func testInt16MonoidLaws() {
        MonoidLaws<Int16>.check()
    }
    
    func testInt32MonoidLaws() {
        MonoidLaws<Int32>.check()
    }
    
    func testInt64MonoidLaws() {
        MonoidLaws<Int64>.check()
    }
    
    func testUIntMonoidLaws() {
        MonoidLaws<UInt>.check()
    }
    
    func testUInt8MonoidLaws() {
        MonoidLaws<UInt8>.check()
    }
    
    func testUInt16MonoidLaws() {
        MonoidLaws<UInt16>.check()
    }
    
    func testUInt32MonoidLaws() {
        MonoidLaws<UInt32>.check()
    }
    
    func testUInt64MonoidLaws() {
        MonoidLaws<UInt64>.check()
    }
    
    func testFloatMonoidLaws() {
        MonoidLaws<Float>.check()
    }
    
    func testDoubleMonoidLaws() {
        MonoidLaws<Double>.check()
    }

    func testIntSemiringLaws() {
        SemiringLaws<Int>.check()
    }

    func testInt8SemiringLaws() {
        SemiringLaws<Int8>.check()
    }

    func testInt16SemiringLaws() {
        SemiringLaws<Int16>.check()
    }

    func testInt32SemiringLaws() {
        SemiringLaws<Int32>.check()
    }

    func testInt64SemiringLaws() {
        SemiringLaws<Int64>.check()
    }
    
    func testUIntSemiringLaws() {
        SemiringLaws<UInt>.check()
    }

    func testUInt8SemiringLaws() {
        SemiringLaws<UInt8>.check()
    }

    func testUInt16SemiringLaws() {
        SemiringLaws<UInt16>.check()
    }

    func testUInt32SemiringLaws() {
        SemiringLaws<UInt32>.check()
    }

    func testUInt64SemiringLaws() {
        SemiringLaws<UInt64>.check()
    }
}

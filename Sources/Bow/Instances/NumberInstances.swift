import Foundation

/// Instance of `Semigroup` for `Int`. Uses sum as combination of elements.
extension Int: Semigroup {
    public func combine(_ other: Int) -> Int {
        return self + other
    }
}

/// Instance of `Monoid` for `Int`. Uses sum as combination of elements and zero as empty element.
extension Int: Monoid {
    public static func empty() -> Int {
        return 0
    }
}

/// Instance of `Semiring` for `Int`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension Int: Semiring {
    public func multiply(_ other: Int) -> Int {
        return self * other
    }
    
    public static func one() -> Int {
        return 1
    }
}

/// Instance of `Semigroup` for `Int8`. Uses sum as combination of elements.
extension Int8: Semigroup {
    public func combine(_ other: Int8) -> Int8 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `Int8`. Uses sum as combination of elements and zero as empty element.
extension Int8: Monoid {
    public static func empty() -> Int8 {
        return 0
    }
}

/// Instance of `Semiring` for `Int8`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension Int8: Semiring {
    public func multiply(_ other: Int8) -> Int8 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> Int8 {
        return 1
    }
}

/// Instance of `Semigroup` for `Int16`. Uses sum as combination of elements.
extension Int16: Semigroup {
    public func combine(_ other: Int16) -> Int16 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `Int16`. Uses sum as combination of elements and zero as empty element.
extension Int16: Monoid {
    public static func empty() -> Int16 {
        return 0
    }
}

/// Instance of `Semiring` for `Int16`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension Int16: Semiring {
    public func multiply(_ other: Int16) -> Int16 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> Int16 {
        return 1
    }
}

/// Instance of `Semigroup` for `Int32`. Uses sum as combination of elements.
extension Int32: Semigroup {
    public func combine(_ other: Int32) -> Int32 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `Int32`. Uses sum as combination of elements and zero as empty element.
extension Int32: Monoid {
    public static func empty() -> Int32 {
        return 0
    }
}

/// Instance of `Semiring` for `Int32`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension Int32: Semiring {
    public func multiply(_ other: Int32) -> Int32 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> Int32 {
        return 1
    }
}

/// Instance of `Semigroup` for `Int64`. Uses sum as combination of elements.
extension Int64: Semigroup {
    public func combine(_ other: Int64) -> Int64 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `Int64`. Uses sum as combination of elements and zero as empty element.
extension Int64: Monoid {
    public static func empty() -> Int64 {
        return 0
    }
}

/// Instance of `Semiring` for `Int64`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension Int64: Semiring {
    public func multiply(_ other: Int64) -> Int64 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> Int64 {
        return 1
    }
}

/// Instance of `Semigroup` for `UInt`. Uses sum as combination of elements.
extension UInt: Semigroup {
    public func combine(_ other: UInt) -> UInt {
        return self + other
    }
}

/// Instance of `Monoid` for `UInt`. Uses sum as combination of elements and zero as empty element.
extension UInt: Monoid {
    public static func empty() -> UInt {
        return 0
    }
}

/// Instance of `Semiring` for `UInt`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension UInt: Semiring {
    public func multiply(_ other: UInt) -> UInt {
        return self * other
    }
    
    public static func one() -> UInt {
        return 1
    }
}

/// Instance of `Semigroup` for `UInt8`. Uses sum as combination of elements.
extension UInt8: Semigroup {
    public func combine(_ other: UInt8) -> UInt8 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `UInt8`. Uses sum as combination of elements and zero as empty element.
extension UInt8: Monoid {
    public static func empty() -> UInt8 {
        return 0
    }
}

/// Instance of `Semiring` for `UInt8`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension UInt8: Semiring {
    public func multiply(_ other: UInt8) -> UInt8 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> UInt8 {
        return 1
    }
}

/// Instance of `Semigroup` for `UInt16`. Uses sum as combination of elements.
extension UInt16: Semigroup {
    public func combine(_ other: UInt16) -> UInt16 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `UInt16`. Uses sum as combination of elements and zero as empty element.
extension UInt16: Monoid {
    public static func empty() -> UInt16 {
        return 0
    }
}

/// Instance of `Semiring` for `UInt16`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension UInt16: Semiring {
    public func multiply(_ other: UInt16) -> UInt16 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> UInt16 {
        return 1
    }
}

/// Instance of `Semigroup` for `UInt32`. Uses sum as combination of elements.
extension UInt32: Semigroup {
    public func combine(_ other: UInt32) -> UInt32 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `UInt32`. Uses sum as combination of elements and zero as empty element.
extension UInt32: Monoid {
    public static func empty() -> UInt32 {
        return 0
    }
}

/// Instance of `Semiring` for `UInt32`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension UInt32: Semiring {
    public func multiply(_ other: UInt32) -> UInt32 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> UInt32 {
        return 1
    }
}

/// Instance of `Semigroup` for `UInt64`. Uses sum as combination of elements.
extension UInt64: Semigroup {
    public func combine(_ other: UInt64) -> UInt64 {
        return self.addingReportingOverflow(other).partialValue
    }
}

/// Instance of `Monoid` for `UInt64`. Uses sum as combination of elements and zero as empty element.
extension UInt64: Monoid {
    public static func empty() -> UInt64 {
        return 0
    }
}

/// Instance of `Semiring` for `UInt64`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension UInt64: Semiring {
    public func multiply(_ other: UInt64) -> UInt64 {
        return self.multipliedReportingOverflow(by: other).partialValue
    }
    
    public static func one() -> UInt64 {
        return 1
    }
}

/// Instance of `Semigroup` for `Float`. Uses sum as combination of elements.
extension Float: Semigroup {
    public func combine(_ other: Float) -> Float {
        return self + other
    }
}

/// Instance of `Monoid` for `Float`. Uses sum as combination of elements and zero as empty element.
extension Float: Monoid {
    public static func empty() -> Float {
        return 0
    }
}

/// Instance of `Semiring` for `Float`. Uses product (`*`) as multiplication of elements and `1` as one element.
extension Float: Semiring {
    public func multiply(_ other: Float) -> Float {
        return self * other
    }
    
    public static func one() -> Float {
        return 1
    }
}

/// Instance of `Semigroup` for `Double`. Uses addition as combination of elements.
extension Double: Semigroup {
    public func combine(_ other: Double) -> Double {
        return self + other
    }
}

/// Instance of `Monoid` for `Double`. Uses sum as combination of elements and zero as empty element.
extension Double: Monoid {
    public static func empty() -> Double {
        return 0
    }
}

/// Instance of `Semiring` for `Double`. Uses addition as multiplication of elements and `1` as one element.
extension Double: Semiring {
    public func multiply(_ other: Double) -> Double {
        return self * other
    }
    
    public static func one() -> Double {
        return 1
    }
}

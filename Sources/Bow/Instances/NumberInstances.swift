import Foundation

extension Int: Semigroup {
    public func combine(_ other: Int) -> Int {
        return self + other
    }
}

extension Int: Monoid {
    public static func empty() -> Int {
        return 0
    }
}

extension Int8: Semigroup {
    public func combine(_ other: Int8) -> Int8 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension Int8: Monoid {
    public static func empty() -> Int8 {
        return 0
    }
}

extension Int16: Semigroup {
    public func combine(_ other: Int16) -> Int16 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension Int16: Monoid {
    public static func empty() -> Int16 {
        return 0
    }
}

extension Int32: Semigroup {
    public func combine(_ other: Int32) -> Int32 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension Int32: Monoid {
    public static func empty() -> Int32 {
        return 0
    }
}

extension Int64: Semigroup {
    public func combine(_ other: Int64) -> Int64 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension Int64: Monoid {
    public static func empty() -> Int64 {
        return 0
    }
}




extension UInt: Semigroup {
    public func combine(_ other: UInt) -> UInt {
        return self + other
    }
}

extension UInt: Monoid {
    public static func empty() -> UInt {
        return 0
    }
}

extension UInt8: Semigroup {
    public func combine(_ other: UInt8) -> UInt8 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension UInt8: Monoid {
    public static func empty() -> UInt8 {
        return 0
    }
}

extension UInt16: Semigroup {
    public func combine(_ other: UInt16) -> UInt16 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension UInt16: Monoid {
    public static func empty() -> UInt16 {
        return 0
    }
}

extension UInt32: Semigroup {
    public func combine(_ other: UInt32) -> UInt32 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension UInt32: Monoid {
    public static func empty() -> UInt32 {
        return 0
    }
}

extension UInt64: Semigroup {
    public func combine(_ other: UInt64) -> UInt64 {
        return self.addingReportingOverflow(other).partialValue
    }
}

extension UInt64: Monoid {
    public static func empty() -> UInt64 {
        return 0
    }
}

extension Float: Semigroup {
    public func combine(_ other: Float) -> Float {
        return self + other
    }
}

extension Float: Monoid {
    public static func empty() -> Float {
        return 0
    }
}

extension Double: Semigroup {
    public func combine(_ other: Double) -> Double {
        return self + other
    }
}

extension Double: Monoid {
    public static func empty() -> Double {
        return 0
    }
}

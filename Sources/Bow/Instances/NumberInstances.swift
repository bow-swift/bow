import Foundation

// MARK: Int instances

public extension Int {
    /**
     Instance of `Semigroup` for the `Int` primitive type, with sum as combination method.
     */
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Int
        
        public func combine(_ a : Int, _ b : Int) -> Int {
            return a + b
        }
    }

    /**
     Instance of `Monoid` for the `Int` primitive type, with sum as combination method.
     */
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Int {
            return 0
        }
    }

    /**
     Instance of `Semigroup` for the `Int` primitive type, with product as combination method.
     */
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Int
        
        public func combine(_ a : Int, _ b : Int) -> Int {
            return a * b
        }
    }

    /**
     Instance of `Monoid` for the `Int` primitive type, with product as combination method.
     */
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Int {
            return 1
        }
    }

    /**
     Instance of `Eq` for the `Int` primitive type.
     */
    public class EqInstance : Eq {
        public typealias A = Int
        
        public func eqv(_ a: Int, _ b: Int) -> Bool {
            return a == b
        }
    }

    /**
     Instance of `Order` for the `Int` primitive type.
     */
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Int, _ b: Int) -> Int {
            return a - b
        }
    }
    
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : SumSemigroupInstance {
        return SumSemigroupInstance()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : SumMonoidInstance {
        return SumMonoidInstance()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : ProductSemigroupInstance {
        return ProductSemigroupInstance()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : ProductMonoidInstance {
        return ProductMonoidInstance()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : EqInstance {
        return EqInstance()
    }
    
    /// Provides an instance of `Order`.
    public static var order : OrderInstance {
        return OrderInstance()
    }
}

// MARK: Int8 instances

/**
 Instance of `Semigroup` for the `Int8` primitive type, with sum as combination method.
 */
public class Int8SumSemigroup : Semigroup {
    public typealias A = Int8
    
    public func combine(_ a : Int8, _ b : Int8) -> Int8 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int8` primitive type, with sum as combination method.
 */
public class Int8SumMonoid : Int8SumSemigroup, Monoid {
    public var empty : Int8 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `Int8` primitive type, with product as combination method.
 */
public class Int8ProductSemigroup : Semigroup {
    public typealias A = Int8
    
    public func combine(_ a : Int8, _ b : Int8) -> Int8 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int8` primitive type, with product as combination method.
 */
public class Int8ProductMonoid : Int8ProductSemigroup, Monoid {
    public var empty : Int8 {
        return 1
    }
}

/**
 Instance of `Eq` for the `Int8` primitive type.
 */
public class Int8Eq : Eq {
    public typealias A = Int8
    
    public func eqv(_ a: Int8, _ b: Int8) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `Int8` primitive type.
 */
public class Int8Order : Int8Eq, Order {
    public func compare(_ a: Int8, _ b: Int8) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int8 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : Int8SumSemigroup {
        return Int8SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : Int8SumMonoid {
        return Int8SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : Int8ProductSemigroup {
        return Int8ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : Int8ProductMonoid {
        return Int8ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : Int8Eq {
        return Int8Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : Int8Order {
        return Int8Order()
    }
}

// MARK: Int16 instances

/**
 Instance of `Semigroup` for the `Int16` primitive type, with sum as combination method.
 */
public class Int16SumSemigroup : Semigroup {
    public typealias A = Int16
    
    public func combine(_ a : Int16, _ b : Int16) -> Int16 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int16` primitive type, with sum as combination method.
 */
public class Int16SumMonoid : Int16SumSemigroup, Monoid {
    public var empty : Int16 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `Int16` primitive type, with product as combination method.
 */
public class Int16ProductSemigroup : Semigroup {
    public typealias A = Int16
    
    public func combine(_ a : Int16, _ b : Int16) -> Int16 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int16` primitive type, with product as combination method.
 */
public class Int16ProductMonoid : Int16ProductSemigroup, Monoid {
    public var empty : Int16 {
        return 1
    }
}

/**
 Instance of `Eq` for the `Int16` primitive type.
 */
public class Int16Eq : Eq {
    public typealias A = Int16
    
    public func eqv(_ a: Int16, _ b: Int16) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `Int16` primitive type.
 */
public class Int16Order : Int16Eq, Order {
    public func compare(_ a: Int16, _ b: Int16) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int16 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : Int16SumSemigroup {
        return Int16SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : Int16SumMonoid {
        return Int16SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : Int16ProductSemigroup {
        return Int16ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : Int16ProductMonoid {
        return Int16ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : Int16Eq {
        return Int16Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : Int16Order {
        return Int16Order()
    }
}

// MARK: Int32 instances

/**
 Instance of `Semigroup` for the `Int32` primitive type, with sum as combination method.
 */
public class Int32SumSemigroup : Semigroup {
    public typealias A = Int32
    
    public func combine(_ a : Int32, _ b : Int32) -> Int32 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int32` primitive type, with sum as combination method.
 */
public class Int32SumMonoid : Int32SumSemigroup, Monoid {
    public var empty : Int32 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `Int32` primitive type, with product as combination method.
 */
public class Int32ProductSemigroup : Semigroup {
    public typealias A = Int32
    
    public func combine(_ a : Int32, _ b : Int32) -> Int32 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int32` primitive type, with product as combination method.
 */
public class Int32ProductMonoid : Int32ProductSemigroup, Monoid {
    public var empty : Int32 {
        return 1
    }
}

/**
 Instance of `Eq` for the `Int32` primitive type.
 */
public class Int32Eq : Eq {
    public typealias A = Int32
    
    public func eqv(_ a: Int32, _ b: Int32) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `Int32` primitive type.
 */
public class Int32Order : Int32Eq, Order {
    public func compare(_ a: Int32, _ b: Int32) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int32 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : Int32SumSemigroup {
        return Int32SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : Int32SumMonoid {
        return Int32SumMonoid()
    }

    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : Int32ProductSemigroup {
        return Int32ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : Int32ProductMonoid {
        return Int32ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : Int32Eq {
        return Int32Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : Int32Order {
        return Int32Order()
    }
}

// MARK: Int64 instances

/**
 Instance of `Semigroup` for the `Int64` primitive type, with sum as combination method.
 */
public class Int64SumSemigroup : Semigroup {
    public typealias A = Int64
    
    public func combine(_ a : Int64, _ b : Int64) -> Int64 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int64` primitive type, with sum as combination method.
 */
public class Int64SumMonoid : Int64SumSemigroup, Monoid {
    public var empty : Int64 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `Int64` primitive type, with product as combination method.
 */
public class Int64ProductSemigroup : Semigroup {
    public typealias A = Int64
    
    public func combine(_ a : Int64, _ b : Int64) -> Int64 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `Int64` primitive type, with product as combination method.
 */
public class Int64ProductMonoid : Int64ProductSemigroup, Monoid {
    public var empty : Int64 {
        return 1
    }
}

/**
 Instance of `Eq` for the `Int64` primitive type.
 */
public class Int64Eq : Eq {
    public typealias A = Int64
    
    public func eqv(_ a: Int64, _ b: Int64) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `Int64` primitive type.
 */
public class Int64Order : Int64Eq, Order {
    public func compare(_ a: Int64, _ b: Int64) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int64 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : Int64SumSemigroup {
        return Int64SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : Int64SumMonoid {
        return Int64SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : Int64ProductSemigroup {
        return Int64ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : Int64ProductMonoid {
        return Int64ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : Int64Eq {
        return Int64Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : Int64Order {
        return Int64Order()
    }
}

// MARK: UInt instances

/**
 Instance of `Semigroup` for the `UInt` primitive type, with sum as combination method.
 */
public class UIntSumSemigroup : Semigroup {
    public typealias A = UInt
    
    public func combine(_ a : UInt, _ b : UInt) -> UInt {
        return a + b
    }
}

/**
 Instance of `Monoid` for the `UInt` primitive type, with sum as combination method.
 */
public class UIntSumMonoid : UIntSumSemigroup, Monoid {
    public var empty : UInt {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `UInt` primitive type, with product as combination method.
 */
public class UIntProductSemigroup : Semigroup {
    public typealias A = UInt
    
    public func combine(_ a : UInt, _ b : UInt) -> UInt {
        return a * b
    }
}

/**
 Instance of `Monoid` for the `UInt` primitive type, with product as combination method.
 */
public class UIntProductMonoid : UIntProductSemigroup, Monoid {
    public var empty : UInt {
        return 1
    }
}

/**
 Instance of `Eq` for the `UInt` primitive type.
 */
public class UIntEq : Eq {
    public typealias A = UInt
    
    public func eqv(_ a: UInt, _ b: UInt) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `UInt` primitive type.
 */
public class UIntOrder : UIntEq, Order {
    public func compare(_ a: UInt, _ b: UInt) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : UIntSumSemigroup {
        return UIntSumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : UIntSumMonoid {
        return UIntSumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : UIntProductSemigroup {
        return UIntProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : UIntProductMonoid {
        return UIntProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : UIntEq {
        return UIntEq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : UIntOrder {
        return UIntOrder()
    }
}

// MARK: UInt8 instances

/**
 Instance of `Semigroup` for the `UInt8` primitive type, with sum as combination method.
 */
public class UInt8SumSemigroup : Semigroup {
    public typealias A = UInt8
    
    public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt8` primitive type, with sum as combination method.
 */
public class UInt8SumMonoid : UInt8SumSemigroup, Monoid {
    public var empty : UInt8 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `UInt8` primitive type, with product as combination method.
 */
public class UInt8ProductSemigroup : Semigroup {
    public typealias A = UInt8
    
    public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt8` primitive type, with product as combination method.
 */
public class UInt8ProductMonoid : UInt8ProductSemigroup, Monoid {
    public var empty : UInt8 {
        return 1
    }
}

/**
 Instance of `Eq` for the `UInt8` primitive type.
 */
public class UInt8Eq : Eq {
    public typealias A = UInt8
    
    public func eqv(_ a: UInt8, _ b: UInt8) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `UInt8` primitive type.
 */
public class UInt8Order : UInt8Eq, Order {
    public func compare(_ a: UInt8, _ b: UInt8) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt8 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : UInt8SumSemigroup {
        return UInt8SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : UInt8SumMonoid {
        return UInt8SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : UIntProductSemigroup {
        return UIntProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : UInt8ProductMonoid {
        return UInt8ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : UInt8Eq {
        return UInt8Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : UInt8Order {
        return UInt8Order()
    }
}

// MARK: UInt16 instances

/**
 Instance of `Semigroup` for the `UInt16` primitive type, with sum as combination method.
 */
public class UInt16SumSemigroup : Semigroup {
    public typealias A = UInt16
    
    public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt16` primitive type, with sum as combination method.
 */
public class UInt16SumMonoid : UInt16SumSemigroup, Monoid {
    public var empty : UInt16 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `UInt16` primitive type, with product as combination method.
 */
public class UInt16ProductSemigroup : Semigroup {
    public typealias A = UInt16
    
    public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt16` primitive type, with product as combination method.
 */
public class UInt16ProductMonoid : UInt16ProductSemigroup, Monoid {
    public var empty : UInt16 {
        return 1
    }
}

/**
 Instance of `Eq` for the `UInt16` primitive type.
 */
public class UInt16Eq : Eq {
    public typealias A = UInt16
    
    public func eqv(_ a: UInt16, _ b: UInt16) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `UInt16` primitive type.
 */
public class UInt16Order : UInt16Eq, Order {
    public func compare(_ a: UInt16, _ b: UInt16) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt16 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : UInt16SumSemigroup {
        return UInt16SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : UInt16SumMonoid {
        return UInt16SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : UInt16ProductSemigroup {
        return UInt16ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : UInt16ProductMonoid {
        return UInt16ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : UInt16Eq {
        return UInt16Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : UInt16Order {
        return UInt16Order()
    }
}

// MARK: UInt32 instances

/**
 Instance of `Semigroup` for the `UInt32` primitive type, with sum as combination method.
 */
public class UInt32SumSemigroup : Semigroup {
    public typealias A = UInt32
    
    public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt32` primitive type, with sum as combination method.
 */
public class UInt32SumMonoid : UInt32SumSemigroup, Monoid {
    public var empty : UInt32 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `UInt32` primitive type, with product as combination method.
 */
public class UInt32ProductSemigroup : Semigroup {
    public typealias A = UInt32
    
    public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt32` primitive type, with product as combination method.
 */
public class UInt32ProductMonoid : UInt32ProductSemigroup, Monoid {
    public var empty : UInt32 {
        return 1
    }
}

/**
 Instance of `Eq` for the `UInt32` primitive type.
 */
public class UInt32Eq : Eq {
    public typealias A = UInt32
    
    public func eqv(_ a: UInt32, _ b: UInt32) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `UInt32` primitive type.
 */
public class UInt32Order : UInt32Eq, Order {
    public func compare(_ a: UInt32, _ b: UInt32) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt32 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : UInt32SumSemigroup {
        return UInt32SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : UInt32SumMonoid {
        return UInt32SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : UInt32ProductSemigroup {
        return UInt32ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : UInt32ProductMonoid {
        return UInt32ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : UInt32Eq {
        return UInt32Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : UInt32Order {
        return UInt32Order()
    }
}

// MARK: UInt64 instances

/**
 Instance of `Semigroup` for the `UInt64` primitive type, with sum as combination method.
 */
public class UInt64SumSemigroup : Semigroup {
    public typealias A = UInt64
    
    public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
        return a.addingReportingOverflow(b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt64` primitive type, with sum as combination method.
 */
public class UInt64SumMonoid : UInt64SumSemigroup, Monoid {
    public var empty : UInt64 {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `UInt64` primitive type, with product as combination method.
 */
public class UInt64ProductSemigroup : Semigroup {
    public typealias A = UInt64
    
    public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

/**
 Instance of `Monoid` for the `UInt64` primitive type, with product as combination method.
 */
public class UInt64ProductMonoid : UInt64ProductSemigroup, Monoid {
    public var empty : UInt64 {
        return 1
    }
}

/**
 Instance of `Eq` for the `UInt64` primitive type.
 */
public class UInt64Eq : Eq {
    public typealias A = UInt64
    
    public func eqv(_ a: UInt64, _ b: UInt64) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for the `UInt64` primitive type.
 */
public class UInt64Order : UInt64Eq, Order {
    public func compare(_ a: UInt64, _ b: UInt64) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt64 {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : UInt64SumSemigroup {
        return UInt64SumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : UInt64SumMonoid {
        return UInt64SumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : UInt64ProductSemigroup {
        return UInt64ProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : UInt64ProductMonoid {
        return UInt64ProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : UInt64Eq {
        return UInt64Eq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : UInt64Order {
        return UInt64Order()
    }
}

// MARK: Float instances

/**
 Instance of `Semigroup` for the `Float` primitive type, with sum as combination method.
 */
public class FloatSumSemigroup : Semigroup {
    public typealias A = Float
    
    public func combine(_ a : Float, _ b : Float) -> Float {
        return a + b
    }
}

/**
 Instance of `Monoid` for the `Float` primitive type, with sum as combination method.
 */
public class FloatSumMonoid : FloatSumSemigroup, Monoid {
    public var empty : Float {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `Float` primitive type, with product as combination method.
 */
public class FloatProductSemigroup : Semigroup {
    public typealias A = Float
    
    public func combine(_ a : Float, _ b : Float) -> Float {
        return a * b
    }
}

/**
 Instance of `Monoid` for the `Float` primitive type, with product as combination method.
 */
public class FloatProductMonoid : FloatProductSemigroup, Monoid {
    public var empty : Float {
        return 1
    }
}

/**
 Instance of `Eq` for the `Float` primitive type.
 */
public class FloatEq : Eq {
    public typealias A = Float
    
    public func eqv(_ a: Float, _ b: Float) -> Bool {
        return a.isEqual(to: b)
    }
}

/**
 Instance of `Order` for the `Float` primitive type.
 */
public class FloatOrder : FloatEq, Order {
    public func compare(_ a: Float, _ b: Float) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension Float {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : FloatSumSemigroup {
        return FloatSumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : FloatSumMonoid {
        return FloatSumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : FloatProductSemigroup {
        return FloatProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : FloatProductMonoid {
        return FloatProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : FloatEq {
        return FloatEq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : FloatOrder {
        return FloatOrder()
    }
}

// MARK: Double instances

/**
 Instance of `Semigroup` for the `Double` primitive type, with sum as combination method.
 */
public class DoubleSumSemigroup : Semigroup {
    public typealias A = Double
    
    public func combine(_ a : Double, _ b : Double) -> Double {
        return a + b
    }
}

/**
 Instance of `Monoid` for the `Double` primitive type, with sum as combination method.
 */
public class DoubleSumMonoid : DoubleSumSemigroup, Monoid {
    public var empty : Double {
        return 0
    }
}

/**
 Instance of `Semigroup` for the `Double` primitive type, with product as combination method.
 */
public class DoubleProductSemigroup : Semigroup {
    public typealias A = Double
    
    public func combine(_ a : Double, _ b : Double) -> Double {
        return a * b
    }
}

/**
 Instance of `Monoid` for the `Double` primitive type, with product as combination method.
 */
public class DoubleProductMonoid : DoubleProductSemigroup, Monoid {
    public var empty : Double {
        return 1
    }
}

/**
 Instance of `Eq` for the `Double` primitive type.
 */
public class DoubleEq : Eq {
    public typealias A = Double
    
    public func eqv(_ a: Double, _ b: Double) -> Bool {
        return a.isEqual(to: b)
    }
}

/**
 Instance of `Order` for the `Double` primitive type.
 */
public class DoubleOrder : DoubleEq, Order {
    public func compare(_ a: Double, _ b: Double) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension Double {
    /// Provides an instance of `Semigroup`, with sum as combination method.
    public static var sumSemigroup : DoubleSumSemigroup {
        return DoubleSumSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with sum as combination method.
    public static var sumMonoid : DoubleSumMonoid {
        return DoubleSumMonoid()
    }
    
    /// Provides an instance of `Semigroup`, with product as combination method.
    public static var productSemigroup : DoubleProductSemigroup {
        return DoubleProductSemigroup()
    }
    
    /// Provides an instance of `Monoid`, with product as combination method.
    public static var productMonoid : DoubleProductMonoid {
        return DoubleProductMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : DoubleEq {
        return DoubleEq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : DoubleOrder {
        return DoubleOrder()
    }
}

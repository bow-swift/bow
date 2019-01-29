import Foundation

// MARK: Int instances

public extension Int {
    /// Instance of `Semigroup` for the `Int` primitive type, with sum as combination method.
    ///
    /// Use `Int.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Int
        
        public func combine(_ a : Int, _ b : Int) -> Int {
            return a + b
        }
    }

    /// Instance of `Monoid` for the `Int` primitive type, with sum as combination method.
    ///
    /// Use `Int.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Int {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `Int` primitive type, with product as combination method.
    ///
    /// Use `Int.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Int
        
        public func combine(_ a : Int, _ b : Int) -> Int {
            return a * b
        }
    }

    /// Instance of `Monoid` for the `Int` primitive type, with product as combination method.
    ///
    /// Use `Int.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Int {
            return 1
        }
    }

    /// Instance of `Eq` for the `Int` primitive type.
    ///
    /// Use `Int.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Int
        
        public func eqv(_ a: Int, _ b: Int) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `Int` primitive type.
    ///
    /// Use `Int.order` to obtain an instance of this type.
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
public extension Int8 {
    /// Instance of `Semigroup` for the `Int8` primitive type, with sum as combination method.
    ///
    /// Use `Int8.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Int8
        
        public func combine(_ a : Int8, _ b : Int8) -> Int8 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int8` primitive type, with sum as combination method.
    ///
    /// Use `Int8.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Int8 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `Int8` primitive type, with product as combination method.
    ///
    /// Use `Int8.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Int8
        
        public func combine(_ a : Int8, _ b : Int8) -> Int8 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int8` primitive type, with product as combination method.
    ///
    /// Use `Int8.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Int8 {
            return 1
        }
    }

    /// Instance of `Eq` for the `Int8` primitive type.
    ///
    /// Use `Int8.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Int8
        
        public func eqv(_ a: Int8, _ b: Int8) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `Int8` primitive type.
    ///
    /// Use `Int8.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Int8, _ b: Int8) -> Int {
            return Int(a) - Int(b)
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

// MARK: Int16 instances
public extension Int16 {
    /// Instance of `Semigroup` for the `Int16` primitive type, with sum as combination method.
    ///
    /// Use `Int16.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Int16
        
        public func combine(_ a : Int16, _ b : Int16) -> Int16 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int16` primitive type, with sum as combination method.
    ///
    /// Use `Int16.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Int16 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `Int16` primitive type, with product as combination method.
    ///
    /// Use `Int16.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Int16
        
        public func combine(_ a : Int16, _ b : Int16) -> Int16 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int16` primitive type, with product as combination method.
    ///
    /// Use `Int16.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Int16 {
            return 1
        }
    }

    /// Instance of `Eq` for the `Int16` primitive type.
    ///
    /// Use `Int16.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Int16
        
        public func eqv(_ a: Int16, _ b: Int16) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `Int16` primitive type.
    ///
    /// Use `Int16.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Int16, _ b: Int16) -> Int {
            return Int(a) - Int(b)
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

// MARK: Int32 instances
public extension Int32 {
    /// Instance of `Semigroup` for the `Int32` primitive type, with sum as combination method.
    ///
    /// Use `Int32.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Int32
        
        public func combine(_ a : Int32, _ b : Int32) -> Int32 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int32` primitive type, with sum as combination method.
    ///
    /// Use `Int32.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Int32 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `Int32` primitive type, with product as combination method.
    ///
    /// Use `Int32.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Int32
        
        public func combine(_ a : Int32, _ b : Int32) -> Int32 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int32` primitive type, with product as combination method.
    ///
    /// Use `Int32.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Int32 {
            return 1
        }
    }

    /// Instance of `Eq` for the `Int32` primitive type.
    ///
    /// Use `Int32.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Int32
        
        public func eqv(_ a: Int32, _ b: Int32) -> Bool {
            return a == b
        }
    }

    ///Instance of `Order` for the `Int32` primitive type.
    ///
    /// Use `Int32.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Int32, _ b: Int32) -> Int {
            return Int(a) - Int(b)
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

// MARK: Int64 instances
public extension Int64 {
    /// Instance of `Semigroup` for the `Int64` primitive type, with sum as combination method.
    ///
    /// Use `Int64.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Int64
        
        public func combine(_ a : Int64, _ b : Int64) -> Int64 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int64` primitive type, with sum as combination method.
    ///
    /// Use `Int64.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Int64 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `Int64` primitive type, with product as combination method.
    ///
    /// Use `Int64.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Int64
        
        public func combine(_ a : Int64, _ b : Int64) -> Int64 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `Int64` primitive type, with product as combination method.
    ///
    /// Use `Int64.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Int64 {
            return 1
        }
    }

    /// Instance of `Eq` for the `Int64` primitive type.
    ///
    /// Use `Int64.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Int64
        
        public func eqv(_ a: Int64, _ b: Int64) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `Int64` primitive type.
    ///
    /// Use `Int64.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Int64, _ b: Int64) -> Int {
            return Int(a) - Int(b)
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

// MARK: UInt instances
public extension UInt {
    /// Instance of `Semigroup` for the `UInt` primitive type, with sum as combination method.
    ///
    /// Use `UInt.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = UInt
        
        public func combine(_ a : UInt, _ b : UInt) -> UInt {
            return a + b
        }
    }

    /// Instance of `Monoid` for the `UInt` primitive type, with sum as combination method.
    ///
    /// Use `UInt.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : UInt {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `UInt` primitive type, with product as combination method.
    ///
    /// Use `UInt.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = UInt
        
        public func combine(_ a : UInt, _ b : UInt) -> UInt {
            return a * b
        }
    }

    /// Instance of `Monoid` for the `UInt` primitive type, with product as combination method.
    ///
    /// Use `UInt.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : UInt {
            return 1
        }
    }

    /// Instance of `Eq` for the `UInt` primitive type.
    ///
    /// Use `UInt.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = UInt
        
        public func eqv(_ a: UInt, _ b: UInt) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `UInt` primitive type.
    ///
    /// Use `UInt.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: UInt, _ b: UInt) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

// MARK: UInt8 instances
public extension UInt8 {
    /// Instance of `Semigroup` for the `UInt8` primitive type, with sum as combination method.
    ///
    /// Use `UInt8.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = UInt8
        
        public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt8` primitive type, with sum as combination method.
    ///
    /// Use `UInt8.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : UInt8 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `UInt8` primitive type, with product as combination method.
    ///
    /// Use `UInt8.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = UInt8
        
        public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt8` primitive type, with product as combination method.
    ///
    /// Use `UInt8.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : UInt8 {
            return 1
        }
    }

    /// Instance of `Eq` for the `UInt8` primitive type.
    ///
    /// Use `UInt8.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = UInt8
        
        public func eqv(_ a: UInt8, _ b: UInt8) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `UInt8` primitive type.
    ///
    /// Use `UInt8.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: UInt8, _ b: UInt8) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

// MARK: UInt16 instances
public extension UInt16 {
    /// Instance of `Semigroup` for the `UInt16` primitive type, with sum as combination method.
    ///
    /// Use `UInt16.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = UInt16
        
        public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt16` primitive type, with sum as combination method.
    ///
    /// Use `UInt16.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : UInt16 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `UInt16` primitive type, with product as combination method.
    ///
    /// Use `UInt16.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = UInt16
        
        public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt16` primitive type, with product as combination method.
    ///
    /// Use `UInt16.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : UInt16 {
            return 1
        }
    }

    /// Instance of `Eq` for the `UInt16` primitive type.
    ///
    /// Use `UInt16.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = UInt16
        
        public func eqv(_ a: UInt16, _ b: UInt16) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `UInt16` primitive type.
    ///
    /// Use `UInt16.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: UInt16, _ b: UInt16) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

// MARK: UInt32 instances
public extension UInt32 {
    /// Instance of `Semigroup` for the `UInt32` primitive type, with sum as combination method.
    ///
    /// Use `UInt32.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = UInt32
        
        public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt32` primitive type, with sum as combination method.
    ///
    /// Use `UInt32.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : UInt32 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `UInt32` primitive type, with product as combination method.
    ///
    /// Use `UInt32.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = UInt32
        
        public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt32` primitive type, with product as combination method.
    ///
    /// Use `UInt32.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : UInt32 {
            return 1
        }
    }

    /// Instance of `Eq` for the `UInt32` primitive type.
    ///
    /// Use `UInt32.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = UInt32
        
        public func eqv(_ a: UInt32, _ b: UInt32) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `UInt32` primitive type.
    ///
    /// Use `UInt32.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: UInt32, _ b: UInt32) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

// MARK: UInt64 instances
public extension UInt64 {
    /// Instance of `Semigroup` for the `UInt64` primitive type, with sum as combination method.
    ///
    /// Use `UInt64.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = UInt64
        
        public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
            return a.addingReportingOverflow(b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt64` primitive type, with sum as combination method.
    ///
    /// Use `UInt64.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : UInt64 {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `UInt64` primitive type, with product as combination method.
    ///
    /// Use `UInt64.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = UInt64
        
        public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
            return a.multipliedReportingOverflow(by: b).partialValue
        }
    }

    /// Instance of `Monoid` for the `UInt64` primitive type, with product as combination method.
    ///
    /// Use `UInt64.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : UInt64 {
            return 1
        }
    }

    /// Instance of `Eq` for the `UInt64` primitive type.
    ///
    /// Use `UInt64.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = UInt64
        
        public func eqv(_ a: UInt64, _ b: UInt64) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for the `UInt64` primitive type.
    ///
    /// Use `UInt64.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: UInt64, _ b: UInt64) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

// MARK: Float instances
public extension Float {
    /// Instance of `Semigroup` for the `Float` primitive type, with sum as combination method.
    ///
    /// Use `Float.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Float
        
        public func combine(_ a : Float, _ b : Float) -> Float {
            return a + b
        }
    }

    /// Instance of `Monoid` for the `Float` primitive type, with sum as combination method.
    ///
    /// Use `Float.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Float {
            return 0
        }
    }

    /// Instance of `Semigroup` for the `Float` primitive type, with product as combination method.
    ///
    /// Use `Float.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Float
        
        public func combine(_ a : Float, _ b : Float) -> Float {
            return a * b
        }
    }

    /// Instance of `Monoid` for the `Float` primitive type, with product as combination method.
    ///
    /// Use `Float.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Float {
            return 1
        }
    }

    /// Instance of `Eq` for the `Float` primitive type.
    ///
    /// Use `Float.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Float
        
        public func eqv(_ a: Float, _ b: Float) -> Bool {
            return a.isEqual(to: b)
        }
    }

    /// Instance of `Order` for the `Float` primitive type.
    ///
    /// Use `Float.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Float, _ b: Float) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

// MARK: Double instances
public extension Double {
    /// Instance of `Semigroup` for the `Double` primitive type, with sum as combination method.
    ///
    /// Use `Double.sumSemigroup` to obtain an instance of this type.
    public class SumSemigroupInstance : Semigroup {
        public typealias A = Double
        
        public func combine(_ a : Double, _ b : Double) -> Double {
            return a + b
        }
    }

    /// Instance of `Monoid` for the `Double` primitive type, with sum as combination method.
    ///
    /// Use `Double.sumMonoid` to obtain an instance of this type.
    public class SumMonoidInstance : SumSemigroupInstance, Monoid {
        public var empty : Double {
            return 0
        }
    }

    ///Instance of `Semigroup` for the `Double` primitive type, with product as combination method.
    ///
    /// Use `Double.productSemigroup` to obtain an instance of this type.
    public class ProductSemigroupInstance : Semigroup {
        public typealias A = Double
        
        public func combine(_ a : Double, _ b : Double) -> Double {
            return a * b
        }
    }

    /// Instance of `Monoid` for the `Double` primitive type, with product as combination method.
    ///
    /// Use `Double.productMonoid` to obtain an instance of this type.
    public class ProductMonoidInstance : ProductSemigroupInstance, Monoid {
        public var empty : Double {
            return 1
        }
    }

    /// Instance of `Eq` for the `Double` primitive type.
    ///
    /// Use `Double.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = Double
        
        public func eqv(_ a: Double, _ b: Double) -> Bool {
            return a.isEqual(to: b)
        }
    }

    /// Instance of `Order` for the `Double` primitive type.
    ///
    /// Use `Double.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: Double, _ b: Double) -> Int {
            if a < b {
                return -1
            } else if a > b {
                return 1
            }
            return 0
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

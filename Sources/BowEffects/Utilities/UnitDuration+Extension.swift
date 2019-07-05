//import Foundation
//
//public extension UnitDuration {
//    static var days: UnitDuration {
//        return UnitDuration(symbol: "days", converter: UnitConverterLinear(coefficient: 60 * 60 * 24))
//    }
//
//    static var milliseconds: UnitDuration {
//        return UnitDuration(symbol: "ms", converter: UnitConverterLinear(coefficient: 0.001))
//    }
//
//    static var microseconds: UnitDuration {
//        return UnitDuration(symbol: "µs", converter: UnitConverterLinear(coefficient: 0.000001))
//    }
//
//    static var nanoseconds: UnitDuration {
//        return UnitDuration(symbol: "ns", converter: UnitConverterLinear(coefficient: 0.000000001))
//    }
//
//    static var picoseconds: UnitDuration {
//        return UnitDuration(symbol: "ps", converter: UnitConverterLinear(coefficient: 0.000000000001))
//    }
//}
//
//public func *(lhs: Int, rhs: Measurement<UnitDuration>) -> Measurement<UnitDuration> {
//    return Measurement(value: rhs.value * Double(lhs), unit: rhs.unit)
//}
//
//public extension Measurement where UnitType == UnitDuration {
//    static var infinite = Measurement(value: Double.greatestFiniteMagnitude, unit: UnitDuration.days)
//}

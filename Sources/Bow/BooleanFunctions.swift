import Foundation

public func not(_ a : Bool) -> Bool {
    return !a
}

public func and(_ a : Bool, _ b : Bool) -> Bool {
    return a && b
}

public func or(_ a : Bool, _ b : Bool) -> Bool {
    return a || b
}

public func xor(_ a : Bool, _ b : Bool) -> Bool {
    return a != b
}

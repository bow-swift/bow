import Foundation

public protocol Show : Typeclass {
    associatedtype A
    
    func show(_ a : A) -> String
}

public extension CustomStringConvertible {
    public static func show() -> ShowCustomStringConvertible<Self> {
        return ShowCustomStringConvertible<Self>()
    }
}

public class ShowCustomStringConvertible<B> : Show where B : CustomStringConvertible{
    public typealias A = B
    
    public func show(_ a : B) -> String {
        return a.description
    }
}

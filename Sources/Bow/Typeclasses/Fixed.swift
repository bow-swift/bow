import Foundation

public protocol Fixed {
    associatedtype Witness
    associatedtype This

    static func fix<A>(_ value: Kind<Witness, A>) -> This
}

public extension Fixed {
    public static func fix<A>(_ value: Kind<Witness, A>) -> This {
        return value as! This
    }
}

public extension Kind {
    public func fix<T: Fixed>() -> T where T.Witness == F {
        return T.fix(self) as! T
    }
}


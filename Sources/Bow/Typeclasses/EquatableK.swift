import Foundation

public protocol EquatableK {
    static func eq<A: Equatable>(_ lhs: Kind<Self, A>, _ rhs: Kind<Self, A>) -> Bool
}

public extension Kind where F: EquatableK, A: Equatable {
    public func eq(_ rhs: Kind<F, A>) -> Bool {
        return F.eq(self, rhs)
    }
}

extension Kind: Equatable where F: EquatableK, A: Equatable {
    public static func ==(lhs: Kind<F, A>, rhs: Kind<F, A>) -> Bool {
        return F.eq(lhs, rhs)
    }
}

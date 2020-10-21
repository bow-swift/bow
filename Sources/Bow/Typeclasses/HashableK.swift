import Foundation



/// EquatableK provides capabilities to compute a hash value at the kind level.
public protocol HashableK: EquatableK {

    /// Hashes the essential components of a value wrapped by this kind, provided
    /// that the wrapped type conforms to `Hashable`.
    ///
    /// Implementations of this method must obey the following laws:
    ///
    /// 1. Coherence with equality
    ///
    ///         eq(fa1, fa2) -> fa1.hashValue == fa2.hashValue
    ///
    /// - Parameters:
    ///   - fa: A value wrapped by this kind.
    ///   - hasher: The hasher to use when combining the components of this instance.
    static func hash<A: Hashable>(_ fa: Kind<Self, A>, into hasher: inout Hasher)
}

extension Kind: Hashable where F: HashableK, A: Hashable {
    public func hash(into hasher: inout Hasher) {
        F.hash(self, into: &hasher)
    }
}

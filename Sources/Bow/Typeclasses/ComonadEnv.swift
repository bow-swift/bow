/// The ComonadEnv type class represents a Comonad that support a global environment that can be provided and transformed into a local environment.
public protocol ComonadEnv: Comonad {
    /// Type of the associated environment
    associatedtype E
    
    /// Gets the underlying global environment from the provided value.
    /// - Parameter wa: Value to obtain the environment from.
    /// - Returns: Global environment.
    static func ask<A>(_ wa: Kind<Self, A>) -> E
    
    /// Transforms the environment into a local one.
    ///
    /// - Parameters:
    ///   - wa: Value containing the environment.
    ///   - f: Transforming function.
    /// - Returns: A value with the transformed environment.
    static func local<A>(_ wa: Kind<Self, A>, _ f: @escaping (E) -> E) -> Kind<Self, A>
}

public extension ComonadEnv {
    /// Obtains a value that depends on the environment.
    ///
    /// - Parameters:
    ///   - wa: Value containing the environment.
    ///   - f: Function to obtain a value from the environment.
    /// - Returns: A value that depends on the environment.
    static func asks<A, EE>(_ wa: Kind<Self, A>, _ f: @escaping (E) -> EE) -> EE {
        f(ask(wa))
    }
}

// MARK: Syntax for ComonadEnv

public extension Kind where F: ComonadEnv {
    /// Gets the underlying global environment from this value.
    /// - Returns: Global environment.
    func ask() -> F.E {
        F.ask(self)
    }
    
    /// Obtains a value that depends on the environment.
    ///
    /// - Parameters:
    ///   - f: Function to obtain a value from the environment.
    /// - Returns: A value that depends on the environment.
    func asks<EE>(_ f: @escaping (F.E) -> EE) -> EE {
        F.asks(self, f)
    }
    
    /// Transforms the environment into a local one.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: A value with the transformed environment.
    func local(_ f: @escaping (F.E) -> F.E) -> Kind<F, A> {
        F.local(self, f)
    }
}

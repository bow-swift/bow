/// The ComonadStore type class represents those Comonads that support local position information.
public protocol ComonadStore: Comonad {
    /// Type of the position within the ComonadStore
    associatedtype S
    
    /// Obtains the current position of the store.
    /// - Parameter wa: Value from which the store is retrieved.
    /// - Returns: Current position.
    static func position<A>(_ wa: Kind<Self, A>) -> S
    
    /// Obtains the value stored in the provided position.
    ///
    /// - Parameters:
    ///   - wa: Store.
    ///   - s: Position within the Store.
    /// - Returns: Value stored in the provided position.
    static func peek<A>(_ wa: Kind<Self, A>, _ s: S) -> A
}

public extension ComonadStore {
    /// Obtains a value in a position relative to the current position.
    ///
    /// - Parameters:
    ///   - wa: Store.
    ///   - f: Function to compute the relative position.
    /// - Returns: Value located in a relative position to the current one.
    static func peeks<A>(_ wa: Kind<Self, A>, _ f: @escaping (S) -> S) -> A {
        peek(wa, f(position(wa)))
    }
    
    /// Moves to a new position.
    ///
    /// - Parameters:
    ///   - wa: Store.
    ///   - s: New position.
    /// - Returns: Store focused into the new position.
    static func seek<A>(_ wa: Kind<Self, A>, _ s: S) -> Kind<Self, A> {
        wa.coflatMap { fa in peek(fa, s) }
    }
    
    /// Moves to a new position relative to the current one.
    ///
    /// - Parameters:
    ///   - wa: Store.
    ///   - f: Function to compute the new position, relative to the current one.
    /// - Returns: Store focused into the new position.
    static func seeks<A>(_ wa: Kind<Self, A>, _ f: @escaping (S) -> S) -> Kind<Self, A> {
        wa.coflatMap { fa in peeks(fa, f) }
    }
    
    /// Extracts a collection of values from positions that depend on the current one.
    ///
    /// - Parameters:
    ///   - wa: Store.
    ///   - f: Effectful function computing new positions based on the current one.
    /// - Returns: A collection of values located a the specified positions.
    static func experiment<F: Functor, A>(_ wa: Kind<Self, A>, _ f: @escaping (S) -> Kind<F, S>) -> Kind<F, A> {
        F.map(f(position(wa))) { s in peek(wa, s) }
    }
}

// MARK: Syntax for ComonadStore

public extension Kind where F: ComonadStore {
    /// Obtains the current position of the store.
    var position: F.S {
        F.position(self)
    }
    
    /// Obtains the value stored in the provided position.
    ///
    /// - Parameters:
    ///   - s: Position within the Store.
    /// - Returns: Value stored in the provided position.
    func peek(_ s: F.S) -> A {
        F.peek(self, s)
    }
    
    /// Obtains a value in a position relative to the current position.
    ///
    /// - Parameters:
    ///   - f: Function to compute the relative position.
    /// - Returns: Value located in a relative position to the current one.
    func peeks(_ f: @escaping (F.S) -> F.S) -> A {
        F.peeks(self, f)
    }
    
    /// Moves to a new position.
    ///
    /// - Parameters:
    ///   - s: New position.
    /// - Returns: Store focused into the new position.
    func seek(_ s: F.S) -> Kind<F, A> {
        F.seek(self, s)
    }
    
    /// Moves to a new position relative to the current one.
    ///
    /// - Parameters:
    ///   - f: Function to compute the new position, relative to the current one.
    /// - Returns: Store focused into the new position.
    func seeks(_ f: @escaping (F.S) -> F.S) -> Kind<F, A> {
        F.seeks(self, f)
    }
    
    /// Extracts a collection of values from positions that depend on the current one.
    ///
    /// - Parameters:
    ///   - f: Effectful function computing new positions based on the current one.
    /// - Returns: A collection of values located a the specified positions.
    func experiment<G: Functor>(_ f: @escaping (F.S) -> Kind<G, F.S>) -> Kind<G, A> {
        F.experiment(self, f)
    }
}

/// The ComonadTraced type class represents those comonads which support relative (monoidal) position information.
public protocol ComonadTraced: Comonad {
    /// Index type to access values inside the Comonad
    associatedtype M
    
    /// Extracts a value at the specified relative position.
    ///
    /// - Parameters:
    ///   - wa: Trace.
    ///   - m: Relative position.
    /// - Returns: Value corresponding to the specified position.
    static func trace<A>(_ wa: Kind<Self, A>, _ m: M) -> A
    
    /// Gets a value that depends on the current position.
    ///
    /// - Parameters:
    ///   - wa: Trace.
    ///   - f: Function to compute a value from the current position.
    /// - Returns: A tuple with the current and computed value in the context of this ComonadTraced.
    static func listens<A, B>(_ wa: Kind<Self, A>, _ f: @escaping (M) -> B) -> Kind<Self, (B, A)>
    
    /// Obtains a Trace that can modify the current position.
    ///
    /// - Parameter wa: Trace.
    /// - Returns: Trace that can modify the current position.
    static func pass<A>(_ wa: Kind<Self, A>) -> Kind<Self, ((M) -> M) -> A>
}

public extension ComonadTraced {
    /// Extracts a value at a relative position which depends on the current value.
    ///
    /// - Parameters:
    ///   - wa: Trace.
    ///   - f: Function to compute the position based on the current value.
    /// - Returns: Value corresponding to the new position.
    static func traces<A>(_ wa: Kind<Self, A>, _ f: @escaping (A) -> M) -> A {
        trace(wa, f(wa.extract()))
    }
    
    /// Obtains the current position together with the current value.
    ///
    /// - Parameter wa: Trace.
    /// - Returns: A tuple with the current position and value in the context of this ComonadTraced.
    static func listen<A>(_ wa: Kind<Self, A>) -> Kind<Self, (M, A)> {
        listens(wa, id)
    }
    
    /// Apply a function to the current position.
    ///
    /// - Parameters:
    ///   - wa: Trace.
    ///   - f: Function to transform the current position.
    /// - Returns: Trace focused in the new position.
    static func censor<A>(_ wa: Kind<Self, A>, _ f: @escaping (M) -> M) -> Kind<Self, A> {
        pass(wa).map { trace in trace(f) }
    }
}

// MARK: Syntax for ComonadTraced

public extension Kind where F: ComonadTraced {
    /// Extracts a value at the specified relative position.
    ///
    /// - Parameters:
    ///   - m: Relative position.
    /// - Returns: Value corresponding to the specified position.
    func trace(_ m: F.M) -> A {
        F.trace(self, m)
    }
    
    /// Extracts a value at a relative position which depends on the current value.
    ///
    /// - Parameters:
    ///   - f: Function to compute the position based on the current value.
    /// - Returns: Value corresponding to the new position.
    func traces(_ f: @escaping (A) -> F.M) -> A {
        F.traces(self, f)
    }
    
    /// Gets a value that depends on the current position.
    ///
    /// - Parameters:
    ///   - f: Function to compute a value from the current position.
    /// - Returns: A tuple with the current and computed value in the context of this ComonadTraced.
    func listens<B>(_ f: @escaping (F.M) -> B) -> Kind<F, (B, A)> {
        F.listens(self, f)
    }
    
    /// Obtains the current position together with the current value.
    ///
    /// - Returns: A tuple with the current position and value in the context of this ComonadTraced.
    func listen() -> Kind<F, (F.M, A)> {
        F.listen(self)
    }
    
    /// Apply a function to the current position.
    ///
    /// - Parameters:
    ///   - f: Function to transform the current position.
    /// - Returns: Trace focused in the new position.
    func censor(_ f: @escaping (F.M) -> F.M) -> Kind<F, A> {
        F.censor(self, f)
    }
    
    /// Obtains a Trace that can modify the current position.
    ///
    /// - Returns: Trace that can modify the current position.
    func pass() -> Kind<F, ((F.M) -> F.M) -> A>  {
        F.pass(self)
    }
}

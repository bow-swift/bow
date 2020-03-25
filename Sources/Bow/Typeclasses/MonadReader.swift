import Foundation

/// A MonadReader is a `Monad` with capabilities to read values from a shared environment.
public protocol MonadReader: Monad {
    /// Type of the shared environment
    associatedtype D

    /// Retrieves the shared environment.
    ///
    /// - Returns: Shared environment.
    static func ask() -> Kind<Self, D>

    /// Executes a computation in a modified environment.
    ///
    /// - Parameters:
    ///   - fa: Computation to execute.
    ///   - f: Funtion to modify the environment.
    /// - Returns: Computation in the modified environment.
    static func local<A>(
        _ fa: Kind<Self, A>,
        _ f: @escaping (D) -> D) -> Kind<Self, A>
}

public extension MonadReader {
    /// Retrieves a function of the current environment.
    ///
    /// - Parameter f: Selector function to apply to the environment.
    /// - Returns: A value extracted from the environment, in the context implementing this instance.
    static func reader<A>(_ f: @escaping (D) -> A) -> Kind<Self, A> {
        map(ask(), f)
    }
}

// MARK: Syntax for MonadReader

public extension Kind where F: MonadReader, A == F.D {
    /// Retrieves the shared environment.
    ///
    /// This is a convenience method to call `MonadReader.ask` as a static method of this type.
    ///
    /// - Returns: Shared environment.
    static func ask() -> Kind<F, F.D> {
        F.ask()
    }
}

public extension Kind where F: MonadReader {
    /// Executes this computation in a modified environment.
    ///
    /// This is a convenience method to call `MonadReader.local` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: Funtion to modify the environment.
    /// - Returns: Computation in the modified environment.
    func local(_ f: @escaping (F.D) -> F.D) -> Kind<F, A> {
        F.local(self, f)
    }

    /// Retrieves a function of the current environment.
    ///
    /// This is a convenience method to call `MonadReader.reader` as a static method of this type.
    ///
    /// - Parameter f: Selector function to apply to the environment.
    /// - Returns: A value extracted from the environment, in the context implementing this instance.
    static func reader(_ f: @escaping (F.D) -> A) -> Kind<F, A> {
        F.reader(f)
    }
}

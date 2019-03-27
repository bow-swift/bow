import Foundation

/// Coreader is a special case of CoreaderT / Cokleisli where F is `Id`, so it is equivalent to functions `(A) -> B`.
public class Coreader<A, B>: CoreaderT<ForId, A, B> {
    /// Convenience initializer for Coreader
    ///
    /// - Parameter run: Function to be enclosed in this Coreader.
    public init(_ run: @escaping (A) -> B) {
        super.init({ idA in run((idA as! Id<A>).extract()) })
    }
    
    /// Runs this Coreader function with the given input.
    ///
    /// - Parameter a: Input value for the function.
    /// - Returns: Output of the function.
    public func runId(_ a: A) -> B {
        return self.run(Id<A>.pure(a))
    }
}


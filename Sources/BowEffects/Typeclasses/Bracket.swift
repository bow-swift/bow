import Bow

/// Describes the outcome of an operation on a resource.
///
/// - completed: The operation was completed successfully.
/// - canceled: The operation was canceled.
/// - error: The operation finished with an error.
public enum ExitCase<E> {
    case completed
    case canceled
    case error(E)
    
    /// Applies a function based on the content of this value.
    ///
    /// - Parameters:
    ///   - ifCompleted: Function to be applied if this value is completed.
    ///   - ifCanceled: Function to be applied if this value is canceled.
    ///   - ifError: Function to be applied if this value is errored.
    /// - Returns: Result of applying the corresponding function based on the content of this value.
    public func fold<A>(_ ifCompleted: () -> A, _ ifCanceled: () -> A, _ ifError: (E) -> A) -> A {
        switch self {
        case .completed: return ifCompleted()
        case .canceled: return ifCanceled()
        case let .error(e): return ifError(e)
        }
    }
}

extension ExitCase: CustomStringConvertible {
    public var description: String {
        return fold(constant("ExitCase.Completed"),
                    constant("ExitCase.Canceled"),
                    { e in "ExitCase.Error(\(e))" })
    }
}

extension ExitCase: Equatable where E: Equatable {}

public func ==<E: Equatable>(lhs: ExitCase<E>, rhs: ExitCase<E>) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case (.canceled, .canceled): return true
    case let (.error(e1), .error(e2)): return e1 == e2
    default: return false
    }
}

/// Bracket models a generalized abstracted pattern of safe resource acquisition and release in the face of errors or interruptions.
public protocol Bracket: MonadError {
    /// A way to safely acquire a resource and release in the face of errors and cancellations. It uses `ExitCase` to distinguish between different exit cases when releasing the acquired resource.
    ///
    /// - Parameters:
    ///   - fa: Computation to describe the acquisition of the resource.
    ///   - release: Function to release the acquired resource.
    ///   - use: Function to use the acquired resource.
    /// - Returns: Computation describing the result of using the resource.
    static func bracketCase<A, B>(acquire fa: Kind<Self, A>,
                                  release: @escaping (A, ExitCase<Self.E>) -> Kind<Self, ()>,
                                  use: @escaping (A) throws -> Kind<Self, B>) -> Kind<Self, B>
}

// MARK: Related functions

public extension Bracket {
    /// A way to safely acquire a resource and release in the face of errors and cancellations. It uses `ExitCase` to distinguish between different exit cases when releasing the acquired resource.
    ///
    /// - Parameters:
    ///   - fa: Computation to describe the acquisition of the resource.
    ///   - release: Function to release the acquired resource, ignoring the outcome of the release of the resource.
    ///   - use: Function to use the acquired resource.
    /// - Returns: Computation describing the result of using the resource.
    static func bracket<A, B>(acquire fa: Kind<Self, A>,
                              release: @escaping (A) -> Kind<Self, ()>,
                              use: @escaping (A) throws -> Kind<Self, B>) -> Kind<Self, B> {
        return bracketCase(acquire: fa, release: { a, _ in release(a) }, use: use)
    }
    
    /// Forces a resource to be uncancelable even when an interruption happens.
    ///
    /// - Parameter fa: Computation describing the acquisition of the resource.
    /// - Returns: An uncancelable computation.
    static func uncancelable<A>(_ fa: Kind<Self, A>) -> Kind<Self, A> {
        return bracket(acquire: fa, release: constant(pure(())), use: { x in pure(x) })
    }
    
    /// Executes the given finalizer when the source is finished, either in success, error or cancelation.
    ///
    /// - Parameters:
    ///   - fa: Computation describing the acquisition of the resource.
    ///   - finalizer: Finalizer function to be invoked when the resource is released.
    /// - Returns: A computation describing the resouce that will invoke the finalizer when it is released.
    static func guarantee<A>(_ fa: Kind<Self, A>,
                             finalizer: Kind<Self, ()>) -> Kind<Self, A> {
        return bracket(acquire: fa, release: constant(finalizer), use: constant(fa))
    }
    
    /// Executes the given finalizer when the source is finished, either in success, error or cancelation, alowing to differentiate between exit conditions.
    ///
    /// - Parameters:
    ///   - fa: Computation describing the acquisition of the resource.
    ///   - finalizer: Finalizer function to be invoked when the resource is released, distinguishing the exit case.
    /// - Returns: A computation describing the resource that will invoke the finalizer when it is released.
    static func guaranteeCase<A>(_ fa: Kind<Self, A>,
                                 finalizer: @escaping (ExitCase<Self.E>) -> Kind<Self, ()>) -> Kind<Self, A> {
        return bracketCase(acquire: fa, release: { _, e in finalizer(e) }, use: constant(fa))
    }
}

// MARK: Syntax for Bracket

public extension Kind where F: Bracket {
    /// A way to safely acquire a resource and release in the face of errors and cancellations. It uses `ExitCase` to distinguish between different exit cases when releasing the acquired resource.
    ///
    /// - Parameters:
    ///   - release: Function to release the acquired resource.
    ///   - use: Function to use the acquired resource.
    /// - Returns: Computation describing the result of using the resource.
    func bracketCase<B>(release: @escaping (A, ExitCase<F.E>) -> Kind<F, ()>,
                        use: @escaping (A) throws -> Kind<F, B>) -> Kind<F, B> {
        return F.bracketCase(acquire: self, release: release, use: use)
    }
    
    /// A way to safely acquire a resource and release in the face of errors and cancellations. It uses `ExitCase` to distinguish between different exit cases when releasing the acquired resource.
    ///
    /// - Parameters:
    ///   - release: Function to release the acquired resource, ignoring the outcome of the release of the resource.
    ///   - use: Function to use the acquired resource.
    /// - Returns: Computation describing the result of using the resource.
    func bracket<B>(release: @escaping (A) -> Kind<F, ()>,
                    use: @escaping (A) throws -> Kind<F, B>) -> Kind<F, B> {
        return F.bracket(acquire: self, release: release, use: use)
    }
    
    /// Forces this resource to be uncancelable even when an interruption happens.
    ///
    /// - Returns: An uncancelable computation.
    func uncancelable() -> Kind<F, A> {
        return F.uncancelable(self)
    }
    
    /// Executes the given finalizer when the source is finished, either in success, error or cancelation.
    ///
    /// - Parameter finalizer: Finalizer function to be invoked when the resource is released.
    /// - Returns: A computation describing the resouce that will invoke the finalizer when it is released.
    func guarantee(_ finalizer: Kind<F, ()>) -> Kind<F, A> {
        return F.guarantee(self, finalizer: finalizer)
    }
    
    /// Executes the given finalizer when the source is finished, either in success, error or cancelation, alowing to differentiate between exit conditions.
    ///
    /// - Parameter finalizer: Finalizer function to be invoked when the resource is released, distinguishing the exit case.
    /// - Returns: A computation describing the resource that will invoke the finalizer when it is released.
    func guaranteeCase(_ finalizer: @escaping (ExitCase<F.E>) -> Kind<F, ()>) -> Kind<F, A> {
        return F.guaranteeCase(self, finalizer: finalizer)
    }
}

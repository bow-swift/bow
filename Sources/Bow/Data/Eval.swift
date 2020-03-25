import Foundation

/// Witness for the `Eval<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForEval {}

/// Partial application of the Eval type constructor, omitting the last type parameter.
public typealias EvalPartial = ForEval

/// Higher-Kinded Type alias to improve readability over `Kind<ForEval, A>`.
public typealias EvalOf<A> = Kind<ForEval, A>

/// Eval is a data type that describes a potentially lazy computation that produces a value.
///
/// Eval has three different evaluation strategies:
///     - Now: the computation is evaluated immediately.
///     - Later: the computation is evaluated when it is needed (typically by calling `Eval.value()`), just once. This value is cached, so subsequent invocations do not trigger additional computations of the value.
///     - Always: the computation is evaluated every time it is needed (typically by calling `Eval.value()`).
///
/// Now is an eager evaluation strategy, whereas Later and Always are lazy.
public class Eval<A>: EvalOf<A> {
    /// Creates an Eval value with a value that is immediately evaluated.
    ///
    /// - Parameter a: Value to be wrapped in the Eval.
    /// - Returns: An Eval value.
    public static func now(_ a: A) -> Eval<A> {
        Now<A>(a)
    }

    /// Creates an Eval value that will be evaluated using the Later evaluation strategy.
    ///
    /// - Parameter f: Function producing the value to be wrapped in an Eval.
    /// - Returns: An Eval value.
    public static func later(_ f: @escaping () -> A) -> Eval<A> {
        Later<A>(f)
    }

    /// Creates an Eval value that will be evaluated using the Always evaluation strategy.
    ///
    /// - Parameter f: Function producing the value to be wrapped in an Eval.
    /// - Returns: An Eval value.
    public static func always(_ f: @escaping () -> A) -> Eval<A> {
        Always<A>(f)
    }

    /// Creates an Eval value that defers a computation that produces another Eval.
    ///
    /// - Parameter f: Function producing an Eval.
    /// - Returns: An Eval value.
    public static func `defer`(_ f: @escaping () -> Eval<A>) -> Eval<A> {
        Defer<A>(f)
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `Eval`.
    public static func fix(_ fa: EvalOf<A>) -> Eval<A> {
        fa as! Eval<A>
    }

    /// Computes the value wrapped in this Eval.
    ///
    /// - Returns: Value wrapped in this Eval.
    public func value() -> A {
        _value().run()
    }
    
    internal func _value() -> Trampoline<A> {
        fatalError("Must be implemented by subclass")
    }

    /// Provides an Eval that memoizes the result of its enclosed computation.
    ///
    /// - Returns: An Eval value.
    public func memoize() -> Eval<A> {
        fatalError("Must be implemented by subclass")
    }
}

public extension Eval where A == () {
    /// Provides a unit in an Eval.
    static var unit: Eval<Void> {
        Now<Void>(())
    }
}

public extension Eval where A == Bool {
    /// Provides a true value in an Eval.
    static var `true`: Eval<Bool> {
        Now<Bool>(true)
    }
    
    /// Provides a false value in an Eval.
    static var `false`: Eval<Bool> {
        Now<Bool>(false)
    }
}

public extension Eval where A == Int {
    /// Provides a zero value in an Eval.
    static var zero: Eval<Int> {
        Now<Int>(0)
    }
    
    /// Provides a one value in an Eval.
    static var one: Eval<Int> {
        Now<Int>(1)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Eval.
public postfix func ^<A>(_ fa: EvalOf<A>) -> Eval<A> {
    Eval.fix(fa)
}

private class Now<A>: Eval<A> {
    private let a: A

    init(_ a: A) {
        self.a = a
    }

    override func _value() -> Trampoline<A> {
        .done(a)
    }

    override func memoize() -> Eval<A> {
        self
    }
}

private class Later<A>: Eval<A> {
    private lazy var a: A = f()
    private let f: () -> A

    init(_ f: @escaping () -> A) {
        self.f = f
    }

    override func _value() -> Trampoline<A> {
        .done(a)
    }

    override func memoize() -> Eval<A> {
        self
    }
}

private class Always<A>: Eval<A> {
    private let f: () -> A

    init(_ f: @escaping () -> A) {
        self.f = f
    }

    override func _value() -> Trampoline<A> {
        .later(f)
    }

    override func memoize() -> Eval<A> {
        Eval<A>.later(f)
    }
}

private class Defer<A>: Eval<A> {
    private let thunk: () -> Eval<A>

    init(_ thunk: @escaping () -> Eval<A>) {
        self.thunk = thunk
    }

    override func memoize() -> Eval<A> {
        Eval<A>.later(value)
    }

    override func _value() -> Trampoline<A> {
        .defer { self.thunk()._value() }
    }
}

private class FMap<A, B>: Eval<B> {
    private let eval: Eval<A>
    private let f: (A) -> B
    
    init(_ eval: Eval<A>, _ f: @escaping (A) -> B) {
        self.eval = eval
        self.f = f
    }
    
    override func memoize() -> Eval<B> {
        Eval<B>.later { self.value() }
    }
    
    override func _value() -> Trampoline<B> {
        .later { self.f(self.eval.value()) }
    }
}

private class Bind<A, B>: Eval<B> {
    private let eval: Eval<A>
    private let f: (A) -> EvalOf<B>
    
    init(_ eval: Eval<A>, _ f: @escaping (A) -> EvalOf<B>) {
        self.eval = eval
        self.f = f
    }
    
    override func memoize() -> Eval<B> {
        Eval.later { self.value() }
    }
    
    override func _value() -> Trampoline<B> {
        .later { self.f(self.eval.value())^.value() }
    }
}

// MARK: Instance of Functor for Eval
extension EvalPartial: Functor {
    public static func map<A, B>(
        _ fa: EvalOf<A>,
        _ f: @escaping (A) -> B) -> EvalOf<B> {
        FMap(fa^, f)
    }
}

// MARK: Instance of Applicative for Eval
extension EvalPartial: Applicative {
    public static func pure<A>(_ a: A) -> EvalOf<A> {
        Eval.now(a)
    }
}

// MARK: Instance of Selective for Eval
extension EvalPartial: Selective {}

// MARK: Instance of Monad for Eval
extension EvalPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: EvalOf<A>,
        _ f: @escaping (A) -> EvalOf<B>) -> EvalOf<B> {
        Bind(fa^, f)
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> EvalOf<Either<A, B>>) -> EvalOf<B> {
        _tailRecM(a, f).run()
    }
    
    private static func _tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> EvalOf<Either<A, B>>) -> Trampoline<EvalOf<B>> {
        .defer {
            f(a)^.value().fold({ a in _tailRecM(a, f) },
                               { b in .done(Eval<B>.pure(b)) })
        }
    }
}

// MARK: Instance of Comonad for Eval
extension EvalPartial: Comonad {
    public static func coflatMap<A, B>(
        _ fa: EvalOf<A>,
        _ f: @escaping (EvalOf<A>) -> B) -> EvalOf<B> {
        Eval.later { f(fa) }
    }
    
    public static func extract<A>(_ fa: EvalOf<A>) -> A {
        fa^.value()
    }
}

// MARK: Instance of Bimonad for Eval
extension EvalPartial: Bimonad {}

// MARK: Instance of EquatableK for Eval
extension EvalPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: EvalOf<A>,
        _ rhs: EvalOf<A>) -> Bool {
        lhs^.value() == rhs^.value()
    }
}

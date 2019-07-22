import Foundation

/// Witness for the `Eval<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForEval {}

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
        return Now<A>(a)
    }

    /// Creates an Eval value that will be evaluated using the Later evaluation strategy.
    ///
    /// - Parameter f: Function producing the value to be wrapped in an Eval.
    /// - Returns: An Eval value.
    public static func later(_ f: @escaping () -> A) -> Eval<A> {
        return Later<A>(f)
    }

    /// Creates an Eval value that will be evaluated using the Always evaluation strategy.
    ///
    /// - Parameter f: Function producing the value to be wrapped in an Eval.
    /// - Returns: An Eval value.
    public static func always(_ f: @escaping () -> A) -> Eval<A> {
        return Always<A>(f)
    }

    /// Creates an Eval value that defers a computation that produces another Eval.
    ///
    /// - Parameter f: Function producing an Eval.
    /// - Returns: An Eval value.
    public static func `defer`(_ f: @escaping () -> Eval<A>) -> Eval<A> {
        return Defer<A>(f)
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `Eval`.
    public static func fix(_ fa: EvalOf<A>) -> Eval<A> {
        return fa as! Eval<A>
    }

    /// Computes the value wrapped in this Eval.
    ///
    /// - Returns: Value wrapped in this Eval.
    public func value() -> A {
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
    static var unit: Eval<()> {
        return Now<()>(())
    }
}

public extension Eval where A == Bool {
    /// Provides a true value in an Eval.
    static var `true`: Eval<Bool> {
        return Now<Bool>(true)
    }
    
    /// Provides a false value in an Eval.
    static var `false`: Eval<Bool> {
        return Now<Bool>(false)
    }
}

public extension Eval where A == Int {
    /// Provides a zero value in an Eval.
    static var zero: Eval<Int> {
        return Now<Int>(0)
    }
    
    /// Provides a one value in an Eval.
    static var one: Eval<Int> {
        return Now<Int>(1)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Eval.
public postfix func ^<A>(_ fa: EvalOf<A>) -> Eval<A> {
    return Eval.fix(fa)
}

private class Now<A>: Eval<A> {
    private let a: A

    init(_ a: A) {
        self.a = a
    }

    override func value() -> A {
        return a
    }

    override func memoize() -> Eval<A> {
        return self
    }
}

private class Later<A>: Eval<A> {
    private lazy var a: A = f()
    private let f: () -> A

    init(_ f: @escaping () -> A) {
        self.f = f
    }

    override func value() -> A {
        return a
    }

    override func memoize() -> Eval<A> {
        return self
    }
}

private class Always<A>: Eval<A> {
    private  let f: () -> A

    init(_ f: @escaping () -> A) {
        self.f = f
    }

    override func value() -> A {
        return f()
    }

    override func memoize() -> Eval<A> {
        return Eval<A>.later(f)
    }
}

private class Defer<A>: Eval<A> {
    private  let thunk: () -> Eval<A>

    init(_ thunk: @escaping () -> Eval<A>) {
        self.thunk = thunk
    }

    override func memoize() -> Eval<A> {
        return Eval<A>.later(value)
    }

    override func value() -> A {
        return thunk().value()
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
        return Eval<B>.later { self.value() }
    }
    
    override func value() -> B {
        return f(eval.value())
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
        return Eval.later { self.value() }
    }
    
    override func value() -> B {
        return f(eval.value())^.value()
    }
}

// MARK: Instance of `Functor` for `Eval`
extension ForEval: Functor {
    public static func map<A, B>(_ fa: Kind<ForEval, A>, _ f: @escaping (A) -> B) -> Kind<ForEval, B> {
        return FMap(fa^, f)
    }
}

// MARK: Instance of `Applicative` for `Eval`
extension ForEval: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForEval, A> {
        return Eval.now(a)
    }
}

// MARK: Instance of `Selective` for `Eval`
extension ForEval: Selective {}

// MARK: Instance of `Monad` for `Eval`
extension ForEval: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForEval, A>, _ f: @escaping (A) -> Kind<ForEval, B>) -> Kind<ForEval, B> {
        return Bind(fa^, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForEval, Either<A, B>>) -> Kind<ForEval, B> {
        return f(a).flatMap{ either in
            either.fold({ a in tailRecM(a, f) },
                        Eval<B>.pure)
        }
    }
}

// MARK: Instance of `Comonad` for `Eval`
extension ForEval: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<ForEval, A>, _ f: @escaping (Kind<ForEval, A>) -> B) -> Kind<ForEval, B> {
        return Eval.later { f(fa) }
    }
    
    public static func extract<A>(_ fa: Kind<ForEval, A>) -> A {
        return fa^.value()
    }
}

// MARK: Instance of `Bimonad` for `Eval`
extension ForEval: Bimonad {}

// MARK: Instance of `EquatableK` for `Eval`
extension ForEval: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForEval, A>, _ rhs: Kind<ForEval, A>) -> Bool {
        return Eval.fix(lhs).value() == Eval.fix(rhs).value()
    }
}

import Foundation

public final class ForEval {}
public typealias EvalOf<A> = Kind<ForEval, A>

public class Eval<A>: EvalOf<A> {

    public static func now(_ a: A) -> Eval<A> {
        return Now<A>(a)
    }

    public static func later(_ f: @escaping () -> A) -> Eval<A> {
        return Later<A>(f)
    }

    public static func always(_ f: @escaping () -> A) -> Eval<A> {
        return Always<A>(f)
    }

    public static func deferEvaluation(_ f: @escaping () -> Eval<A>) -> Eval<A> {
        return Call<A>(f)
    }

    public static var Unit: Eval<()> {
        return Now<()>(())
    }

    public static var True: Eval<Bool> {
        return Now<Bool>(true)
    }

    public static var False: Eval<Bool> {
        return Now<Bool>(false)
    }

    public static var Zero: Eval<Int> {
        return Now<Int>(0)
    }

    public static var One: Eval<Int> {
        return Now<Int>(1)
    }

    public static func fix(_ fa: EvalOf<A>) -> Eval<A> {
        return fa as! Eval<A>
    }

    public func value() -> A {
        fatalError("Must be implemented by subclass")
    }

    public func memoize() -> Eval<A> {
        fatalError("Must be implemented by subclass")
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Eval.
public postfix func ^<A>(_ fa: EvalOf<A>) -> Eval<A> {
    return Eval.fix(fa)
}

class Now<A>: Eval<A> {
    fileprivate let a: A

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

class Later<A>: Eval<A> {
    fileprivate lazy var a: A = f()
    fileprivate let f: () -> A

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

class Always<A>: Eval<A> {
    fileprivate let f: () -> A

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

private class Call<A>: Eval<A> {
    fileprivate let thunk: () -> Eval<A>

    init(_ thunk: @escaping () -> Eval<A>) {
        self.thunk = thunk
    }

    override func memoize() -> Eval<A> {
        return Eval<A>.later(value)
    }

    override func value() -> A {
        return Call.collapse(self).value()
    }

    static func collapse(_ fa: Eval<A>) -> Eval<A> {
        switch fa {
        case is Call<A>:
            let faCall = fa as! Call
            return collapse(faCall.thunk())
        case is Compute<A>:
            return Call2Compute<A>(fa as! Compute<A>)
        default:
            return fa
        }
    }
}

private class Compute<A>: Eval<A> {
    func start<S>() -> Eval<S> {
        fatalError("Must be implemented by Compute subclass")
    }

    func run<S>(_ s: S) -> Eval<A> {
        fatalError("Must be implemented by Compute subclass")
    }

    override func memoize() -> Eval<A> {
        return Eval<A>.later(value)
    }

    override func value() -> A {
        var curr: Eval<A> = self
        var fs: [(AnyObject) -> Eval<A>] = []

        while true {
            switch curr {
            case is Compute:
                let currComp = curr as! Compute
                let startResult = currComp.start() as Eval<A>
                switch startResult {
                case is Compute:
                    let inStartFunc: (AnyObject) -> Eval<A> = { s in (startResult as! Compute).run(s as! A) }
                    let outStartFunc: (AnyObject) -> Eval<A> = { s in currComp.run(s as! A) }
                    curr = (startResult as! Compute).start()
                    fs = [inStartFunc, outStartFunc] + fs
                default:
                    curr = currComp.run(startResult.value())
                }
            default:
                if !fs.isEmpty {
                    let f = fs.removeFirst()
                    curr = f(curr.value() as AnyObject)
                } else {
                    return curr.value()
                }
            }
        }
    }
}

private class Call2Compute<A>: Compute<A> {
    private let fa: Compute<A>

    init(_ fa: Compute<A>) {
        self.fa = fa
    }

    override func start<S>() -> Eval<S> {
        return fa.start()
    }

    override func run<S>(_ s: S) -> Eval<A> {
        return Call.collapse(fa.run(s))
    }
}

private class FlatmapCompute<A, B>: Compute<A> {
    private let compute: Compute<B>
    private let f: (B) -> Eval<A>

    init(_ compute: Compute<B>, _ f: @escaping (B) -> Eval<A>) {
        self.compute = compute
        self.f = f
    }

    override func start<S>() -> Eval<S> {
        return compute.start()
    }

    override func run<S>(_ s: S) -> Eval<A> {
        return RunCompute(compute, f, s)
    }
}

private class RunCompute<A, B, S>: Compute<A> {
    private let compute: Compute<B>
    private let f: (B) -> Eval<A>
    private let s: S

    init(_ compute: Compute<B>, _ f: @escaping (B) -> Eval<A>, _ s: S) {
        self.compute = compute
        self.f = f
        self.s = s
    }

    override func start<S1>() -> Eval<S1> {
        return compute.run(s) as! Eval<S1>
    }

    override func run<S1>(_ s: S1) -> Eval<A> {
        return f(s as! B)
    }
}

private class FlatmapCall<A, B>: Compute<A> {
    private let call: Call<B>
    private let f: (B) -> Eval<A>

    init(_ call: Call<B>, _ f: @escaping (B) -> Eval<A>) {
        self.call = call
        self.f = f
    }

    override func start<S>() -> Eval<S> {
        return call.thunk() as! Eval<S>
    }

    override func run<S>(_ s: S) -> Eval<A> {
        return f(s as! B)
    }
}

private class FlatmapDefault<A, B>: Compute<A> {
    private let eval: Eval<B>
    private let f: (B) -> Eval<A>

    init(_ eval: Eval<B>, _ f: @escaping (B) -> Eval<A>) {
        self.eval = eval
        self.f = f
    }

    override func start<S>() -> Eval<S> {
        return eval as! Eval<S>
    }

    override func run<S>(_ s: S) -> Eval<A> {
        return f(s as! B)
    }
}

extension ForEval: Functor {
    public static func map<A, B>(_ fa: Kind<ForEval, A>, _ f: @escaping (A) -> B) -> Kind<ForEval, B> {
        return flatMap(fa, { a in Eval.now(f(a)) })
    }
}

extension ForEval: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForEval, A> {
        return Eval.now(a)
    }
}

// MARK: Instance of `Selective` for `Eval`
extension ForEval: Selective {}

extension ForEval: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForEval, A>, _ f: @escaping (A) -> Kind<ForEval, B>) -> Kind<ForEval, B> {
        let ff: (A) -> Eval<B> = { a in Eval.fix(f(a)) }
        switch fa {
        case let compute as Compute<A>:
            return FlatmapCompute(compute, ff)
        case let call as Call<A>:
            return FlatmapCall(call, ff)
        default:
            return FlatmapDefault(Eval.fix(fa), ff)
        }
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForEval, Either<A, B>>) -> Kind<ForEval, B> {
        return Eval.fix(f(a)).flatMap{ either in
            either.fold({ a in tailRecM(a, f) },
                        Eval<B>.pure)
        }
    }
}

extension ForEval: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForEval, A>, _ rhs: Kind<ForEval, A>) -> Bool where A: Equatable {
        return Eval.fix(lhs).value() == Eval.fix(rhs).value()
    }
}

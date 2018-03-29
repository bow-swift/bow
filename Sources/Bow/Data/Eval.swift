//
//  Eval.swift
//  Bow
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class EvalF {}

public class Eval<A> : HK<EvalF, A> {
    
    public static func now(_ a : A) -> Eval<A> {
        return Now<A>(a)
    }
    
    public static func later(_ f : @escaping () -> A) -> Eval<A> {
        return Later<A>(f)
    }
    
    public static func always(_ f : @escaping () -> A) -> Eval<A> {
        return Always<A>(f)
    }
    
    public static func pure(_ a : A) -> Eval<A> {
        return now(a)
    }
    
    public static func deferEvaluation(_ f : @escaping () -> Eval<A>) -> Eval<A> {
        return Call<A>(f)
    }
    
    public static var Unit : Eval<()> {
        return Now<()>(())
    }
    
    public static var True : Eval<Bool> {
        return Now<Bool>(true)
    }
    
    public static var False : Eval<Bool> {
        return Now<Bool>(false)
    }
    
    public static var Zero : Eval<Int> {
        return Now<Int>(0)
    }
    
    public static var One : Eval<Int> {
        return Now<Int>(1)
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> Eval<Either<A, B>>) -> Eval<B> {
        return f(a).flatMap{ either in
            either.fold({ a in tailRecM(a, f) },
                        Eval<B>.pure)
        }
    }
    
    public static func ev(_ fa : HK<EvalF, A>) -> Eval<A> {
        return fa.ev()
    }
    
    public func value() -> A {
        fatalError("Must be implemented by subclass")
    }
    
    public func memoize() -> Eval<A> {
        fatalError("Must be implemented by subclass")
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Eval<B> {
        return flatMap{ a in Eval<B>.now(f(a)) }
    }
    
    public func ap<B>(_ ff : Eval<(A) -> B>) -> Eval<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Eval<B>) -> Eval<B> {
        switch self {
            case is Compute<A>:
                return FlatmapCompute(self as! Compute<A>, f)
            case is Call<A>:
                return FlatmapCall(self as! Call<A>, f)
            default:
                return FlatmapDefault(self, f)
        }
    }
}

class Now<A> : Eval<A> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
    
    override func value() -> A {
        return a
    }
    
    override func memoize() -> Eval<A> {
        return self
    }
}

class Later<A> : Eval<A> {
    fileprivate lazy var a : A = f()
    fileprivate let f : () -> A
    
    init(_ f : @escaping () -> A) {
        self.f = f
    }
    
    override func value() -> A {
        return a
    }
    
    override func memoize() -> Eval<A> {
        return self
    }
}

class Always<A> : Eval<A> {
    fileprivate let f : () -> A
    
    init(_ f : @escaping () -> A) {
        self.f = f
    }
    
    override func value() -> A {
        return f()
    }
    
    override func memoize() -> Eval<A> {
        return Eval<A>.later(f)
    }
}

fileprivate class Call<A> : Eval<A> {
    fileprivate let thunk : () -> Eval<A>
    
    init(_ thunk : @escaping () -> Eval<A>) {
        self.thunk = thunk
    }
    
    override func memoize() -> Eval<A> {
        return Eval<A>.later(value)
    }
    
    override func value() -> A {
        return Call.collapse(self).value()
    }
    
    static func collapse(_ fa : Eval<A>) -> Eval<A> {
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

fileprivate class Compute<A> : Eval<A> {
    func start<S>() -> Eval<S> {
        fatalError("Must be implemented by Compute subclass")
    }
    
    func run<S>(_ s : S) -> Eval<A> {
        fatalError("Must be implemented by Compute subclass")
    }
    
    override func memoize() -> Eval<A> {
        return Eval<A>.later(value)
    }
    
    override func value() -> A {
        var curr : Eval<A> = self
        var fs : [(AnyObject) -> Eval<A>] = []
        
        while true {
            switch curr {
                case is Compute:
                    let currComp = curr as! Compute
                    let startResult = currComp.start() as Eval<A>
                    switch startResult {
                        case is Compute:
                            let inStartFunc : (AnyObject) -> Eval<A> = { s in (startResult as! Compute).run(s as! A) }
                            let outStartFunc : (AnyObject) -> Eval<A> = { s in currComp.run(s as! A) }
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

fileprivate class Call2Compute<A> : Compute<A> {
    private let fa : Compute<A>
    
    init(_ fa : Compute<A>) {
        self.fa = fa
    }
    
    override func start<S>() -> Eval<S> {
        return fa.start()
    }
    
    override func run<S>(_ s: S) -> Eval<A> {
        return Call.collapse(fa.run(s))
    }
}

fileprivate class FlatmapCompute<A, B> : Compute<A> {
    private let compute : Compute<B>
    private let f : (B) -> Eval<A>
    
    init(_ compute : Compute<B>, _ f : @escaping (B) -> Eval<A>) {
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

fileprivate class RunCompute<A, B, S> : Compute<A> {
    private let compute : Compute<B>
    private let f : (B) -> Eval<A>
    private let s : S
    
    init(_ compute : Compute<B>, _ f : @escaping (B) -> Eval<A>, _ s : S) {
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

fileprivate class FlatmapCall<A, B> : Compute<A> {
    private let call : Call<B>
    private let f : (B) -> Eval<A>
    
    init(_ call : Call<B>, _ f : @escaping (B) -> Eval<A>) {
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

fileprivate class FlatmapDefault<A, B> : Compute<A> {
    private let eval : Eval<B>
    private let f : (B) -> Eval<A>
    
    init(_ eval : Eval<B>, _ f : @escaping (B) -> Eval<A>) {
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

public extension HK where F == EvalF {
    public func ev() -> Eval<A> {
        return self as! Eval<A>
    }
}

public extension Eval {
    public static func functor() -> EvalApplicative {
        return EvalApplicative()
    }
    
    public static func applicative() -> EvalApplicative {
        return EvalApplicative()
    }
    
    public static func eq<EqA>(_ eq : EqA) -> EvalEq<A, EqA> {
        return EvalEq<A, EqA>(eq)
    }
}

public class EvalApplicative : Applicative {
    public typealias F = EvalF
    
    public func pure<A>(_ a: A) -> HK<F, A> {
        return Eval<A>.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<F, A>, _ ff: HK<F, (A) -> B>) -> HK<F, B> {
        return fa.ev().ap(ff.ev())
    }
}

public class EvalEq<B, EqB> : Eq where EqB : Eq, EqB.A == B {
    public typealias A = HK<EvalF, B>
    
    private let eq : EqB
    
    public init(_ eq : EqB) {
        self.eq = eq
    }
    
    public func eqv(_ a: HK<EvalF, B>, _ b: HK<EvalF, B>) -> Bool {
        return eq.eqv(a.ev().value(), b.ev().value())
    }
}

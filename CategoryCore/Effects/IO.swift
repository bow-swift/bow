//
//  IO.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class IOF {}

public class IO<A> : HK<IOF, A> {
    
    public static func pure(_ a : A) -> IO<A> {
        return Pure(a)
    }
    
    public static func ev(_ fa : HK<IOF, A>) -> IO<A> {
        return fa as! IO<A>
    }
    
    public static func raiseError(_ error : Error) -> IO<A> {
        return RaiseError(error)
    }
    
    internal static func mapDefault<B>(_ t : IO<A>, _ f : @escaping (A) throws -> B) -> IO<B> {
        return t.flatMap(f >>> IO<B>.pure)
    }
    
    internal static func attemptValue() -> AndThen<A, IO<Either<Error, A>>> {
        return AndThen.create({ (a : A) in Pure(Either.right(a)) },
                              { (e : Error) in Pure(Either.left(e)) })
    }
    
    public static func invoke(_ f : @escaping () throws -> A) -> IO<A> {
        return suspend({ Pure(try f()) })
    }
    
    public static func suspend(_ f : @escaping () throws -> IO<A>) -> IO<A> {
        return Suspend(AndThen.create({ _ in
            do {
                return try f()
            } catch {
                return raiseError(error)
            }
        }))
    }
    
    public static func runAsync(_ proc : @escaping Proc<A>) -> IO<A> {
        let g : Proc<A> = { (f : Callback<A>) in
            run(f)
        }
        
        func run(_ callback : (Either<Error, A>) -> Unit) {
            do {
                try proc(callback)
            } catch {
                callback(Either<Error, A>.left(error))
            }
        }
        
        return Async<A>(Effects.onceOnly(g))
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> HK<IOF, Either<A, B>>) -> IO<B> {
        return IO<Either<A, B>>.ev(f(a)).flatMap { either in
            either.fold({ a in tailRecM(a, f) },
                        { b in IO<B>.pure(b) })
        }
    }
    
    public func map<B>(_ f : @escaping (A) throws -> B) -> IO<B> {
        fatalError("IO map must be implemented by subclasses")
    }
    
    public func ap<B>(_ ff : IO<(A) -> B>) -> IO<B> {
        return flatMap({ a in ff.map({ f in f(a) })})
    }
    
    internal func flatMapTotal<B>(_ f : AndThen<A, IO<B>>) -> IO<B> {
        fatalError("IO flatMapTotal must be implemented by subclasses")
    }
    
    public func flatMap<B>(_ f : @escaping (A) throws -> IO<B>) -> IO<B> {
        return flatMapTotal(AndThen<A, IO<B>>.create({ (a : A) in
            do {
                return try f(a)
            } catch {
                return RaiseError(error)
            }
        }))
    }
    
    public func attempt() -> IO<Either<Error, A>> {
        fatalError("IO attempt must be implemented by subclasses")
    }
    
    public func runAsync(_ callback : @escaping (Either<Error, A>) -> IO<Unit>) -> IO<Unit> {
        return IO<Unit>.invoke({ self.unsafeRunAsync(callback >>> { (io : IO<Unit>) in io.unsafeRunAsync({ _ in unit }) }) })
    }
    
    public func unsafeRunAsync(_ callback : @escaping Callback<A>) -> Unit {
        return try! unsafeStep().unsafeRunAsyncTotal(callback)
    }
    
    internal func unsafeRunAsyncTotal(_ callback : @escaping Callback<A>) throws {
        fatalError("IO unsafeRunAsyncTotal must be implemented by subclasses")
    }
    
    func unsafeStep() -> IO<A> {
        var current = self
        var continues = true
        while continues {
            do {
                (current, continues) = try current.unsafeStepChildren()
            } catch {
                return RaiseError(error)
            }
        }
        return current
    }
    
    internal func unsafeStepChildren() throws -> (IO<A>, Bool) {
        return (self, false)
    }
    
    public func handleErrorWith(_ f : @escaping (Error) -> HK<IOF, A>) -> IO<A> {
        return attempt().flatMap{ either in IO.ev(either.fold(f, IO<A>.pure)) }
    }
}

fileprivate class Pure<A> : IO<A> {
    let a : A
    
    init(_ a : A) {
        self.a = a
    }
    
    override func map<B>(_ f: @escaping (A) throws -> B) -> IO<B> {
        do {
            return Pure<B>(try f(a))
        } catch {
            return RaiseError<B>(error)
        }
    }
    
    override func flatMapTotal<B>(_ f: AndThen<A, IO<B>>) -> IO<B> {
        return Suspend(AndThen.create({ _ in self.a }).andThen(f))
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return Pure<Either<Error, A>>(Either.right(a))
    }
    
    override func unsafeRunAsyncTotal(_ callback: @escaping (Either<Error, A>) -> Unit) throws {
        callback(Either.right(a))
    }
}

fileprivate class RaiseError<A> : IO<A> {
    let error : Error
    
    init(_ error : Error) {
        self.error = error
    }
    
    override func map<B>(_ f: @escaping (A) throws -> B) -> IO<B> {
        return RaiseError<B>(error)
    }
    
    override func flatMapTotal<B>(_ f: AndThen<A, IO<B>>) -> IO<B> {
        return Suspend<B>(AndThen.create({ _ in f.error(self.error, { e in RaiseError<B>(e) })}))
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return Pure(Either.left(error))
    }
    
    override func unsafeRunAsyncTotal(_ callback: @escaping (Either<Error, A>) -> Unit) throws {
        callback(Either.left(error))
    }
}

fileprivate class Suspend<A> : IO<A> {
    let cont : AndThen<Unit, IO<A>>
    
    init(_ cont : AndThen<Unit, IO<A>>) {
        self.cont = cont
    }
    
    override func unsafeStepChildren() throws -> (IO<A>, Bool) {
        return (try cont.invoke(unit), true)
    }
    
    override func map<B>(_ f: @escaping (A) throws -> B) -> IO<B> {
        return IO.mapDefault(self, f)
    }
    
    override func flatMapTotal<B>(_ f: AndThen<A, IO<B>>) -> IO<B> {
        return BindSuspend(cont, f)
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return BindSuspend(cont, IO.attemptValue())
    }
    
    override func unsafeRunAsyncTotal(_ callback: @escaping (Either<Error, A>) -> Unit) throws {
        fatalError("Unreachable code")
    }
}

fileprivate class BindSuspend<E, A> : IO<A> {
    let cont : AndThen<Unit, IO<E>>
    let f : AndThen<E, IO<A>>
    
    init(_ cont : AndThen<Unit, IO<E>>, _ f : AndThen<E, IO<A>>) {
        self.cont = cont
        self.f = f
    }
    
    override func unsafeStepChildren() throws -> (IO<A>, Bool) {
        let cont = try self.cont.invoke(unit)
        return (cont.flatMapTotal(f), true)
    }
    
    override func map<B>(_ f: @escaping (A) throws -> B) -> IO<B> {
        return IO.mapDefault(self, f)
    }
    
    override func flatMapTotal<B>(_ ff: AndThen<A, IO<B>>) -> IO<B> {
        return BindSuspend<E, B>(cont, f.andThen(AndThen.create({ a in a.flatMapTotal(ff) }, { e in ff.error(e, { ee in RaiseError(ee) })})))
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return BindSuspend<A, Either<Error, A>>(AndThen.create({ _ in self }), IO.attemptValue())
    }
    
    override func unsafeRunAsyncTotal(_ callback: @escaping (Either<Error, A>) -> Unit) throws {
        fatalError("Unreachable code")
    }
}

fileprivate class Async<A> : IO<A> {
    let cont : Proc<A>
    
    init(_ cont : @escaping Proc<A>) {
        self.cont = cont
    }
    
    override func map<B>(_ f: @escaping (A) throws -> B) -> IO<B> {
        return IO.mapDefault(self, f)
    }
    
    override func flatMapTotal<B>(_ f: AndThen<A, IO<B>>) -> IO<B> {
        return BindAsync(cont, f)
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return BindAsync(cont, IO.attemptValue())
    }
    
    override func unsafeRunAsyncTotal(_ callback: @escaping (Either<Error, A>) -> Unit) throws {
        try cont(callback)
    }
}

fileprivate class BindAsync<E, A> : IO<A> {
    let cont : Proc<E>
    let f : AndThen<E, IO<A>>
    
    init(_ cont : @escaping Proc<E>, _ f : AndThen<E, IO<A>>) {
        self.cont = cont
        self.f = f
    }
    
    override func map<B>(_ f: @escaping (A) throws -> B) -> IO<B> {
        return IO.mapDefault(self, f)
    }
    
    override func flatMapTotal<B>(_ ff: AndThen<A, IO<B>>) -> IO<B> {
        return BindAsync<E, B>(cont, f.andThen(AndThen.create({ a in a.flatMapTotal(ff) }, { e in ff.error(e, { ee in RaiseError(ee) })})))
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return BindSuspend<A, Either<Error, A>>(AndThen.create({ _ in self }), IO.attemptValue())
    }
    
    override func unsafeRunAsyncTotal(_ callback: @escaping (Either<Error, A>) -> Unit) throws {
        try cont({ result in
            do {
                switch result {
                case is Left<Error, E>:
                    f.error((result as! Left<Error, E>).a, { e in RaiseError(e)}).unsafeRunAsync(callback)
                case is Right<Error, E>:
                    try f.invoke((result as! Right<Error, E>).b).unsafeRunAsync(callback)
                default:
                    fatalError("No more cases")
                }
            } catch {
                callback(Either.left(error))
            }
        })
    }
}

public extension HK where F == IOF {
    public func ev() -> IO<A> {
        return self as! IO<A>
    }
}

public extension IO {
    public static func functor() -> IOFunctor {
        return IOFunctor()
    }
    
    public static func applicative() -> IOApplicative {
        return IOApplicative()
    }
    
    public static func monad() -> IOMonad {
        return IOMonad()
    }
    
    public static func asyncContext() -> IOAsyncContext {
        return IOAsyncContext()
    }
    
    public static func monadError() -> IOMonadError {
        return IOMonadError()
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> IOSemigroup<A, SemiG> {
        return IOSemigroup<A, SemiG>(semigroup)
    }
    
    public static func monoid<Mono>(_ monoid : Mono) -> IOMonoid<A, Mono> {
        return IOMonoid<A, Mono>(monoid)
    }
}

public class IOFunctor : Functor {
    public typealias F = IOF
    
    public func map<A, B>(_ fa: HK<IOF, A>, _ f: @escaping (A) -> B) -> HK<IOF, B> {
        return IO.ev(fa).map(f)
    }
}

public class IOApplicative : IOFunctor, Applicative {
    public func pure<A>(_ a: A) -> HK<IOF, A> {
        return IO.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<IOF, A>, _ ff: HK<IOF, (A) -> B>) -> HK<IOF, B> {
        return fa.ev().ap(ff.ev())
    }
}

public class IOMonad : IOApplicative, Monad {
    public func flatMap<A, B>(_ fa: HK<IOF, A>, _ f: @escaping (A) -> HK<IOF, B>) -> HK<IOF, B> {
        return fa.ev().flatMap({ a in f(a).ev() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<IOF, Either<A, B>>) -> HK<IOF, B> {
        return IO.tailRecM(a, f)
    }
}

public class IOAsyncContext : AsyncContext {
    public typealias F = IOF
    
    public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> Unit) throws -> Unit) -> HK<IOF, A> {
        return IO.runAsync(fa)
    }
}

public class IOMonadError : IOMonad, MonadError {
    public typealias E = Error
    
    public func raiseError<A>(_ e: Error) -> HK<IOF, A> {
        return IO.raiseError(e)
    }
    
    public func handleErrorWith<A>(_ fa: HK<IOF, A>, _ f: @escaping (Error) -> HK<IOF, A>) -> HK<IOF, A> {
        return fa.ev().handleErrorWith(f)
    }
}

public class IOSemigroup<B, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == B {
    public typealias A = HK<IOF, B>
    
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: HK<IOF, B>, _ b: HK<IOF, B>) -> HK<IOF, B> {
        return a.ev().flatMap { aa in b.ev().map { bb in self.semigroup.combine(aa, bb) } }
    }
}

public class IOMonoid<B, Mono> : IOSemigroup<B, Mono>, Monoid where Mono : Monoid, Mono.A == B {
    private let monoid : Mono
    
    override public init(_ monoid : Mono) {
        self.monoid = monoid
        super.init(monoid)
    }
    
    public var empty: HK<IOF, B> {
        return IO.pure(monoid.empty)
    }
}

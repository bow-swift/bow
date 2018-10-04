import Foundation
import RxSwift

public class ForMaybeK {}
public typealias MaybeKOf<A> = Kind<ForMaybeK, A>

public extension PrimitiveSequence where Trait == MaybeTrait {
    public func k() -> MaybeK<Element> {
        return MaybeK(self)
    }
}

public class MaybeK<A> : MaybeKOf<A> {
    public let value : Maybe<A>
    
    public static func fix(_ value : MaybeKOf<A>) -> MaybeK<A> {
        return value as! MaybeK<A>
    }
    
    public static func pure(_ a : A) -> MaybeK<A> {
        return Maybe.just(a).k()
    }
    
    public static func raiseError(_ error : Error) -> MaybeK<A> {
        return Maybe.error(error).k()
    }
    
    public static func from(_ f : @escaping () -> A) -> MaybeK<A> {
        return suspend { pure(f()) }
    }
    
    public static func suspend(_ f : @escaping () -> MaybeKOf<A>) -> MaybeK<A> {
        return Maybe.deferred { f().fix().value }.k()
    }
    
    public static func async(_ fa : @escaping Proc<A>) -> MaybeK<A> {
        return Maybe.create { emitter in
            do {
                try fa { either in
                    either.fold({ e in emitter(.error(e)) },
                                { a in emitter(.success(a)) })
                }
            } catch {}
            return Disposables.create()
        }.k()
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> MaybeKOf<Either<A, B>>) -> MaybeK<B> {
        let either = f(a).fix().value.blockingGet()!
        return either.fold({ a in tailRecM(a, f) },
                           { b in Maybe.just(b).k() })
    }
    
    public init(_ value : Maybe<A>) {
        self.value = value
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> MaybeK<B> {
        return value.map(f).k()
    }
    
    public func ap<B>(_ fa : MaybeKOf<(A) -> B>) -> MaybeK<B> {
        return flatMap { a in fa.fix().map{ ff in ff(a) } }
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> MaybeK<B>) -> MaybeK<B> {
        return value.flatMap { a in f(a).fix().value }.k()
    }
    
    public func fold<B>(_ ifEmpty : @escaping () -> B, _ ifSome : @escaping (A) -> B) -> B {
        if let result = value.blockingGet() {
            return ifSome(result)
        } else {
            return ifEmpty()
        }
    }
    
    public func foldLeft<B>(_ b : B, _ f : @escaping (B, A) -> B) -> B {
        return fold(constant(b), { a in f(b, a) })
    }
    
    public func foldRight<B>(_ lb : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.deferEvaluation { self.fold(constant(lb), { a in f(a, lb) }) }
    }
    
    public var isEmpty : Bool {
        return value.blockingGet() == nil
    }
    
    public var nonEmpty : Bool {
        return !isEmpty
    }
    
    public func exists(_ predicate : @escaping (A) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    public func forall(_ predicate : @escaping (A) -> Bool) -> Bool {
        return fold(constant(true), predicate)
    }
    
    public func handleErrorWith(_ f : @escaping (Error) -> MaybeK<A>) -> MaybeK<A> {
        return value.catchError { e in f(e).value }.k()
    }
    
    public func runAsync(_ callback : @escaping (Either<Error, A>) -> MaybeKOf<Unit>) -> MaybeK<Unit> {
        return value.flatMap { a in callback(Either.right(a)).fix().value }
            .catchError { e in callback(Either.left(e)).fix().value }.k()
    }
}

public extension Kind where F == ForMaybeK {
    public func fix() -> MaybeK<A> {
        return MaybeK<A>.fix(self)
    }
}

public extension MaybeK {
    public static func functor() -> MaybeKFunctor {
        return MaybeKFunctor()
    }
    
    public static func applicative() -> MaybeKApplicative {
        return MaybeKApplicative()
    }
    
    public static func monad() -> MaybeKMonad {
        return MaybeKMonad()
    }
    
    public static func foldable() -> MaybeKFoldable {
        return MaybeKFoldable()
    }
    
    public static func applicativeError() -> MaybeKApplicativeError {
        return MaybeKApplicativeError()
    }
    
    public static func monadError() -> MaybeKMonadError {
        return MaybeKMonadError()
    }
    
    public static func monadDefer() -> MaybeKMonadDefer {
        return MaybeKMonadDefer()
    }
    
    public static func async() -> MaybeKAsync {
        return MaybeKAsync()
    }
    
    public static func effect() -> MaybeKEffect {
        return MaybeKEffect()
    }
}

public class MaybeKFunctor : Functor {
    public typealias F = ForMaybeK
    
    public func map<A, B>(_ fa: MaybeKOf<A>, _ f: @escaping (A) -> B) -> MaybeKOf<B> {
        return fa.fix().map(f)
    }
}

public class MaybeKApplicative : MaybeKFunctor, Applicative {
    public func pure<A>(_ a: A) -> MaybeKOf<A> {
        return MaybeK.pure(a)
    }
    
    public func ap<A, B>(_ fa: MaybeKOf<A>, _ ff: MaybeKOf<(A) -> B>) -> MaybeKOf<B> {
        return fa.fix().ap(ff)
    }
}

public class MaybeKMonad : MaybeKApplicative, Monad {
    public func flatMap<A, B>(_ fa: MaybeKOf<A>, _ f: @escaping (A) -> MaybeKOf<B>) -> MaybeKOf<B> {
        return fa.fix().flatMap { a in f(a).fix() }
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> MaybeKOf<Either<A, B>>) -> MaybeKOf<B> {
        return MaybeK.tailRecM(a, f)
    }
}

public class MaybeKFoldable : Foldable {
    public typealias F = ForMaybeK
    
    public func foldL<A, B>(_ fa: MaybeKOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldR<A, B>(_ fa: MaybeKOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class MaybeKApplicativeError : MaybeKApplicative, ApplicativeError {
    public typealias E = Error

    public func raiseError<A>(_ e: Error) -> MaybeKOf<A> {
        return MaybeK.raiseError(e)
    }
    
    public func handleErrorWith<A>(_ fa: MaybeKOf<A>, _ f: @escaping (Error) -> MaybeKOf<A>) -> MaybeKOf<A> {
        return fa.fix().handleErrorWith { e in f(e).fix() }
    }
}

public class MaybeKMonadError : MaybeKMonad, MonadError {
    public typealias E = Error
    
    public func raiseError<A>(_ e: Error) -> MaybeKOf<A> {
        return MaybeK.raiseError(e)
    }
    
    public func handleErrorWith<A>(_ fa: MaybeKOf<A>, _ f: @escaping (Error) -> MaybeKOf<A>) -> MaybeKOf<A> {
        return fa.fix().handleErrorWith { e in f(e).fix() }
    }
}

public class MaybeKMonadDefer : MaybeKMonadError, MonadDefer {
    public func suspend<A>(_ fa: @escaping () -> MaybeKOf<A>) -> MaybeKOf<A> {
        return MaybeK.suspend(fa)
    }
}

public class MaybeKAsync : MaybeKMonadDefer, Async {
    public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> Unit) throws -> Unit) -> MaybeKOf<A> {
        return MaybeK.async(fa)
    }
}

public class MaybeKEffect : MaybeKAsync, Effect {
    public func runAsync<A>(_ fa: MaybeKOf<A>, _ callback: @escaping (Either<Error, A>) -> MaybeKOf<Unit>) -> MaybeKOf<Unit> {
        return fa.fix().runAsync(callback)
    }
}

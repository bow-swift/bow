import Foundation
import BrightFutures
import Bow
import BowEffects

public class ForFutureK {}
public typealias FutureKOf<E, A> = Kind2<ForFutureK, E, A>
public typealias FutureKPartial<E> = Kind<ForFutureK, E>

public extension Future {
    public func k() -> FutureK<E, T> {
        return FutureK(self)
    }
}

public class FutureK<E, A> : FutureKOf<E, A> where E : Error {
    public let value : Future<A, E>
    
    public static func fix(_ value : FutureKOf<E, A>) -> FutureK<E, A> {
        return value as! FutureK<E, A>
    }
    
    public static func pure(_ a : A) -> FutureK<E, A> {
        return Future(value: a).k()
    }
    
    public static func raiseError(_ e : E) -> FutureK<E, A> {
        return Future(error: e).k()
    }
    
    public static func from(_ f : @escaping () -> A) -> FutureK<E, A> {
        return Future { complete in complete(.success(f())) }.k()
    }
    
    public static func suspend(_ fa : @escaping () -> FutureKOf<E, A>) -> FutureK<E, A> {
        return FutureK<E, A>.fix(fa())
    }
    
    public static func runAsync(_ fa : @escaping ((Either<E, A>) -> ()) throws -> ()) -> FutureK<E, A> {
        return Future { complete in
            do {
                try fa { either in
                    either.fold({ e in complete(.failure(e)) },
                                { a in complete(.success(a)) })
                }
            } catch {}
        }.k()
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> FutureKOf<E, Either<A, B>>) -> FutureK<E, B> {
        let either = FutureK<E, Either<A, B>>.fix(f(a)).value.value!
        return either.fold({ a in tailRecM(a, f) },
                           { b in FutureK<E, B>.pure(b) })
    }
    
    public init(_ value : Future<A, E>) {
        self.value = value
    }
    
    public var isCompleted : Bool {
        return value.isCompleted
    }
    
    public var isSuccess : Bool {
        return value.isSuccess
    }
    
    public var isFailure : Bool {
        return value.isFailure
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> FutureK<E, B> {
        return value.map(f).k()
    }
    
    public func ap<AA, B>(_ fa : FutureKOf<E, AA>) -> FutureK<E, B> where A == (AA) -> B {
        return FutureK<E, AA>.fix(fa).flatMap { a in self.map { ff in ff(a) } }
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> FutureKOf<E, B>) -> FutureK<E, B> {
        return value.flatMap { (a : A) -> Future<B, E> in FutureK<E, B>.fix(f(a)).value }.k()
    }
    
    public func handleErrorWith(_ f : @escaping (E) -> FutureKOf<E, A>) -> FutureK<E, A> {
        return value.recoverWith { e in FutureK<E, A>.fix(f(e)).value }.k()
    }
    
    public func runAsync(_ callback : @escaping (Either<E, A>) -> FutureKOf<E, ()>) -> FutureK<E, ()> {
        return value.flatMap { a in FutureK<E, ()>.fix(callback(Either.right(a))).value }
            .recoverWith { e in FutureK<E, ()>.fix(callback(Either.left(e))).value }.k()
    }
}

public extension FutureK {
    public static func functor() -> FunctorInstance<E> {
        return FunctorInstance<E>()
    }
    
    public static func applicative() -> ApplicativeInstance<E> {
        return ApplicativeInstance<E>()
    }
    
    public static func monad() -> MonadInstance<E> {
        return MonadInstance<E>()
    }
    
    public static func applicativeError() -> ApplicativeErrorInstance<E> {
        return ApplicativeErrorInstance<E>()
    }
    
    public static func monadError() -> MonadErrorInstance<E> {
        return MonadErrorInstance<E>()
    }
    
    public static func monadDefer() -> MonadDeferInstance<E> {
        return MonadDeferInstance<E>()
    }
    
    public static func async() -> AsyncInstance<E> {
        return AsyncInstance<E>()
    }
    
    public static func effect() -> EffectInstance<E> {
        return EffectInstance<E>()
    }

    public class FunctorInstance<E> : Functor where E : Error {
        public typealias F = FutureKPartial<E>
        
        public func map<A, B>(_ fa: FutureKOf<E, A>, _ f: @escaping (A) -> B) -> FutureKOf<E, B> {
            return FutureK<E, A>.fix(fa).map(f)
        }
    }

    public class ApplicativeInstance<E> : FunctorInstance<E>, Applicative where E : Error {
        public func pure<A>(_ a: A) -> FutureKOf<E, A> {
            return FutureK<E, A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: FutureKOf<E, (A) -> B>, _ fa: FutureKOf<E, A>) -> FutureKOf<E, B> {
            return FutureK<E, (A) -> B>.fix(ff).ap(fa)
        }
    }

    public class MonadInstance<E> : ApplicativeInstance<E>, Monad where E : Error {
        public func flatMap<A, B>(_ fa: FutureKOf<E, A>, _ f: @escaping (A) -> FutureKOf<E, B>) -> FutureKOf<E, B> {
            return FutureK<E, A>.fix(fa).flatMap(f)
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> FutureKOf<E, Either<A, B>>) -> FutureKOf<E, B> {
            return FutureK<E, A>.tailRecM(a, f)
        }
    }

    public class ApplicativeErrorInstance<Err> : ApplicativeInstance<Err>, ApplicativeError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> FutureKOf<E, A> {
            return FutureK<E, A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: FutureKOf<E, A>, _ f: @escaping (Err) -> FutureKOf<E, A>) -> FutureKOf<E, A> {
            return FutureK<E, A>.fix(fa).handleErrorWith(f)
        }
    }

    public class MonadErrorInstance<Err> : MonadInstance<Err>, MonadError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> FutureKOf<E, A> {
            return FutureK<E, A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: FutureKOf<E, A>, _ f: @escaping (Err) -> FutureKOf<E, A>) -> FutureKOf<E, A> {
            return FutureK<E, A>.fix(fa).handleErrorWith(f)
        }
    }

    public class MonadDeferInstance<Err> : MonadErrorInstance<Err>, MonadDefer where Err : Error {
        public func suspend<A>(_ fa: @escaping () -> FutureKOf<E, A>) -> FutureKOf<E, A> {
            return FutureK<E, A>.suspend(fa)
        }
    }

    public class AsyncInstance<Err> : MonadDeferInstance<Err>, BowEffects.Async where Err : Error {
        public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> FutureKOf<E, A> {
            return Future { complete in
                do {
                    try fa { either in
                        either.fold({ e in complete(.failure(e as! E)) },
                                    { a in complete(.success(a)) })
                    }
                } catch {}
            }.k()
        }
    }

    public class EffectInstance<Err> : AsyncInstance<Err>, Effect where Err : Error {
        public func runAsync<A>(_ fa: FutureKOf<E, A>, _ callback: @escaping (Either<Error, A>) -> FutureKOf<E, ()>) -> FutureKOf<E, ()> {
            return FutureK<E, A>.fix(fa).value
                .flatMap { a in FutureK<E, ()>.fix(callback(Either.right(a))).value }
                .recoverWith { e in FutureK<E, ()>.fix(callback(Either.left(e))).value }.k()
        }
    }
}

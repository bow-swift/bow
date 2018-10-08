import Foundation
import BrightFutures

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
    
    public static func runAsync(_ fa : @escaping ((Either<E, A>) -> Unit) throws -> Unit) -> FutureK<E, A> {
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
    
    public func ap<B>(_ fa : FutureKOf<E, (A) -> B>) -> FutureK<E, B> {
        return flatMap { a in FutureK<E, (A) -> B>.fix(fa).map { ff in ff(a) } }
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> FutureKOf<E, B>) -> FutureK<E, B> {
        return value.flatMap { (a : A) -> Future<B, E> in FutureK<E, B>.fix(f(a)).value }.k()
    }
    
    public func handleErrorWith(_ f : @escaping (E) -> FutureKOf<E, A>) -> FutureK<E, A> {
        return value.recoverWith { e in FutureK<E, A>.fix(f(e)).value }.k()
    }
    
    public func runAsync(_ callback : @escaping (Either<E, A>) -> FutureKOf<E, Unit>) -> FutureK<E, Unit> {
        return value.flatMap { a in FutureK<E, Unit>.fix(callback(Either.right(a))).value }
            .recoverWith { e in FutureK<E, Unit>.fix(callback(Either.left(e))).value }.k()
    }
}

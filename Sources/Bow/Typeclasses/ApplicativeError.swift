import Foundation

public protocol ApplicativeError : Applicative {
    associatedtype E
    
    func raiseError<A>(_ e : E) -> Kind<F, A>
    func handleErrorWith<A>(_ fa : Kind<F, A>, _ f : @escaping (E) -> Kind<F, A>) -> Kind<F, A>
}

public extension ApplicativeError {
    public func handleError<A>(_ fa : Kind<F, A>, _ f : @escaping (E) -> A) -> Kind<F, A> {
        return handleErrorWith(fa, { a in self.pure(f(a)) })
    }
    
    public func attempt<A>(_ fa : Kind<F, A>) -> Kind<F, Either<E, A>> {
        return handleErrorWith(map(fa, Either<E, A>.right), { e in self.pure(Either<E, A>.left(e)) })
    }
    
    public func fromEither<A>(_ fea : Either<E, A>) -> Kind<F, A> {
        return fea.fold(raiseError, pure)
    }
    
    public func catchError<A>(_ f : () throws -> A, recover : (Error) -> E) -> Kind<F, A> {
        do {
            return pure(try f())
        } catch {
            return raiseError(recover(error))
        }
    }
    
    public func catchError<A>(_ f : () throws -> A) -> Kind<F, A> where Self.E == Error {
        do {
            return pure(try f())
        } catch {
            return raiseError(error)
        }
    }
}

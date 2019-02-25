import Foundation

public protocol ApplicativeError: Applicative {
    associatedtype E
    
    static func raiseError<A>(_ e: E) -> Kind<Self, A>
    static func handleErrorWith<A>(_ fa: Kind<Self, A>, _ f: @escaping (E) -> Kind<Self, A>) -> Kind<Self, A>
}

public extension ApplicativeError {
    public static func handleError<A>(_ fa: Kind<Self, A>, _ f: @escaping (E) -> A) -> Kind<Self, A> {
        return handleErrorWith(fa, { a in self.pure(f(a)) })
    }
    
    public static func attempt<A>(_ fa: Kind<Self, A>) -> Kind<Self, Either<E, A>> {
        return handleErrorWith(map(fa, Either<E, A>.right), { e in self.pure(Either<E, A>.left(e)) })
    }
    
    public static func fromEither<A>(_ fea: Either<E, A>) -> Kind<Self, A> {
        return fea.fold(raiseError, pure)
    }
    
    public static func catchError<A>(_ f: () throws -> A, _ recover: (Error) -> E) -> Kind<Self, A> {
        do {
            return pure(try f())
        } catch {
            return raiseError(recover(error))
        }
    }
    
    public static func catchError<A>(_ f: () throws -> A) -> Kind<Self, A> where Self.E == Error {
        do {
            return pure(try f())
        } catch {
            return raiseError(error)
        }
    }
}

// MARK: Syntax for ApplicativeError

public extension Kind where F: ApplicativeError {
    public static func raiseError(_ e: F.E) -> Kind<F, A> {
        return F.raiseError(e)
    }

    public func handleErrorWith(_ f: @escaping (F.E) -> Kind<F, A>) -> Kind<F, A> {
        return F.handleErrorWith(self, f)
    }

    public func handleError(_ f: @escaping (F.E) -> A) -> Kind<F, A> {
        return F.handleError(self, f)
    }

    public func attempt() -> Kind<F, Either<F.E, A>> {
        return F.attempt(self)
    }

    public static func fromEither(_ fea: Either<F.E, A>) -> Kind<F, A> {
        return F.fromEither(fea)
    }

    public static func catchError(_ f: () throws -> A, _ recover: (Error) -> F.E) -> Kind<F, A> {
        return F.catchError(f, recover)
    }
}

public extension Kind where F: ApplicativeError, F.E == Error {
    public static func catchError(_ f: () throws -> A) -> Kind<F, A> {
        return F.catchError(f)
    }
}

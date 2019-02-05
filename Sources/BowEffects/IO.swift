import Foundation
import Bow

public final class ForIO {}
public typealias IOOf<A> = Kind<ForIO, A>

public class IO<A> : IOOf<A> {
    public static func fix(_ fa : IOOf<A>) -> IO<A> {
        return fa.fix()
    }
    
    public static func pure(_ a : A) -> IO<A> {
        return Pure(a)
    }
    
    public static func invoke(_ f : @escaping () throws -> A) -> IO<A> {
        return suspend({ try Pure(f()) })
    }
    
    public static func suspend(_ f : @escaping () throws -> IO<A>) -> IO<A> {
        return Pure<()>(()).flatMap(f)
    }
    
    public static func raiseError(_ error : Error) -> IO<A> {
        return RaiseError(error)
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> IOOf<Either<A, B>>) -> IO<B> {
        return IO<Either<A, B>>.fix(f(a)).flatMap { either in
            either.fold({ a in tailRecM(a, f) },
                        { b in IO<B>.pure(b) })
        }
    }
    
    public static func runAsync(_ proc : @escaping Proc<A>) -> IO<A> {
        return AsyncIO(proc)
    }
    
    public static func merge<B>(_ fa : @escaping () throws -> A,
                                _ fb : @escaping () throws -> B) -> IO<(A, B)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb)).fix()
    }
    
    public static func merge<B, C>(_ fa : @escaping () throws -> A,
                                   _ fb : @escaping () throws -> B,
                                   _ fc : @escaping () throws -> C) -> IO<(A, B, C)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc)).fix()
    }
    
    public static func merge<B, C, D>(_ fa : @escaping () throws -> A,
                                      _ fb : @escaping () throws -> B,
                                      _ fc : @escaping () throws -> C,
                                      _ fd : @escaping () throws -> D) -> IO<(A, B, C, D)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc),
                                       IO<D>.invoke(fd)).fix()
    }
    
    public static func merge<B, C, D, E>(_ fa : @escaping () throws -> A,
                                         _ fb : @escaping () throws -> B,
                                         _ fc : @escaping () throws -> C,
                                         _ fd : @escaping () throws -> D,
                                         _ fe : @escaping () throws -> E) -> IO<(A, B, C, D, E)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc),
                                       IO<D>.invoke(fd),
                                       IO<E>.invoke(fe)).fix()
    }
    
    public static func merge<B, C, D, E, F>(_ fa : @escaping () throws -> A,
                                            _ fb : @escaping () throws -> B,
                                            _ fc : @escaping () throws -> C,
                                            _ fd : @escaping () throws -> D,
                                            _ fe : @escaping () throws -> E,
                                            _ ff : @escaping () throws -> F) -> IO<(A, B, C, D, E, F)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc),
                                       IO<D>.invoke(fd),
                                       IO<E>.invoke(fe),
                                       IO<F>.invoke(ff)).fix()
    }
    
    public static func merge<B, C, D, E, F, G>(_ fa : @escaping () throws -> A,
                                               _ fb : @escaping () throws -> B,
                                               _ fc : @escaping () throws -> C,
                                               _ fd : @escaping () throws -> D,
                                               _ fe : @escaping () throws -> E,
                                               _ ff : @escaping () throws -> F,
                                               _ fg : @escaping () throws -> G) -> IO<(A, B, C, D, E, F, G)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc),
                                       IO<D>.invoke(fd),
                                       IO<E>.invoke(fe),
                                       IO<F>.invoke(ff),
                                       IO<G>.invoke(fg)).fix()
    }
    
    public static func merge<B, C, D, E, F, G, H>(_ fa : @escaping () throws -> A,
                                                  _ fb : @escaping () throws -> B,
                                                  _ fc : @escaping () throws -> C,
                                                  _ fd : @escaping () throws -> D,
                                                  _ fe : @escaping () throws -> E,
                                                  _ ff : @escaping () throws -> F,
                                                  _ fg : @escaping () throws -> G,
                                                  _ fh : @escaping () throws -> H) -> IO<(A, B, C, D, E, F, G, H)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc),
                                       IO<D>.invoke(fd),
                                       IO<E>.invoke(fe),
                                       IO<F>.invoke(ff),
                                       IO<G>.invoke(fg),
                                       IO<H>.invoke(fh)).fix()
    }
    
    public static func merge<B, C, D, E, F, G, H, I>(_ fa : @escaping () throws -> A,
                                                     _ fb : @escaping () throws -> B,
                                                     _ fc : @escaping () throws -> C,
                                                     _ fd : @escaping () throws -> D,
                                                     _ fe : @escaping () throws -> E,
                                                     _ ff : @escaping () throws -> F,
                                                     _ fg : @escaping () throws -> G,
                                                     _ fh : @escaping () throws -> H,
                                                     _ fi : @escaping () throws -> I) -> IO<(A, B, C, D, E, F, G, H, I)> {
        return IO.applicative().tupled(IO<A>.invoke(fa),
                                       IO<B>.invoke(fb),
                                       IO<C>.invoke(fc),
                                       IO<D>.invoke(fd),
                                       IO<E>.invoke(fe),
                                       IO<F>.invoke(ff),
                                       IO<G>.invoke(fg),
                                       IO<H>.invoke(fh),
                                       IO<I>.invoke(fi)).fix()
    }
    
    public func unsafePerformIO() throws -> A {
        fatalError("Implement in subclasses")
    }
    
    public func attempt() -> IO<Either<Error, A>>{
        fatalError("Implement in subclasses")
    }
    
    public func unsafeRunAsync(_ callback : Callback<A>) {
        do {
            callback(Either.right(try unsafePerformIO()))
        } catch {
            callback(Either.left(error))
        }
    }
    
    public func map<B>(_ f : @escaping (A) throws -> B) -> IO<B> {
        return FMap(f, self)
    }
    
    public func ap<AA, B>(_ fa : IO<AA>) -> IO<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func flatMap<B>(_ f : @escaping (A) throws -> IO<B>) -> IO<B> {
        return Join(self.map(f))
    }
    
    public func handleErrorWith(_ f : @escaping (Error) -> IOOf<A>) -> IO<A> {
        return attempt().flatMap{ either in either.fold({ e in f(e).fix() }, IO<A>.pure) }
    }
}

fileprivate class Pure<A> : IO<A> {
    let a : A
    
    init(_ a : A) {
        self.a = a
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return Pure<Either<Error, A>>(Either<Error, A>.right(a))
    }
    
    override func unsafePerformIO() throws -> A {
        return a
    }
}

fileprivate class RaiseError<A> : IO<A> {
    let error : Error
    
    init(_ error : Error) {
        self.error = error
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        return Pure<Either<Error, A>>(Either<Error, A>.left(error))
    }
    
    override func unsafePerformIO() throws -> A {
        throw error
    }
}

fileprivate class FMap<A, B> : IO<B> {
    let f : (A) throws -> B
    let action : IO<A>
    
    init(_ f : @escaping (A) throws -> B, _ action : IO<A>) {
        self.f = f
        self.action = action
    }
    
    override func attempt() -> IO<Either<Error, B>> {
        do {
            return try Pure<Either<Error, B>>(Either<Error, B>.right(self.unsafePerformIO()))
        } catch {
            return Pure<Either<Error, B>>(Either<Error, B>.left(error))
        }
    }
    
    override func unsafePerformIO() throws -> B {
        return try f(try action.unsafePerformIO())
    }
}

fileprivate class Join<A> : IO<A> {
    let io : IO<IO<A>>
    
    init(_ io : IO<IO<A>>) {
        self.io = io
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        do {
            return try Pure<Either<Error, A>>(Either<Error, A>.right(self.unsafePerformIO()))
        } catch {
            return Pure<Either<Error, A>>(Either<Error, A>.left(error))
        }
    }
    
    override func unsafePerformIO() throws -> A {
        return try io.unsafePerformIO().unsafePerformIO()
    }
}

fileprivate class AsyncIO<A> : IO<A> {
    let f : Proc<A>
    
    init(_ f : @escaping Proc<A>) {
        self.f = f
    }
    
    override func attempt() -> IO<Either<Error, A>> {
        var result : IO<Either<Error, A>>?
        
        do {
            let callback : Callback<A> = { either in
                result = Pure<Either<Error, A>>(either)
            }
            try f(callback)
        } catch {
            result = Pure<Either<Error, A>>(Either<Error, A>.left(error))
        }
        
        while(result == nil) {}
        
        return result!
    }
    
    override func unsafePerformIO() throws -> A {
        let result = attempt()
        let either = try result.unsafePerformIO()
        
        if either.isLeft {
            throw either.leftValue
        } else {
            return either.rightValue
        }
    }
}

extension IO: Fixed {}

public extension IO {
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    public static func async<E>() -> AsyncInstance<E> {
        return AsyncInstance<E>()
    }
    
    public static func applicativeError<E>() -> MonadErrorInstance<E> {
        return MonadErrorInstance<E>()
    }
    
    public static func monadError<E>() -> MonadErrorInstance<E> {
        return MonadErrorInstance<E>()
    }
    
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> SemigroupInstance<A, SemiG> {
        return SemigroupInstance<A, SemiG>(semigroup)
    }
    
    public static func monoid<Mono>(_ monoid : Mono) -> MonoidInstance<A, Mono> {
        return MonoidInstance<A, Mono>(monoid)
    }
    
    public static func eq<EqA, EqError>(_ eq : EqA, _ eqError : EqError) -> EqInstance<A, EqA, EqError> {
        return EqInstance<A, EqA, EqError>(eq, eqError)
    }

    public class FunctorInstance : Functor {
        public typealias F = ForIO
        
        public func map<A, B>(_ fa: IOOf<A>, _ f: @escaping (A) -> B) -> IOOf<B> {
            return IO<A>.fix(fa).map(f)
        }
    }

    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> IOOf<A> {
            return IO<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: IOOf<(A) -> B>, _ fa: IOOf<A>) -> IOOf<B> {
            return IO<(A) -> B>.fix(ff).ap(IO<A>.fix(fa))
        }
    }

    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: IOOf<A>, _ f: @escaping (A) -> IOOf<B>) -> IOOf<B> {
            return IO<A>.fix(fa).flatMap({ a in IO<B>.fix(f(a)) })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IOOf<Either<A, B>>) -> IOOf<B> {
            return IO<A>.tailRecM(a, f)
        }
    }

    public class AsyncInstance<Err> : MonadErrorInstance<Err>, Async where Err : Error {
        public func suspend<A>(_ fa: @escaping () -> Kind<ForIO, A>) -> Kind<ForIO, A> {
            return IO<A>.suspend { fa().fix() }
        }
        
        public typealias F = ForIO
        
        public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> IOOf<A> {
            return IO<A>.runAsync(fa)
        }
    }

    public class MonadErrorInstance<Err> : MonadInstance, MonadError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> IOOf<A> {
            return IO<A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: IOOf<A>, _ f: @escaping (Err) -> IOOf<A>) -> IOOf<A> {
            return IO<A>.fix(fa).handleErrorWith { e in IO<A>.fix(f(e as! Err)) }
        }
    }

    public class SemigroupInstance<B, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == B {
        public typealias A = IOOf<B>
        
        private let semigroup : SemiG
        
        init(_ semigroup : SemiG) {
            self.semigroup = semigroup
        }
        
        public func combine(_ a: IOOf<B>, _ b: IOOf<B>) -> IOOf<B> {
            return IO<B>.fix(a).flatMap { aa in IO<B>.fix(b).map { bb in self.semigroup.combine(aa, bb) } }
        }
    }

    public class MonoidInstance<B, Mono> : SemigroupInstance<B, Mono>, Monoid where Mono : Monoid, Mono.A == B {
        private let monoid : Mono
        
        override init(_ monoid : Mono) {
            self.monoid = monoid
            super.init(monoid)
        }
        
        public var empty: IOOf<B> {
            return IO<B>.pure(monoid.empty)
        }
    }

    public class EqInstance<B, EqB, EqError> : Eq where EqB : Eq, EqB.A == B, EqError : Eq, EqError.A == Error {
        public typealias A = IOOf<B>
        
        private let eq : EqB
        private let eqError : EqError
        
        init(_ eq : EqB, _ eqError : EqError) {
            self.eq = eq
            self.eqError = eqError
        }
        
        public func eqv(_ a: IOOf<B>, _ b: IOOf<B>) -> Bool {
            var aValue, bValue : B?
            var aError, bError : Error?
            
            do {
                aValue = try IO<B>.fix(a).unsafePerformIO()
            } catch {
                aError = error
            }
            
            do {
                bValue = try IO<B>.fix(b).unsafePerformIO()
            } catch {
                bError = error
            }
            
            if let aV = aValue, let bV = bValue {
                return eq.eqv(aV, bV)
            } else if let aE = aError, let bE = bError {
                return eqError.eqv(aE, bE)
            } else {
                return false
            }
        }
    }
}

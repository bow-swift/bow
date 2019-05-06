import Foundation
import Bow

public final class ForIO {}
public final class IOPartial<E: Error>: Kind<ForIO, E> {}
public typealias IOOf<E: Error, A> = Kind<IOPartial<E>, A>

public class IO<E: Error, A>: IOOf<E, A> {
    public static func fix(_ fa: IOOf<E, A>) -> IO<E, A> {
        return fa as! IO<E, A>
    }

    public static func invoke(_ f: @escaping () throws -> A) -> IO<E, A> {
        return IO.fix(IO.suspend({
            do {
                return Pure<E, A>(try f())
            } catch let error as E {
                return RaiseError(error)
            } catch {
                fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
            }
        }))
    }
    
    public static func merge<B>(_ fa : @escaping () throws -> A,
                                _ fb : @escaping () throws -> B) -> IO<E, (A, B)> {
        return IO<E, (A, B)>.fix(IO<E, (A, B)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb)))
    }
    
    public static func merge<B, C>(_ fa : @escaping () throws -> A,
                                   _ fb : @escaping () throws -> B,
                                   _ fc : @escaping () throws -> C) -> IO<E, (A, B, C)> {
        return IO<E, (A, B, C)>.fix(IO<E, (A, B, C)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc)))
    }
    
    public static func merge<B, C, D>(_ fa : @escaping () throws -> A,
                                      _ fb : @escaping () throws -> B,
                                      _ fc : @escaping () throws -> C,
                                      _ fd : @escaping () throws -> D) -> IO<E, (A, B, C, D)> {
        return IO<E, (A, B, C, D)>.fix(IO<E, (A, B, C, D)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd)))
    }
    
    public static func merge<B, C, D, F>(_ fa : @escaping () throws -> A,
                                         _ fb : @escaping () throws -> B,
                                         _ fc : @escaping () throws -> C,
                                         _ fd : @escaping () throws -> D,
                                         _ ff : @escaping () throws -> F) -> IO<E, (A, B, C, D, F)> {
        return IO<E, (A, B, C, D, F)>.fix(IO<E, (A, B, C, D, F)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff)))
    }
    
    public static func merge<B, C, D, F, G>(_ fa : @escaping () throws -> A,
                                            _ fb : @escaping () throws -> B,
                                            _ fc : @escaping () throws -> C,
                                            _ fd : @escaping () throws -> D,
                                            _ ff : @escaping () throws -> F,
                                            _ fg : @escaping () throws -> G) -> IO<E, (A, B, C, D, F, G)> {
        return IO<E, (A, B, C, D, F, G)>.fix(IO<E, (A, B, C, D, F, G)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg)))
    }
    
    public static func merge<B, C, D, F, G, H>(_ fa : @escaping () throws -> A,
                                               _ fb : @escaping () throws -> B,
                                               _ fc : @escaping () throws -> C,
                                               _ fd : @escaping () throws -> D,
                                               _ ff : @escaping () throws -> F,
                                               _ fg : @escaping () throws -> G,
                                               _ fh : @escaping () throws -> H ) -> IO<E, (A, B, C, D, F, G, H)> {
        return IO<E, (A, B, C, D, F, G, H)>.fix(IO<E, (A, B, C, D, F, G, H)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh)))
    }
    
    public static func merge<B, C, D, F, G, H, I>(_ fa : @escaping () throws -> A,
                                                  _ fb : @escaping () throws -> B,
                                                  _ fc : @escaping () throws -> C,
                                                  _ fd : @escaping () throws -> D,
                                                  _ ff : @escaping () throws -> F,
                                                  _ fg : @escaping () throws -> G,
                                                  _ fh : @escaping () throws -> H,
                                                  _ fi : @escaping () throws -> I) -> IO<E, (A, B, C, D, F, G, H, I)> {
        return IO<E, (A, B, C, D, F, G, H, I)>.fix(IO<E, (A, B, C, D, F, G, H, I)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi)))
    }
    
    public static func merge<B, C, D, F, G, H, I, J>(_ fa : @escaping () throws -> A,
                                                     _ fb : @escaping () throws -> B,
                                                     _ fc : @escaping () throws -> C,
                                                     _ fd : @escaping () throws -> D,
                                                     _ ff : @escaping () throws -> F,
                                                     _ fg : @escaping () throws -> G,
                                                     _ fh : @escaping () throws -> H,
                                                     _ fi : @escaping () throws -> I,
                                                     _ fj : @escaping () throws -> J ) -> IO<E, (A, B, C, D, F, G, H, I, J)> {
        return IO<E, (A, B, C, D, F, G, H, I, J)>.fix(IO<E, (A, B, C, D, F, G, H, I, J)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi),
            IO<E, J>.invoke(fj)))
    }
    
    public func unsafePerformIO() throws -> A {
        fatalError("unsafePerformIO must be implemented in subclasses")
    }
    
    public func attempt() -> IO<E, A>{
        fatalError("attempt must be implemented in subclasses")
    }
    
    public func unsafeRunAsync(_ callback: Callback<E, A>) {
        do {
            callback(Either.right(try unsafePerformIO()))
        } catch let error as E {
            callback(Either.left(error))
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }

    public func mapLeft<EE>(_ f: @escaping (E) -> EE) -> IO<EE, A> {
        return FErrorMap(f, self)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to IO.
public postfix func ^<E, A>(_ fa: IOOf<E, A>) -> IO<E, A> {
    return IO.fix(fa)
}

private class Pure<E: Error, A>: IO<E, A> {
    let a: A
    
    init(_ a: A) {
        self.a = a
    }
    
    override func attempt() -> IO<E, A> {
        return Pure<E, A>(a)
    }
    
    override func unsafePerformIO() throws -> A {
        return a
    }
}

private class RaiseError<E: Error, A> : IO<E, A> {
    let error: E
    
    init(_ error : E) {
        self.error = error
    }
    
    override func attempt() -> IO<E, A> {
        return RaiseError<E, A>(error)
    }
    
    override func unsafePerformIO() throws -> A {
        throw error
    }
}

private class FMap<E: Error, A, B> : IO<E, B> {
    let f: (A) throws -> B
    let action: IO<E, A>
    
    init(_ f: @escaping (A) throws -> B, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override func attempt() -> IO<E, B> {
        do {
            return try Pure<E, B>(self.unsafePerformIO())
        } catch let error as E {
            return RaiseError<E, B>(error)
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
    
    override func unsafePerformIO() throws -> B {
        return try f(try action.unsafePerformIO())
    }
}

private class FErrorMap<E: Error, A, EE: Error>: IO<EE, A> {
    let f: (E) -> EE
    let action: IO<E, A>

    init(_ f: @escaping (E) -> EE, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }

    override func attempt() -> IO<EE, A> {
        do {
            return try Pure<EE, A>(self.unsafePerformIO())
        } catch let error as E {
            return RaiseError<EE, A>(f(error))
        } catch let error as EE {
            return RaiseError<EE, A>(error)
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) or \(EE.self) are handled.")
        }
    }

    override func unsafePerformIO() throws -> A {
        do {
            return try action.unsafePerformIO()
        } catch let error as E {
            throw f(error)
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
}

private class Join<E: Error, A> : IO<E, A> {
    let io: IO<E, IO<E, A>>
    
    init(_ io: IO<E, IO<E, A>>) {
        self.io = io
    }
    
    override func attempt() -> IO<E, A> {
        do {
            return Pure<E, A>(try unsafePerformIO())
        } catch let error as E {
            return RaiseError<E, A>(error)
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
    
    override func unsafePerformIO() throws -> A {
        return try io.unsafePerformIO().unsafePerformIO()
    }
}

private class AsyncIO<E: Error, A> : IO<E, A> {
    let f: Proc<E, A>
    
    init(_ f: @escaping Proc<E, A>) {
        self.f = f
    }
    
    override func attempt() -> IO<E, A> {
        var result: IO<E, A>?
        
        do {
            let callback: Callback<E, A> = { either in
                result = either.fold(RaiseError.init, Pure.init)
            }
            try f(callback)
        } catch let error as E {
            result = RaiseError<E, A>(error)
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
        
        while(result == nil) {}
        
        return result!
    }
    
    override func unsafePerformIO() throws -> A {
        let result = attempt()
        return try result.unsafePerformIO()
    }
}

extension IOPartial: Functor {
    public static func map<A, B>(_ fa: Kind<IOPartial<E>, A>, _ f: @escaping (A) -> B) -> Kind<IOPartial<E>, B> {
        return FMap(f, IO.fix(fa))
    }
}

extension IOPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<IOPartial<E>, A> {
        return Pure(a)
    }
}

// MARK: Instance of `Selective` for `IO`
extension IOPartial: Selective {}

extension IOPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<IOPartial<E>, A>, _ f: @escaping (A) -> Kind<IOPartial<E>, B>) -> Kind<IOPartial<E>, B> {
        return Join(IO.fix(IO.fix(fa).map { x in IO.fix(f(x)) }))
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<IOPartial<E>, Either<A, B>>) -> Kind<IOPartial<E>, B> {
        return IO.fix(f(a)).flatMap { either in
            either.fold({ a in tailRecM(a, f) },
                        { b in IO.pure(b) })
        }
    }
}

extension IOPartial: ApplicativeError {
    public static func raiseError<A>(_ e: E) -> Kind<IOPartial<E>, A> {
        return RaiseError(e)
    }

    private static func fold<A, B>(_ io: IO<E, A>, _ fe: @escaping (E) -> B, _ fa: @escaping (A) -> B) -> B {
        switch io {
        case let pure as Pure<E, A>: return fa(pure.a)
        case let raise as RaiseError<E, A>: return fe(raise.error)
        default: fatalError("Invoke attempt before fold")
        }
    }

    public static func handleErrorWith<A>(_ fa: Kind<IOPartial<E>, A>, _ f: @escaping (E) -> Kind<IOPartial<E>, A>) -> Kind<IOPartial<E>, A> {
        return fold(IO.fix(fa).attempt(), f, IO.pure)
    }
}

extension IOPartial: MonadError {}

extension IOPartial: MonadDefer {
    public static func suspend<A>(_ fa: @escaping () -> Kind<IOPartial<E>, A>) -> Kind<IOPartial<E>, A> {
        return Pure(()).flatMap(fa)
    }
}

extension IOPartial: Async {
    public static func runAsync<A>(_ fa: @escaping ((Either<E, A>) -> ()) throws -> ()) -> Kind<IOPartial<E>, A> {
        return AsyncIO(fa)
    }
}

extension IOPartial: EquatableK where E: Equatable {
    public static func eq<A: Equatable>(_ lhs: Kind<IOPartial<E>, A>, _ rhs: Kind<IOPartial<E>, A>) -> Bool {
        var aValue, bValue : A?
        var aError, bError : E?

        do {
            aValue = try IO.fix(lhs).unsafePerformIO()
        } catch let error as E {
            aError = error
        } catch {
            fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
        }

        do {
            bValue = try IO.fix(rhs).unsafePerformIO()
        } catch let error as E {
            bError = error
        } catch {
            fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
        }

        if let aV = aValue, let bV = bValue {
            return aV == bV
        } else if let aE = aError, let bE = bError {
            return aE == bE
        } else {
            return false
        }
    }
}

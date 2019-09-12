import Foundation
import Bow

public final class ForIO {}
public final class IOPartial<E: Error>: Kind<ForIO, E> {}
public typealias IOOf<E: Error, A> = Kind<IOPartial<E>, A>

public typealias ForTask = IOPartial<Error>
public typealias Task<A> = IO<Error, A>

public typealias ForUIO = IOPartial<Never>
public typealias UIO<A> = IO<Never, A>

public enum IOError: Error {
    case timeout
}

public class IO<E: Error, A>: IOOf<E, A> {
    public static func fix(_ fa: IOOf<E, A>) -> IO<E, A> {
        return fa as! IO<E, A>
    }
    
    public static func invoke(_ f: @escaping () throws -> A) -> IO<E, A> {
        return IO.defer {
            do {
                return Pure<E, A>(try f())
            } catch let error as E {
                return RaiseError(error)
            } catch {
                fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
            }
        }^
    }
    
    public static func merge<B>(_ fa: @escaping () throws -> A,
                                _ fb: @escaping () throws -> B) -> IO<E, (A, B)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb))^
    }
    
    public static func merge<B, C>(_ fa: @escaping () throws -> A,
                                   _ fb: @escaping () throws -> B,
                                   _ fc: @escaping () throws -> C) -> IO<E, (A, B, C)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc))^
    }
    
    public static func merge<B, C, D>(_ fa: @escaping () throws -> A,
                                      _ fb: @escaping () throws -> B,
                                      _ fc: @escaping () throws -> C,
                                      _ fd: @escaping () throws -> D) -> IO<E, (A, B, C, D)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd))^
    }
    
    public static func merge<B, C, D, F>(_ fa: @escaping () throws -> A,
                                         _ fb: @escaping () throws -> B,
                                         _ fc: @escaping () throws -> C,
                                         _ fd: @escaping () throws -> D,
                                         _ ff: @escaping () throws -> F) -> IO<E, (A, B, C, D, F)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff))^
    }
    
    public static func merge<B, C, D, F, G>(_ fa: @escaping () throws -> A,
                                            _ fb: @escaping () throws -> B,
                                            _ fc: @escaping () throws -> C,
                                            _ fd: @escaping () throws -> D,
                                            _ ff: @escaping () throws -> F,
                                            _ fg: @escaping () throws -> G) -> IO<E, (A, B, C, D, F, G)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg))^
    }
    
    public static func merge<B, C, D, F, G, H>(_ fa: @escaping () throws -> A,
                                               _ fb: @escaping () throws -> B,
                                               _ fc: @escaping () throws -> C,
                                               _ fd: @escaping () throws -> D,
                                               _ ff: @escaping () throws -> F,
                                               _ fg: @escaping () throws -> G,
                                               _ fh: @escaping () throws -> H ) -> IO<E, (A, B, C, D, F, G, H)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh))^
    }
    
    public static func merge<B, C, D, F, G, H, I>(_ fa: @escaping () throws -> A,
                                                  _ fb: @escaping () throws -> B,
                                                  _ fc: @escaping () throws -> C,
                                                  _ fd: @escaping () throws -> D,
                                                  _ ff: @escaping () throws -> F,
                                                  _ fg: @escaping () throws -> G,
                                                  _ fh: @escaping () throws -> H,
                                                  _ fi: @escaping () throws -> I) -> IO<E, (A, B, C, D, F, G, H, I)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi))^
    }
    
    public static func merge<B, C, D, F, G, H, I, J>(_ fa: @escaping () throws -> A,
                                                     _ fb: @escaping () throws -> B,
                                                     _ fc: @escaping () throws -> C,
                                                     _ fd: @escaping () throws -> D,
                                                     _ ff: @escaping () throws -> F,
                                                     _ fg: @escaping () throws -> G,
                                                     _ fh: @escaping () throws -> H,
                                                     _ fi: @escaping () throws -> I,
                                                     _ fj: @escaping () throws -> J ) -> IO<E, (A, B, C, D, F, G, H, I, J)> {
        return IO.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi),
            IO<E, J>.invoke(fj))^
    }
    
    public func unsafePerformIO(on queue: DispatchQueue = .main) throws -> A {
        return try self._unsafePerformIO(on: queue).0
    }
    
    internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        fatalError("_unsafePerformIO must be implemented in subclasses")
    }
    
    internal func on<T>(queue: DispatchQueue, perform: @escaping () throws -> T) throws -> T {
        if DispatchQueue.currentLabel == queue.label {
            return try perform()
        } else {
            return try queue.sync {
                try perform()
            }
        }
    }
    
    public func attempt(on queue: DispatchQueue = .main) -> IO<E, A>{
        do {
            let result = try self.unsafePerformIO(on: queue)
            return IO.pure(result)^
        } catch let error as E {
            return IO.raiseError(error)^
        } catch {
            fail(error)
        }
    }
    
    public func unsafeRunAsync(on queue: DispatchQueue = .main, _ callback: @escaping Callback<E, A>) {
        queue.async {
            do {
                callback(Either.right(try self.unsafePerformIO(on: queue)))
            } catch let error as E {
                callback(Either.left(error))
            } catch {
                self.fail(error)
            }
        }
    }
    
    public func mapLeft<EE>(_ f: @escaping (E) -> EE) -> IO<EE, A> {
        return FErrorMap(f, self)
    }
    
    internal func fail(_ error: Error) -> Never {
        fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to IO.
public postfix func ^<E, A>(_ fa: IOOf<E, A>) -> IO<E, A> {
    return IO.fix(fa)
}

internal class Pure<E: Error, A>: IO<E, A> {
    let a: A
    
    init(_ a: A) {
        self.a = a
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try on(queue: queue) { self.a }, queue)
    }
}

internal class RaiseError<E: Error, A> : IO<E, A> {
    let error: E
    
    init(_ error : E) {
        self.error = error
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try on(queue: queue) { throw self.error }, queue)
    }
}

internal class FMap<E: Error, A, B> : IO<E, B> {
    let f: (A) -> B
    let action: IO<E, A>
    
    init(_ f: @escaping (A) -> B, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (B, DispatchQueue) {
        let result = try action._unsafePerformIO(on: queue)
        return (try on(queue: result.1) { self.f(result.0) }, result.1)
    }
}

internal class FErrorMap<E: Error, A, EE: Error>: IO<EE, A> {
    let f: (E) -> EE
    let action: IO<E, A>
    
    init(_ f: @escaping (E) -> EE, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        do {
            return try action._unsafePerformIO(on: queue)
        } catch let error as E {
            return (try on(queue: queue) { throw self.f(error) }, queue)
        } catch {
            self.fail(error)
        }
    }
}

internal class Join<E: Error, A> : IO<E, A> {
    let io: IO<E, IO<E, A>>
    
    init(_ io: IO<E, IO<E, A>>) {
        self.io = io
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        let result = try io._unsafePerformIO(on: queue)
        return try result.0._unsafePerformIO(on: result.1)
    }
}

internal class AsyncIO<E: Error, A>: IO<E, A> {
    let f: ProcF<IOPartial<E>, E, A>
    
    init(_ f: @escaping ProcF<IOPartial<E>, E, A>) {
        self.f = f
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        var result: Either<E, A>?
        let group = DispatchGroup()
        group.enter()
        let callback: Callback<E, A> = { either in
            result = either
            group.leave()
        }
        let io = try on(queue: queue) {
            self.f(callback)
        }
        let procResult = try io^._unsafePerformIO(on: queue)
        group.wait()
        
        return (try IO.fromEither(result!)^._unsafePerformIO(on: procResult.1).0 , procResult.1)
    }
}

internal class ContinueOn<E: Error, A>: IO<E, A> {
    let io: IO<E, A>
    let queue: DispatchQueue
    
    init(_ io: IO<E, A>, _ queue: DispatchQueue) {
        self.io = io
        self.queue = queue
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try io._unsafePerformIO(on: queue).0, self.queue)
    }
}

internal class BracketIO<E: Error, A, B>: IO<E, B> {
    let io: IO<E, A>
    let release: (A, ExitCase<E>) -> Kind<IOPartial<E>, ()>
    let use: (A) throws -> Kind<IOPartial<E>, B>
    
    init(_ io: IO<E, A>,
         _ release: @escaping (A, ExitCase<E>) -> Kind<IOPartial<E>, ()>,
         _ use: @escaping (A) throws -> Kind<IOPartial<E>, B>) {
        self.io = io
        self.release = release
        self.use = use
    }
    
    override func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (B, DispatchQueue) {
        let ioResult = try io._unsafePerformIO(on: queue)
        let resource = ioResult.0
        do {
            let useResult = try use(resource)^._unsafePerformIO(on: queue)
            let _ = try release(resource, .completed)^._unsafePerformIO(on: queue)
            return useResult
        } catch let error as E {
            let _ = try release(resource, .error(error))^._unsafePerformIO(on: queue)
            throw error
        } catch {
            self.fail(error)
        }
    }
}

internal class ParMap2<E: Error, A, B, Z>: IO<E, Z> {
    private let fa: IO<E, A>
    private let fb: IO<E, B>
    private let f: (A, B) -> Z
    
    init(_ fa: IO<E, A>, _ fb: IO<E, B>, _ f: @escaping (A, B) -> Z) {
        self.fa = fa
        self.fb = fb
        self.f = f
    }
    
    override func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (Z, DispatchQueue) {
        var a: A?
        var b: B?
        let atomic = Atomic<E?>(nil)
        let group = DispatchGroup()
        let parQueue1 = DispatchQueue(label: queue.label + "parMap1", qos: queue.qos)
        let parQueue2 = DispatchQueue(label: queue.label + "parMap2", qos: queue.qos)
        
        group.enter()
        parQueue1.async {
            do {
                a = try self.fa._unsafePerformIO(on: parQueue1).0
            } catch let error as E {
                atomic.setIfNil(error)
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.enter()
        parQueue2.async {
            do {
                b = try self.fb._unsafePerformIO(on: parQueue2).0
            } catch let error as E {
                atomic.setIfNil(error)
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.wait()
        if let aa = a, let bb = b {
            return (f(aa, bb), queue)
        } else {
            throw atomic.value!
        }
    }
}

internal class ParMap3<E: Error, A, B, C, Z>: IO<E, Z> {
    private let fa: IO<E, A>
    private let fb: IO<E, B>
    private let fc: IO<E, C>
    private let f: (A, B, C) -> Z
    
    init(_ fa: IO<E, A>, _ fb: IO<E, B>, _ fc: IO<E, C>, _ f: @escaping (A, B, C) -> Z) {
        self.fa = fa
        self.fb = fb
        self.fc = fc
        self.f = f
    }
    
    override func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (Z, DispatchQueue) {
        var a: A?
        var b: B?
        var c: C?
        let atomic = Atomic<E?>(nil)
        let group = DispatchGroup()
        let parQueue1 = DispatchQueue(label: queue.label + "parMap1", qos: queue.qos)
        let parQueue2 = DispatchQueue(label: queue.label + "parMap2", qos: queue.qos)
        let parQueue3 = DispatchQueue(label: queue.label + "parMap3", qos: queue.qos)
        
        group.enter()
        parQueue1.async {
            do {
                a = try self.fa._unsafePerformIO(on: parQueue1).0
            } catch let error as E {
                atomic.value = error
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.enter()
        parQueue2.async {
            do {
                b = try self.fb._unsafePerformIO(on: parQueue2).0
            } catch let error as E {
                atomic.value = error
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.enter()
        parQueue3.async {
            do {
                c = try self.fc._unsafePerformIO(on: parQueue3).0
            } catch let error as E {
                atomic.value = error
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.wait()
        if let aa = a, let bb = b, let cc = c {
            return (f(aa, bb, cc), queue)
        } else {
            throw atomic.value!
        }
    }
}

internal class IOEffect<E: Error, A>: IO<E, ()> {
    let io: IO<E, A>
    let callback: (Either<E, A>) -> IOOf<E, ()>
    
    init(_ io: IO<E, A>, _ callback: @escaping (Either<E, A>) -> IOOf<E, ()>) {
        self.io = io
        self.callback = callback
    }
    
    override func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> ((), DispatchQueue) {
        var result: IOOf<E, ()>
        do {
            let (a, nextQueue) = try io._unsafePerformIO(on: queue)
            result = callback(.right(a))
            return try result^._unsafePerformIO(on: nextQueue)
        } catch let error as E {
            result = callback(.left(error))
            return try result^._unsafePerformIO(on: queue)
        } catch {
            fail(error)
        }
    }
}

internal class Suspend<E: Error, A>: IO<E, A> {
    let thunk: () -> IOOf<E, A>
    
    init(_ thunk: @escaping () -> IOOf<E, A>) {
        self.thunk = thunk
    }
    
    override func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return try on(queue: queue) {
            try self.thunk()^._unsafePerformIO(on: queue)
        }
    }
}

// MARK: Instance of `Functor` for `IO`
extension IOPartial: Functor {
    public static func map<A, B>(_ fa: IOOf<E, A>, _ f: @escaping (A) -> B) -> IOOf<E, B> {
        return FMap(f, IO.fix(fa))
    }
}

// MARK: Instance of `Applicative` for `IO`
extension IOPartial: Applicative {
    public static func pure<A>(_ a: A) -> IOOf<E, A> {
        return Pure(a)
    }
}

// MARK: Instance of `Selective` for `IO`
extension IOPartial: Selective {}

// MARK: Instance of `Monad` for `IO`
extension IOPartial: Monad {
    public static func flatMap<A, B>(_ fa: IOOf<E, A>, _ f: @escaping (A) -> IOOf<E, B>) -> IOOf<E, B> {
        return Join(IO.fix(IO.fix(fa).map { x in IO.fix(f(x)) }))
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IOOf<E, Either<A, B>>) -> IOOf<E, B> {
        return IO.fix(f(a)).flatMap { either in
            either.fold({ a in tailRecM(a, f) },
                        { b in IO.pure(b) })
        }
    }
}

// MARK: Instance of `ApplicativeError` for `IO`
extension IOPartial: ApplicativeError {
    public static func raiseError<A>(_ e: E) -> IOOf<E, A> {
        return RaiseError(e)
    }
    
    private static func fold<A, B>(_ io: IO<E, A>, _ fe: @escaping (E) -> B, _ fa: @escaping (A) -> B) -> B {
        switch io {
        case let pure as Pure<E, A>: return fa(pure.a)
        case let raise as RaiseError<E, A>: return fe(raise.error)
        default: fatalError("Invoke attempt before fold")
        }
    }
    
    public static func handleErrorWith<A>(_ fa: IOOf<E, A>, _ f: @escaping (E) -> IOOf<E, A>) -> IOOf<E, A> {
        return fold(IO.fix(fa).attempt(), f, IO.pure)
    }
}

// MARK: Instance of `MonadError` for `IO`
extension IOPartial: MonadError {}

// MARK: Instance of `Bracket` for `IO`
extension IOPartial: Bracket {
    public static func bracketCase<A, B>(acquire fa: IOOf<E, A>, release: @escaping (A, ExitCase<E>) -> IOOf<E, ()>, use: @escaping (A) throws -> IOOf<E, B>) -> IOOf<E, B> {
        return BracketIO<E, A, B>(fa^, release, use)
    }
}

// MARK: Instance of `MonadDefer` for `IO`
extension IOPartial: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> IOOf<E, A>) -> IOOf<E, A> {
        return Suspend(fa)
    }
}

// MARK: Instance of `Async` for `IO`
extension IOPartial: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<E, A>) -> ()) -> IOOf<E, ()>) -> IOOf<E, A> {
        return AsyncIO(procf)
    }
    
    public static func continueOn<A>(_ fa: IOOf<E, A>, _ queue: DispatchQueue) -> IOOf<E, A> {
        return ContinueOn(fa^, queue)
    }
}

// MARK: Instance of `Concurrent` for `IO`
extension IOPartial: Concurrent {
    public static func parMap<A, B, Z>(_ fa: Kind<IOPartial<E>, A>, _ fb: Kind<IOPartial<E>, B>, _ f: @escaping (A, B) -> Z) -> Kind<IOPartial<E>, Z> {
        return ParMap2<E, A, B, Z>(fa^, fb^, f)
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<IOPartial<E>, A>, _ fb: Kind<IOPartial<E>, B>, _ fc: Kind<IOPartial<E>, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<IOPartial<E>, Z> {
        return ParMap3<E, A, B, C, Z>(fa^, fb^, fc^, f)
    }
}

// MARK: Instance of `Effect` for `IO`
extension IOPartial: Effect {
    public static func runAsync<A>(_ fa: IOOf<E, A>, _ callback: @escaping (Either<E, A>) -> IOOf<E, ()>) -> IOOf<E, ()> {
        return IOEffect(fa^, callback)
    }
}

// MARK: Instance of `UnsafeRun` for `IO`
extension IOPartial: UnsafeRun {
    public static func runBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<IOPartial<E>, A>) throws -> A {
        return try fa()^.unsafePerformIO(on: queue)
    }
    
    public static func runNonBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<IOPartial<E>, A>, _ callback: @escaping (Either<E, A>) -> ()) {
        fa()^.unsafeRunAsync(on: queue, callback)
    }
}

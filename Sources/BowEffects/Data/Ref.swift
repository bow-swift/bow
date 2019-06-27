import Bow

public class Ref<F, A> {
    public func get() -> Kind<F, A> {
        fatalError("get must be implemented in subclasses")
    }
    
    public func set(_ a: A) -> Kind<F, ()> {
        fatalError("set must be implemented in subclasses")
    }
    
    public func getAndSet(_ a: A) -> Kind<F, A> {
        fatalError("getAndSet must be implemented in subclasses")
    }
    
    public func setAndGet(_ a: A) -> Kind<F, A> {
        fatalError("setAndGet must be implemented in subclasses")
    }
    
    public func update(_ f: @escaping (A) -> A) -> Kind<F, ()> {
        fatalError("update must be implemented in subclasses")
    }
    
    public func getAndUpdate(_ f: @escaping (A) -> A) -> Kind<F, A> {
        fatalError("getAndUpdate must be implemented in subclasses")
    }
    
    public func updateAndGet(_ f: @escaping (A) -> A) -> Kind<F, A> {
        fatalError("updateAndGet must be implemented in subclasses")
    }
    
    public func modify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, B> {
        fatalError("modify must be implemented in subclasses")
    }
    
    public func tryUpdate(_ f: @escaping (A) -> A) -> Kind<F, Bool> {
        fatalError("tryUpdate must be implemented in subclasses")
    }
    
    public func tryModify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, Option<B>> {
        fatalError("tryModify must be implemented in subclasses")
    }
    
    public func access() -> Kind<F, (A, (A) -> Kind<F, Bool>)> {
        fatalError("access must be implemented in subclasses")
    }
}

public extension Ref where F: MonadDefer, A: Equatable {
    static func later(_ f: @escaping () -> A) -> Kind<F, Ref<F, A>> {
        return F.delay { unsafe(f()) }
    }
    
    static func unsafe(_ a: A) -> Ref<F, A> {
        return MonadDeferRef(Atomic(a))
    }
}

private class MonadDeferRef<F: MonadDefer, A: Equatable>: Ref<F, A> {
    private let atomic: Atomic<A>
    
    init(_ atomic: Atomic<A>) {
        self.atomic = atomic
    }
    
    override func get() -> Kind<F, A> {
        return F.delay { self.atomic.value }
    }
    
    override func set(_ a: A) -> Kind<F, ()> {
        return F.delay { self.atomic.value = a }
    }
    
    override func getAndSet(_ a: A) -> Kind<F, A> {
        return F.delay { self.atomic.getAndSet(a) }
    }
    
    override func setAndGet(_ a: A) -> Kind<F, A> {
        return set(a).flatMap { self.get() }
    }
    
    override func update(_ f: @escaping (A) -> A) -> Kind<F, ()> {
        return modify { a in (f(a), ()) }
    }
    
    override func getAndUpdate(_ f: @escaping (A) -> A) -> Kind<F, A> {
        return F.delay { self.atomic.getAndUpdate(f) }
    }
    
    override func updateAndGet(_ f: @escaping (A) -> A) -> Kind<F, A> {
        return F.delay { self.atomic.updateAndGet(f) }
    }
    
    override func modify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, B> {
        func go() -> B {
            let a = atomic.value
            let (u, b) = f(a)
            return atomic.compare(a, andSet: u) ? b : go()
        }
        
        return F.delay(go)
    }
    
    override func tryUpdate(_ f: @escaping (A) -> A) -> Kind<F, Bool> {
        return tryModify { a in (f(a), ()) }.map { x in x.isDefined }
    }
    
    override func tryModify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, Option<B>> {
        return F.delay {
            let a = self.atomic.value
            let (u, b) = f(a)
            return self.atomic.compare(a, andSet: u) ? Option.some(b) : Option.none()
        }
    }
    
    override func access() -> Kind<F, (A, (A) -> Kind<F, Bool>)> {
        return F.delay {
            let snapshot = self.atomic.value
            let hasBeenCalled = Atomic(false)
            let setter = { (a: A) in F.delay { hasBeenCalled.compare(false, andSet: true) && self.atomic.compare(snapshot, andSet: a) } }
            return (snapshot, setter)
        }
    }
}

import Bow

public class Promise<F, A> {
    public func get() -> Kind<F, A> {
        fatalError("get must be implemented in subclasses")
    }
    
    public func tryGet() -> Kind<F, Option<A>> {
        fatalError("tryGet must be implemented in subclasses")
    }
    
    public func complete(_ a: A) -> Kind<F, ()> {
        fatalError("complete must be implemented in subclasses")
    }
    
    public func tryComplete(_ a: A) -> Kind<F, Bool> {
        fatalError("tryComplete must be implemented in subclasses")
    }
    
    public func error<E: Error>(_ e: E) -> Kind<F, ()> {
        fatalError("error must be implemented in subclasses")
    }
    
    public func tryError<E: Error>(_ e: E) -> Kind<F, Bool> {
        fatalError("tryError must be implemented in subclasses")
    }
}

public enum PromiseError: Error {
    case alreadyFulfilled
}

public extension Promise where F: Concurrent {
    static var cancelable: Kind<F, Promise<F, A>> {
        return F.delay { CancelablePromise<F, A>() }
    }
    
    static var unsafeCancelable: Promise<F, A> {
        return CancelablePromise<F, A>()
    }
}

public extension Promise where F: Async {
    static var uncancelable: Kind<F, Promise<F, A>> {
        return F.delay { UncancelablePromise<F, A>() }
    }
    
    static var unsafeUncancelable: Promise<F, A> {
        return UncancelablePromise<F, A>()
    }
}

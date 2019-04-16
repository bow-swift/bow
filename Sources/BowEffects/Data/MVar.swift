import Bow

public class MVar<F, A> {
    public init() {}

    var isEmpty: Kind<F, Bool> {
        fatalError("isEmpty needs to be implemented in subclasses")
    }

    var isNotEmpty: Kind<F, Bool> {
        fatalError("isNotEmpty needs to be implemented in subclasses")
    }

    func put(_ a: A) -> Kind<F, ()> {
        fatalError("put needs to be implemented in subclasses")
    }

    func tryPut(_ a: A) -> Kind<F, Bool> {
        fatalError("tryPut needs to be implemented in subclasses")
    }

    func take() -> Kind<F, A> {
        fatalError("take needs to be implemented in subclasses")
    }

    func tryTake() -> Kind<F, Option<A>> {
        fatalError("tryTake needs to be implemented in subclasses")
    }

    func read() -> Kind<F, A> {
        fatalError("read needs to be implemented in subclasses")
    }
}

public class MVarPartialOf<F> {
    func of<A>(_ a: A) -> Kind<F, MVar<F, A>> {
        fatalError("of needs to be implemented in subclasses")
    }

    func empty<A>() -> Kind<F, MVar<F, A>> {
        fatalError("empty needs to be implemented in subclasses")
    }
}

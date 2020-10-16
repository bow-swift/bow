import Foundation

public final class ForLazyFunction1 {}
public final class LazyFunction1Partial<I>: Kind<ForLazyFunction1, I> {}
public typealias LazyFunction1Of<I, O> = Kind<LazyFunction1Partial<I>, O>
public final class LazyFunction1<I, O>: LazyFunction1Of<I, O> {
    public init(_ f: @escaping (I) -> O) {
        functions = [erase(f)]
    }

    init(_ functions: [(Any) -> Any]) {
        self.functions = functions
    }

    let functions: [(Any) -> Any]

    public static func fix(_ fa: LazyFunction1Of<I, O>) -> LazyFunction1<I, O> {
        fa as! LazyFunction1<I, O>
    }

    public var run: (I) -> O {
        { (i: I) in
            self.functions.foldLeft(i) { (x, f) in
                f(x)
            } as! O
        }
    }

    public func compose<A>(_ f: LazyFunction1<A, I>) -> LazyFunction1<A, O> {
        LazyFunction1<A, O>(f.functions + functions)
    }

    public func andThen<A>(_ f: LazyFunction1<O, A>) -> LazyFunction1<I, A> {
        f.compose(self)
    }

    public func contramap<A>(_ f: @escaping (A) -> I) -> LazyFunction1<A, O> {
        compose(LazyFunction1<A, I>(f))
    }
}

fileprivate func erase<I, O>(_ f: @escaping (I) -> O) -> (Any) -> Any {
    { f($0 as! I) }
}

public postfix func ^<I, O>(_ fa: LazyFunction1Of<I, O>) -> LazyFunction1<I, O> {
    LazyFunction1.fix(fa)
}

// MARK: Instance of Functor for LazyFunction1
extension LazyFunction1Partial: Functor {
    public static func map<A, B>(
        _ fa: LazyFunction1Of<I, A>,
        _ f: @escaping (A) -> B) -> LazyFunction1Of<I, B> {
        fa^.andThen(LazyFunction1(f))
    }
}

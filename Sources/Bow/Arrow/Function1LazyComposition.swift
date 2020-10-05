import Foundation

public final class ForFunction1LazyComposition {}
public final class Function1LazyCompositionPartial<I>: Kind<ForFunction1LazyComposition, I> {}
public typealias Function1LazyCompositionOf<I, O> = Kind<Function1LazyCompositionPartial<I>, O>
public final class Function1LazyComposition<I, O>: Function1LazyCompositionOf<I, O> {
    public init(_ f: @escaping (I) -> O) {
        functions = [erase(f)]
    }

    init(_ functions: [(Any) -> Any]) {
        self.functions = functions
    }

    let functions: [(Any) -> Any]

    public static func fix(_ fa: Function1LazyCompositionOf<I, O>) -> Function1LazyComposition<I, O> {
        fa as! Function1LazyComposition<I, O>
    }

    public var run: (I) -> O {
        { (i: I) in
            self.functions.foldLeft(i) { (x, f) in
                f(x)
            } as! O
        }
    }

    public func compose<A>(_ f: Function1LazyComposition<A, I>) -> Function1LazyComposition<A, O> {
        Function1LazyComposition<A, O>(f.functions + functions)
    }

    public func andThen<A>(_ f: Function1LazyComposition<O, A>) -> Function1LazyComposition<I, A> {
        f.compose(self)
    }

    public func contramap<A>(_ f: @escaping (A) -> I) -> Function1LazyComposition<A, O> {
        compose(Function1LazyComposition<A, I>(f))
    }
}

fileprivate func erase<I, O>(_ f: @escaping (I) -> O) -> (Any) -> Any {
    { f($0 as! I) }
}

public postfix func ^<I, O>(_ fa: Function1LazyCompositionOf<I, O>) -> Function1LazyComposition<I, O> {
    Function1LazyComposition.fix(fa)
}

// MARK: Instance of Functor for Function1LazyComposition
extension Function1LazyCompositionPartial: Functor {
    public static func map<A, B>(
        _ fa: Function1LazyCompositionOf<I, A>,
        _ f: @escaping (A) -> B) -> Function1LazyCompositionOf<I, B> {
        fa^.andThen(Function1LazyComposition(f))
    }
}

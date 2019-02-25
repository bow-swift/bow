import Foundation

public final class ForFunction1 {}
public final class Function1Partial<I>: Kind<ForFunction1, I> {}
public typealias Function1Of<I, O> = Kind<Function1Partial<I>, O>

public class Function1<I, O> : Function1Of<I, O> {
    fileprivate let f : (I) -> O
    
    public static func fix(_ fa : Function1Of<I, O>) -> Function1<I, O> {
        return fa as! Function1<I, O>
    }
    
    public init(_ f : @escaping (I) -> O) {
        self.f = f
    }
    
    public func invoke(_ value : I) -> O {
        return f(value)
    }
}

extension Function1Partial: Functor {
    public static func map<A, B>(_ fa: Kind<Function1Partial<I>, A>, _ f: @escaping (A) -> B) -> Kind<Function1Partial<I>, B> {
        return Function1(Function1.fix(fa).f >>> f)
    }
}

extension Function1Partial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<Function1Partial<I>, A> {
        return Function1(constant(a))
    }
}

extension Function1Partial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<Function1Partial<I>, A>, _ f: @escaping (A) -> Kind<Function1Partial<I>, B>) -> Kind<Function1Partial<I>, B> {
        return Function1<I, B>({ i in Function1.fix(f(Function1.fix(fa).f(i))).f(i) })
    }

    private static func step<A, B>(_ a : A, _ t : I, _ f : (A) -> Function1Of<I, Either<A, B>>) -> B {
        return Function1.fix(f(a)).f(t).fold({ a in step(a, t, f) }, id)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<Function1Partial<I>, Either<A, B>>) -> Kind<Function1Partial<I>, B> {
        return Function1<I, B>({ t in step(a, t, f) })
    }
}

extension Function1Partial: MonadReader {
    public typealias D = I

    public static func ask() -> Kind<Function1Partial<I>, I> {
        return Function1(id)
    }

    public static func local<A>(_ fa: Kind<Function1Partial<I>, A>, _ f: @escaping (I) -> I) -> Kind<Function1Partial<I>, A> {
        return Function1(f >>> Function1.fix(fa).f)
    }
}

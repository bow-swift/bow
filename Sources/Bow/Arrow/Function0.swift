import Foundation

public final class ForFunction0 {}
public typealias Function0Of<A> = Kind<ForFunction0, A>

public class Function0<A>: Function0Of<A> {
    fileprivate let f: () -> A
    
    public static func fix(_ fa: Function0Of<A>) -> Function0<A> {
        return fa as! Function0
    }
    
    public init(_ f: @escaping () -> A) {
        self.f = f
    }
    
    public func invoke() -> A {
        return f()
    }
}

extension ForFunction0: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForFunction0, A>, _ rhs: Kind<ForFunction0, A>) -> Bool where A : Equatable {
        return Function0.fix(lhs).extract() == Function0.fix(rhs).extract()
    }
}

extension ForFunction0: Functor {
    public static func map<A, B>(_ fa: Kind<ForFunction0, A>, _ f: @escaping (A) -> B) -> Kind<ForFunction0, B> {
        return Function0(Function0.fix(fa).f >>> f)
    }
}

extension ForFunction0: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForFunction0, A> {
        return Function0(constant(a))
    }
}

extension ForFunction0: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForFunction0, A>, _ f: @escaping (A) -> Kind<ForFunction0, B>) -> Kind<ForFunction0, B> {
        return f(Function0.fix(fa).f())
    }

    private static func loop<A, B>(_ a: A, _ f: (A) -> Function0Of<Either<A, B>>) -> B {
        let result = Function0.fix(f(a)).extract()
        return result.fold({ a in loop(a, f) }, id)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForFunction0, Either<A, B>>) -> Kind<ForFunction0, B> {
        return Function0<B>({ loop(a, f) })
    }
}

extension ForFunction0: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<ForFunction0, A>, _ f: @escaping (Kind<ForFunction0, A>) -> B) -> Kind<ForFunction0, B> {
        return Function0<B>({ f(Function0.fix(fa)) })
    }

    public static func extract<A>(_ fa: Kind<ForFunction0, A>) -> A {
        return Function0.fix(fa).f()
    }
}

extension ForFunction0: Bimonad {}

import Foundation

public class ForFunction1 {}
public typealias Function1Of<I, O> = Kind2<ForFunction1, I, O>
public typealias Function1Partial<I> = Kind<ForFunction1, I>

public class Function1<I, O> : Function1Of<I, O> {
    private let f : (I) -> O
    
    public static func ask<I>() -> Function1<I, I> {
        return Function1<I, I>({ (a : I) in a })
    }
    
    public static func pure<I, A>(_ a : A) -> Function1<I, A> {
        return Function1<I, A>({ _ in a })
    }
    
    private static func step<A, B>(_ a : A, _ t : I, _ f : (A) -> Function1Of<I, Either<A, B>>) -> B {
        return Function1<I, Either<A, B>>.fix(f(a)).f(t).fold({ a in step(a, t, f) }, id)
    }
    
    public static func tailRecM<A, B>(_ a : A, _ f : @escaping (A) -> Function1Of<I, Either<A, B>>) -> Function1Of<I, B> {
        return Function1<I, B>({ t in step(a, t, f) })
    }
    
    public static func fix(_ fa : Function1Of<I, O>) -> Function1<I, O> {
        return fa as! Function1<I, O>
    }
    
    public init(_ f : @escaping (I) -> O) {
        self.f = f
    }
    
    public func map<B>(_ g : @escaping (O) -> B) -> Function1<I, B> {
        return Function1<I, B>(self.f >>> g)
    }
    
    public func flatMap<B>(_ g : @escaping (O) -> Function1<I, B>) -> Function1<I, B> {
        let h : (I) -> B = { i in g(self.f(i)).f(i) }
        return Function1<I, B>(h)
    }
    
    public func ap<AA, B>(_ fa : Function1<I, AA>) -> Function1<I, B> where O == (AA) -> B {
        return Function1<I, B>({ i in self.f(i)(fa.f(i)) })
    }
    
    public func local(_ g : @escaping (I) -> I) -> Function1<I, O> {
        return Function1<I, O>(g >>> self.f)
    }
    
    public func invoke(_ value : I) -> O {
        return f(value)
    }
}

public extension Function1 {
    public static func functor() -> Function1Functor<I> {
        return Function1Functor<I>()
    }
    
    public static func applicative() -> Function1Applicative<I> {
        return Function1Applicative<I>()
    }
    
    public static func monad() -> Function1Monad<I> {
        return Function1Monad<I>()
    }
    
    public static func reader() -> Function1MonadReader<I> {
        return Function1MonadReader<I>()
    }
}

public class Function1Functor<I> : Functor {
    public typealias F = Function1Partial<I>
    
    public func map<A, B>(_ fa: Function1Of<I, A>, _ f: @escaping (A) -> B) -> Function1Of<I, B> {
        return Function1.fix(fa).map(f)
    }
}

public class Function1Applicative<I> : Function1Functor<I>, Applicative {
    public func pure<A>(_ a: A) -> Function1Of<I, A> {
        return Function1<I, A>.pure(a)
    }
    
    public func ap<A, B>(_ ff: Function1Of<I, (A) -> B>, _ fa: Function1Of<I, A>) -> Function1Of<I, B> {
        return Function1.fix(ff).ap(Function1.fix(fa))
    }
}

public class Function1Monad<I> : Function1Applicative<I>, Monad {
    public func flatMap<A, B>(_ fa: Function1Of<I, A>, _ f: @escaping (A) -> Function1Of<I, B>) -> Function1Of<I, B> {
        return Function1.fix(fa).flatMap({ a in Function1.fix(f(a)) })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Function1Of<I, Either<A, B>>) -> Function1Of<I, B> {
        return Function1<I, A>.tailRecM(a, f)
    }
}

public class Function1MonadReader<I> : Function1Monad<I>, MonadReader {
    public typealias D = I
    
    public func ask() -> Function1Of<I, I> {
        return Function1<I, I>.ask()
    }
    
    public func local<A>(_ f: @escaping (I) -> I, _ fa: Function1Of<I, A>) -> Function1Of<I, A> {
        return Function1.fix(fa).local(f)
    }
}


























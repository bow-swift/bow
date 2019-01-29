import Foundation

public class ForFunction0 {}
public typealias Function0Of<A> = Kind<ForFunction0, A>

public class Function0<A> : Function0Of<A> {
    private let f : () -> A
    
    public static func pure(_ a : A) -> Function0<A> {
        return Function0({ a })
    }
    
    public static func loop<B>(_ a : A, _ f : (A) -> Function0Of<Either<A, B>>) -> B {
        let result = (f(a) as! Function0<Either<A, B>>).extract()
        return result.fold({ a in loop(a, f) }, id)
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> Function0Of<Either<A, B>>) -> Function0<B> {
        return Function0<B>({ loop(a, f) })
    }
    
    public static func fix(_ fa : Function0Of<A>) -> Function0<A> {
        return fa.fix()
    }
    
    public init(_ f : @escaping () -> A) {
        self.f = f
    }
    
    public func invoke() -> A {
        return f()
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Function0<B> {
        return Function0<B>(self.f >>> f)
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Function0<B>) -> Function0<B> {
        return f(self.f())
    }
    
    public func coflatMap<B>(_ f : @escaping (Function0<A>) -> B) -> Function0<B> {
        return Function0<B>({ f(self) })
    }
    
    public func ap<AA, B>(_ fa : Function0<AA>) -> Function0<B> where A == (AA) -> B {
        return Function0<B>(fa.f >>> f())
    }
    
    public func extract() -> A {
        return f()
    }
}

public extension Kind where F == ForFunction0 {
    public func fix() -> Function0<A> {
        return self as! Function0<A>
    }
}

public extension Function0 {
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    public static func comonad() -> BimonadInstance {
        return BimonadInstance()
    }
    
    public static func bimonad() -> BimonadInstance {
        return BimonadInstance()
    }
    
    public static func eq<EqA>(_ eq : EqA) -> EqInstance<A, EqA> {
        return EqInstance<A, EqA>(eq)
    }

    public class FunctorInstance : Functor {
        public typealias F = ForFunction0
        
        public func map<A, B>(_ fa: Function0Of<A>, _ f: @escaping (A) -> B) -> Function0Of<B> {
            return fa.fix().map(f)
        }
    }

    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> Kind<ApplicativeInstance.F, A> {
            return Function0<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: Kind<ApplicativeInstance.F, (A) -> B>, _ fa: Kind<ApplicativeInstance.F, A>) -> Kind<ApplicativeInstance.F, B> {
            return Function0<(A) -> B>.fix(ff).ap(Function0<A>.fix(fa))
        }
    }

    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: Function0Of<A>, _ f: @escaping (A) -> Function0Of<B>) -> Function0Of<B> {
            return fa.fix().flatMap({ a in f(a).fix() })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Function0Of<Either<A, B>>) -> Function0Of<B> {
            return Function0<A>.tailRecM(a, f)
        }
    }

    public class BimonadInstance : MonadInstance, Bimonad {
        public func coflatMap<A, B>(_ fa: Function0Of<A>, _ f: @escaping (Function0Of<A>) -> B) -> Function0Of<B> {
            return fa.fix().coflatMap(f)
        }
        
        public func extract<A>(_ fa: Function0Of<A>) -> A {
            return fa.fix().extract()
        }
    }

    public class EqInstance<B, EqB> : Eq where EqB : Eq, EqB.A == B{
        public typealias A = Function0Of<B>
        
        private let eq : EqB
        
        init(_ eq : EqB) {
            self.eq = eq
        }
        
        public func eqv(_ a: Function0Of<B>, _ b: Function0Of<B>) -> Bool {
            return eq.eqv(a.fix().extract(), b.fix().extract())
        }
    }
}

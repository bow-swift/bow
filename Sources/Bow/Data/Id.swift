import Foundation

/**
 Witness for the `Id<A>` data type. To be used in simulated Higher Kinded Types.
 */
public class ForId {}

/**
 Higher Kinded Type alias to improve readability of `Kind<ForId, A>`.
 */
public typealias IdOf<A> = Kind<ForId, A>

/**
 The identity data type represents a context of having no effect on the type it wraps. A instance of `Id<A>` is isomorphic to an instance of `A`; it is just wrapped without any additional information.
 */
public class Id<A> : IdOf<A> {
    public let value : A
    
    /**
     Lifts a pure value to `Id<A>`.
     
     - parameter a: Value to be lifted.
     */
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    public static func tailRecM<B>(_ a : (A), _ f : (A) -> IdOf<Either<A, B>>) -> Id<B> {
        return Id<Either<A, B>>.fix(f(a)).value
            .fold({ left in tailRecM(left, f)},
                  Id<B>.pure)
    }
    
    /**
     Safe downcast to `Id<A>`.
     */
    public static func fix(_ fa : IdOf<A>) -> Id<A> {
        return fa.fix()
    }
    
    /**
     Constructs a value of `Id<A>` given a value of `A`.
     
     - parameter value: Value to be wrapped in `Id<A>`.
     */
    public init(_ value : A) {
        self.value = value
    }
    
    /**
     Transforms the type parameter, preserving its structure.
     
     - parameter f: Closure to transform the wrapped value.
     */
    public func map<B>(_ f : (A) -> B) -> Id<B> {
        return Id<B>(f(value))
    }
    
    /**
     Transforms the parameter using the function wrapped in the receiver `Id`.
     */
    public func ap<AA, B>(_ fa : Id<AA>) -> Id<B> where A == (AA) -> B{
        return flatMap(fa.map)
    }
    
    /**
     Returns the result of applying `f` to the wrapped value.
     */
    public func flatMap<B>(_ f : (A) -> Id<B>) -> Id<B> {
        return f(value)
    }
    
    /**
     Left associative fold using a function.
     */
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return f(b, value)
    }
    
    /**
     Right associative fold using a function.
     */
    public func foldRight<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return f(value, b)
    }
    
    /**
     Given a function which returns a `G` effect through the running of this function on the wrapped value, returning an `Id` in a `G` context.
     */
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, IdOf<B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    /**
     Applies a function that receives a value in a context and returns a normal value.
     */
    public func coflatMap<B>(_ f : (Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    /**
     Obtain the wrapped value.
     */
    public func extract() -> A {
        return value
    }
}

// MARK: Kind extensions
public extension Kind where F == ForId {
    /**
     Safe downcast to `Id<A>`.
     */
    public func fix() -> Id<A> {
        return self as! Id<A>
    }
}

// MARK: Protocol conformances
/**
 Conformance of `Id<A>` to `CustomStringConvertible`.
 */
extension Id : CustomStringConvertible {
    public var description : String {
        return "Id(\(value))"
    }
}

/**
 Conformance of `Id<A>` to `CustomDebugStringConvertible`, given that type parameter `A` also conforms to `CustomDebugStringConvertible`.
 */
extension Id : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "Id(\(value.debugDescription))"
    }
}

/**
 Conformance of `Id<A>` to `Equatable`, given that type parameter `A` also conforms to `Equatable`.
 */
extension Id : Equatable where A : Equatable {
    public static func ==(lhs : Id<A>, rhs : Id<A>) -> Bool {
        return lhs.value == rhs.value
    }
}

// MARK: Id typeclass instances
extension Id {
    /**
     Obtains an instance of the `Functor` typeclass for `Id`.
     */
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    /**
     Obtains an instance of the `Applicative` typeclass for `Id`.
     */
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    /**
     Obtains an instance of the `Monad` typeclass for `Id`.
     */
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    /**
     Obtains an instance of the `Comonad` typeclass for `Id`.
     */
    public static func comonad() -> BimonadInstance {
        return BimonadInstance()
    }
    
    /**
     Obtains an instance of the `Bimonad` typeclass for `Id`.
     */
    public static func bimonad() -> BimonadInstance {
        return BimonadInstance()
    }
    
    /**
     Obtains an instance of the `Foldable` typeclass for `Id`.
     */
    public static func foldable() -> FoldableInstance {
        return FoldableInstance()
    }
    
    /**
     Obtains an instance of the `Traverse` typeclass for `Id`.
     */
    public static func traverse() -> TraverseInstance {
        return TraverseInstance()
    }

    /**
     Obtains an instance of the `Eq` typeclass for `Id`.
     */
    public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, EqA> {
        return EqInstance<A, EqA>(eqa)
    }

    /**
     An instance of the `Functor` typeclass for the `Id` data type.
     */
    public class FunctorInstance : Functor {
        public typealias F = ForId
        
        public func map<A, B>(_ fa: IdOf<A>, _ f: @escaping (A) -> B) -> IdOf<B> {
            return fa.fix().map(f)
        }
    }

    /**
     An instance of the `Applicative` typeclass for the `Id` data type.
     */
    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> IdOf<A> {
            return Id<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: IdOf<(A) -> B>, _ fa: IdOf<A>) -> IdOf<B> {
            return ff.fix().ap(fa.fix())
        }
    }

    /**
     An instance of the `Monad` typeclass for the `Id` data type.
     */
    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (A) -> IdOf<B>) -> IdOf<B> {
            return fa.fix().flatMap({ a in f(a).fix() })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IdOf<Either<A, B>>) -> IdOf<B> {
            return Id<A>.tailRecM(a, f)
        }
    }

    /**
     An instance of the `Bimonad` typeclass for the `Id` data type.
     */
    public class BimonadInstance : MonadInstance, Bimonad {
        public func coflatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (IdOf<A>) -> B) -> IdOf<B> {
            return fa.fix().coflatMap(f as (Id<A>) -> B)
        }
        
        public func extract<A>(_ fa: IdOf<A>) -> A {
            return fa.fix().extract()
        }
    }

    /**
     An instance of the `Foldable` typeclass for the `Id` data type.
     */
    public class FoldableInstance : Foldable {
        public typealias F = ForId
        
        public func foldLeft<A, B>(_ fa: IdOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return fa.fix().foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: IdOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return fa.fix().foldRight(b, f)
        }
    }

    /**
     An instance of the `Traverse` typeclass for the `Id` data type.
     */
    public class TraverseInstance : FoldableInstance, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: IdOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, IdOf<B>> where G == Appl.F, Appl : Applicative {
            return fa.fix().traverse(f, applicative)
        }
    }

    /**
     An instance of the `Eq` typeclass for the `Id` data type.
     */
    public class EqInstance<B, EqB> : Eq where EqB : Eq, EqB.A == B {
        public typealias A = IdOf<B>
        
        private let eqb : EqB
        
        init(_ eqb : EqB) {
            self.eqb = eqb
        }
        
        public func eqv(_ a: IdOf<B>, _ b: IdOf<B>) -> Bool {
            return eqb.eqv(Id<B>.fix(a).value, Id<B>.fix(b).value)
        }
    }
}

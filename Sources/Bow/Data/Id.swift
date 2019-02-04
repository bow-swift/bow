import Foundation

/// Witness for the `Id<A>` data type. To be used in simulated Higher Kinded Types.
public class ForId {}

/// Higher Kinded Type alias to improve readability of `Kind<ForId, A>`.
public typealias IdOf<A> = Kind<ForId, A>

/// The identity data type represents a context of having no effect on the type it wraps. A instance of `Id<A>` is isomorphic to an instance of `A`; it is just wrapped without any additional information.
public class Id<A> : IdOf<A> {
    public let value : A
    
    /// Lifts a pure value to `Id`.
    ///
    /// - Parameter a: Value to be lifted.
    /// - Returns: Parameter in the context of `Id`.
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    
    /// Tail recursion function on the context of `Id`.
    ///
    /// - Parameters:
    ///   - a: Initial value for the recursion.
    ///   - f: Function defining a recursion step.
    ///   - step: Value to be processed in the next recursion step.
    /// - Returns: Result of processing the recursive call.
    public static func tailRecM<B>(_ a : (A), _ f : (_ step: A) -> IdOf<Either<A, B>>) -> Id<B> {
        return Id<Either<A, B>>.fix(f(a)).value
            .fold({ left in tailRecM(left, f)},
                  Id<B>.pure)
    }
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Higher Kinded Type form of `Id`.
    /// - Returns: Value casted to `Id`.
    public static func fix(_ fa : IdOf<A>) -> Id<A> {
        return fa.fix()
    }
    
    /// Constructs a value of `Id`.
    ///
    /// - Parameter value: Value to be wrapped in `Id`.
    public init(_ value : A) {
        self.value = value
    }
    
    /// Transforms the type parameter, preserving the `Id` structure.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    ///   - a: Wrapped value.
    /// - Returns: Result of applying the transforming function to the wrapped value, in the context of `Id`.
    public func map<B>(_ f : (_ a: A) -> B) -> Id<B> {
        return Id<B>(f(value))
    }
    
    /// Transforms the value in the `Id` context given the function wrapped in this `Id`.
    ///
    /// - Parameter fa: Value in the context of `Id` to be transformed using the wrapped function.
    /// - Returns: Result of applying this function to the parameter, in the context of `Id`.
    public func ap<AA, B>(_ fa : Id<AA>) -> Id<B> where A == (AA) -> B{
        return flatMap(fa.map)
    }
    
    /// Applies `f` to the wrapped value.
    ///
    /// - Parameters:
    ///   - f: Function to apply to the wrapped value.
    ///   - a: Value wrapped in this `Id`.
    /// - Returns: Result of applying `f` to the wrapped value.
    public func flatMap<B>(_ f : (_ a: A) -> Id<B>) -> Id<B> {
        return f(value)
    }
    
    /// Left associative fold using a function.
    ///
    /// - Parameters:
    ///   - b: Initial value.
    ///   - f: Function describing a folding step.
    ///   - partial: Accumulated value in the folding process.
    ///   - next: Next value to fold.
    /// - Returns: Combination of the value inside this `Id` and the initial value.
    public func foldLeft<B>(_ b : B, _ f : (_ partial: B, _ next:A) -> B) -> B {
        return f(b, value)
    }
    
    /// Right associative fold using a function.
    ///
    /// This methods evaluates computations lazily and returns a lazy value using `Eval`.
    ///
    /// - Parameters:
    ///   - b: Initial value.
    ///   - f: Function describing a folding step.
    ///   - next: Next value to fold.
    ///   - partial: Accumulated value in the folding process.
    /// - Returns: Lazy combination of the value inside this `Id` and the initial value.
    public func foldRight<B>(_ b : Eval<B>, _ f : (_ next: A, _ partial: Eval<B>) -> Eval<B>) -> Eval<B> {
        return f(value, b)
    }
    
    /// Given a function which returns a `G` effect through the running of this function on the wrapped value, returning an `Id` in a `G` context.
    ///
    /// - Parameters:
    ///   - f: A function from the wrapped type into a value in the context of `G`.
    ///   - applicative: An instance of `Applicative` for the type `G`.
    /// - Returns: An `Id` value in the context of `G`.
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, IdOf<B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    /// Dual of `flatMap`. Applies a function that receives a value in a context and returns a normal value.
    ///
    /// - Parameters:
    ///   - f: A function that receives a value in the context of `Id` and returns a normal value.
    ///   - fa: This value.
    /// - Returns: The result of applying the parameter function lifted to the context of `Id`.
    public func coflatMap<B>(_ f : (_ fa: Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    /// Obtains the wrapped value.
    ///
    /// - Returns: Value inside this `Id`.
    public func extract() -> A {
        return value
    }
}

// MARK: Kind extensions
public extension Kind where F == ForId {
    /// Safe downcast.
    ///
    /// - Returns: This value casted to `Id`.
    public func fix() -> Id<A> {
        return self as! Id<A>
    }
}

// MARK: Protocol conformances
/// Conformance of `Id` to `CustomStringConvertible`.
extension Id : CustomStringConvertible {
    public var description : String {
        return "Id(\(value))"
    }
}

/// Conformance of `Id` to `CustomDebugStringConvertible`, given that type parameter also conforms to `CustomDebugStringConvertible`.
extension Id : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "Id(\(value.debugDescription))"
    }
}

/// Conformance of `Id` to `Equatable`, given that type parameter also conforms to `Equatable`.
extension Id : Equatable where A : Equatable {
    public static func ==(lhs : Id<A>, rhs : Id<A>) -> Bool {
        return lhs.value == rhs.value
    }
}

// MARK: Id typeclass instances
extension Id {
    /// Obtains an instance of the `Functor` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Functor`.
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    /// Obtains an instance of the `Applicative` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Applicative`.
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    /// Obtains an instance of the `Monad` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Monad`.
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    /// Obtains an instance of the `Comonad` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Comonad`.
    public static func comonad() -> ComonadInstance {
        return ComonadInstance()
    }
    
    /// Obtains an instance of the `Bimonad` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Bimonad`.
    public static func bimonad() -> BimonadInstance {
        return BimonadInstance()
    }
    
    /// Obtains an instance of the `Foldable` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Foldable`.
    public static func foldable() -> FoldableInstance {
        return FoldableInstance()
    }
    
    /// Obtains an instance of the `Traverse` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Traverse`.
    public static func traverse() -> TraverseInstance {
        return TraverseInstance()
    }

    /// Obtains an instance of the `Eq` typeclass for `Id`.
    ///
    /// - Returns: Instance of `Eq`.
    public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, EqA> {
        return EqInstance<A, EqA>(eqa)
    }

    /// An instance of the `Functor` typeclass for the `Id` data type.
    ///
    /// Use `Id.functor()` to obtain an instance of this type.
    public class FunctorInstance : Functor {
        public typealias F = ForId
        
        public func map<A, B>(_ fa: IdOf<A>, _ f: @escaping (A) -> B) -> IdOf<B> {
            return fa.fix().map(f)
        }
    }

    /// An instance of the `Applicative` typeclass for the `Id` data type.
    ///
    /// Use `Id.applicative()` to obtain an instance of this type.
    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> IdOf<A> {
            return Id<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: IdOf<(A) -> B>, _ fa: IdOf<A>) -> IdOf<B> {
            return ff.fix().ap(fa.fix())
        }
    }

    /// An instance of the `Monad` typeclass for the `Id` data type.
    ///
    /// Use `Id.monad()` to obtain an instance of this type.
    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (A) -> IdOf<B>) -> IdOf<B> {
            return fa.fix().flatMap({ a in f(a).fix() })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IdOf<Either<A, B>>) -> IdOf<B> {
            return Id<A>.tailRecM(a, f)
        }
    }
    
    /// An instance of the `Comonad` typeclass for the `Id` data type.
    ///
    /// Use `Id.comonad()` to obtain an instance of this type.
    public class ComonadInstance : FunctorInstance, Comonad {
        public func coflatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (IdOf<A>) -> B) -> IdOf<B> {
            return fa.fix().coflatMap(f as (Id<A>) -> B)
        }
        
        public func extract<A>(_ fa: IdOf<A>) -> A {
            return fa.fix().extract()
        }
    }

    /// An instance of the `Bimonad` typeclass for the `Id` data type.
    ///
    /// Use `Id.bimonad()` to obtain an instance of this type.
    public class BimonadInstance : MonadInstance, Bimonad {
        public func coflatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (IdOf<A>) -> B) -> IdOf<B> {
            return Id<A>.comonad().coflatMap(fa, f)
        }
        
        public func extract<A>(_ fa: IdOf<A>) -> A {
            return Id<A>.comonad().extract(fa)
        }
    }

    /// An instance of the `Foldable` typeclass for the `Id` data type.
    ///
    /// Use `Id.foldable()` to obtain an instance of this type.
    public class FoldableInstance : Foldable {
        public typealias F = ForId
        
        public func foldLeft<A, B>(_ fa: IdOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return fa.fix().foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: IdOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return fa.fix().foldRight(b, f)
        }
    }

    /// An instance of the `Traverse` typeclass for the `Id` data type.
    ///
    /// Use `Id.traverse()` to obtain an instance of this type.
    public class TraverseInstance : FoldableInstance, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: IdOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, IdOf<B>> where G == Appl.F, Appl : Applicative {
            return fa.fix().traverse(f, applicative)
        }
    }

    /// An instance of the `Eq` typeclass for the `Id` data type.
    ///
    /// Use `Id.eq(_:)` to obtain an instance of this type.
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

import Foundation

/**
 Witness for the `Option<A>` data type. To be used in simulated Higher Kinded Types.
 */
public class ForOption {}

/**
 Higher Kinded Type alias to improve readability of `Kind<ForOption, A>`.
 */
public typealias OptionOf<A> = Kind<ForOption, A>

/**
 Represents optional values. Instances of this type may represent the presence of a value (`some`) or absence of it (`none`). This type is isomorphic to native Swift `Optional<A>` (usually written `A?`), with the addition of behaving as a Higher Kinded Type.
 */
public class Option<A> : OptionOf<A> {
    /**
     Constructs an instance of `Option` with presence of a value of the type parameter.
     
     It is an alias for `Option<A>.pure(_:)`
     
     - parameter a: Value to be wrapped in an `Option<A>`.
     */
    public static func some(_ a : A) -> Option<A> {
        return Some(a)
    }
    
    /**
     Constucts an instance of `Option` with absence of a value.
     
     It is an alias for `Option<A>.empty()`
     */
    public static func none() -> Option<A> {
        return None()
    }
    
    /**
     Lifts a pure value to `Option`.
     
     - parameter a: Value to be lifted.
     */
    public static func pure(_ a : A) -> Option<A> {
        return some(a)
    }
    
    /**
     Constructs an instance of `Option` with absence of a value.
     */
    public static func empty() -> Option<A> {
        return None()
    }
    
    /**
     Converts a native Swift optional into a value of `Option<A>`.
     
     - parameter a: Optional value to be converted.
     */
    public static func fromOptional(_ a : A?) -> Option<A> {
        if let a = a { return some(a) }
        return none()
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Option<Either<A, B>>) -> Option<B> {
        return f(a).fold(constant(Option<B>.none()),
                         { either in
                            either.fold({ left in tailRecM(left, f) },
                                        Option<B>.some)
                         }
        )
    }
    
    /**
     Safe downcast to `Option<A>`.
     */
    public static func fix(_ fa : OptionOf<A>) -> Option<A> {
        return fa.fix()
    }
    
    /**
     Checks absence of value.
     */
    public var isEmpty : Bool {
        return fold({ true },
                    { _ in false })
    }
    
    internal var isDefined : Bool {
        return !isEmpty
    }
    
    /**
     Applies a function based on the presence or absence of a value.
     
     - parameter ifEmpty: A closure that is executed when there is no value in the `Option`.
     - parameter f: A closure that is executed where there is a value in the `Option`. In such case, the the inner value is sent as an argument of `f`.
     */
    public func fold<B>(_ ifEmpty : () -> B, _ f : (A) -> B) -> B {
        switch self {
            case is Some<A>:
                return f((self as! Some<A>).a)
            case is None<A>:
                return ifEmpty()
            default:
                fatalError("Option has only two possible cases")
        }
    }
    
    /**
     Transforms the type parameter, preserving its structure.
     
     - parameter f: Closure to be applied when there is presence of a value.
     */
    public func map<B>(_ f : (A) -> B) -> Option<B> {
        return fold({ Option<B>.none() },
                    { a in Option<B>.some(f(a)) })
    }
    
    /**
     Transform the parameter using the function wrapped in the receiver `Option`.
     */
    public func ap<AA, B>(_ fa : Option<AA>) -> Option<B> where A == (AA) -> B{
        return flatMap(fa.map)
    }
    
    /**
     Returns the result of applying `f` to this option's value if it is non empty, or none it this option is empty.
     */
    public func flatMap<B>(_ f : (A) -> Option<B>) -> Option<B> {
        return fold(Option<B>.none, f)
    }
    
    /**
     Left associative fold using a function.
     */
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold({ b },
                    { a in f(b, a) })
    }
    
    /**
     Right associative fold using a function.
     */
    public func foldRight<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.fold(constant(b),
                         { a in f(a, b) })
    }
    
    /**
     Combined map and filter application.
     */
    public func mapFilter<B>(_ f : (A) -> OptionOf<B>) -> OptionOf<B> {
        return self.fold(Option<B>.none, f)
    }
    
    /**
     Given a function which returns a `G` effect, thread this effect through the running of this function on the wrapped value, returning an Option in a `G` context.
     */
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, OptionOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Option<B>.none()) },
                    { a in applicative.map(f(a), Option<B>.some)})
    }
    
    /**
     Combined traverse and filter application.
     */
    public func traverseFilter<G, B, Appl>(_ f : (A) -> Kind<G, OptionOf<B>>, _ applicative : Appl) -> Kind<G, OptionOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ applicative.pure(Option<B>.none()) }, f)
    }
    
    /**
     Applies a predicate to the wrapped value of this option, returning it if the value matches the predicate, or none otherwise.
     
     - parameter predicate: Boolean predicate to test the wrapped value.
     */
    public func filter(_ predicate : (A) -> Bool) -> Option<A> {
        return fold(constant(Option<A>.none()),
                    { a in predicate(a) ? Option<A>.some(a) : Option<A>.none() })
    }
    
    /**
     Applies a predicate to the wrapped value of this option, returning it if the value does not match the predicate, or none otherwise.
     
     - parameter predicate: Boolean predicate to test the wrapped value.
     */
    public func filterNot(_ predicate : @escaping (A) -> Bool) -> Option<A> {
        return filter(predicate >>> not)
    }
    
    /**
     Check if the wrapped value matches a predicate.
     
     - parameter predicate: Boolean predicate to test the wrapped value.
     */
    public func exists(_ predicate : (A) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    /**
     Check if the wrapped value matches a predicate.
     
     - parameter predicate: Boolean predicate to test the wrapped value.
     */
    public func forall(_ predicate : (A) -> Bool) -> Bool {
        return exists(predicate)
    }
    
    /**
     Obtains the wrapped value, or a default value if absent.
     
     - parameter defaultValue: Value to be returned if this option is empty.
     */
    public func getOrElse(_ defaultValue : A) -> A {
        return getOrElse(constant(defaultValue))
    }
    
    /**
     Obtains the wrapped value, or a default value if absent.
     
     - parameter defaultValue: Closure to be evaluated if there is no wrapped value in this option.
     */
    public func getOrElse(_ defaultValue : () -> A) -> A {
        return fold(defaultValue, id)
    }
    
    /**
     Obtains this option, or a default value if this option is empty.
     
     - parameter defaultValue: Default option value to be returned if this option is empty.
     */
    public func orElse(_ defaultValue : Option<A>) -> Option<A> {
        return orElse(constant(defaultValue))
    }
    
    /**
     Obtains this option, or a default value if this option is empty.
     
     - parameter defaultValue: Closure returning an option for the empty case.
     */
    public func orElse(_ defaultValue : () -> Option<A>) -> Option<A> {
        return fold(defaultValue, Option.some)
    }
    
    /**
     Converts this option into a native Swift optional `A?`.
     */
    public func toOptional() -> A? {
        return fold(constant(nil), id)
    }
    
    /**
     Converts this option into an empty list, if absent, or a singleton list, if present.
     */
    public func toList() -> [A] {
        return fold(constant([]), { a in [a] })
    }
}

class Some<A> : Option<A> {
    fileprivate let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class None<A> : Option<A> {}

// MARK: Protocol conformances
/**
 Conformance of `Option` to `CustomStringConvertible`.
 */
extension Option : CustomStringConvertible {
    public var description : String {
        return fold({ "None" },
                    { a in "Some(\(a))" })
    }
}

/**
 Conformance of `Option` to `CustomDebugStringConvertible`, given that the type parameter `A` also conforms to `CustomDebugStringConvertible`.
 */
extension Option : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold(constant("None"),
                    { a in "Some(\(a.debugDescription)" })
    }
}

/**
 Conformance of `Option` to `Equatable`, given that the type parameter `A` also conforms to `Equatable`.
 */
extension Option : Equatable where A : Equatable {
    public static func ==(lhs : Option<A>, rhs : Option<A>) -> Bool {
        return lhs.fold({ rhs.fold(constant(true), constant(false)) },
                        { a in rhs.fold(constant(false), { b in a == b })})
    }
}

// MARK: Optional extensions
extension Optional {
    func toOption() -> Option<Wrapped> {
        return Option<Wrapped>.fromOptional(self)
    }
}

// MARK: Kind extensions
public extension Kind where F == ForOption {
    public func fix() -> Option<A> {
        return self as! Option<A>
    }
}

// MARK: Option typeclass instances
public extension Option {
    /**
     Obtains an instance of the `Functor` typeclass for `Option`.
     */
    public static func functor() -> OptionFunctor {
        return OptionFunctor()
    }
    
    /**
     Obtains an instance of the `Applicative` typeclass for `Option`.
     */
    public static func applicative() -> OptionApplicative {
        return OptionApplicative()
    }
    
    /**
     Obtains an instance of the `Monad` typeclass for `Option`.
     */
    public static func monad() -> OptionMonad {
        return OptionMonad()
    }
    
    /**
     Obtains an instance of the Semigroup typeclass for `Option`.
     
     - semigroup: An instance of a `Semigroup` for the wrapped type.
     */
    public static func semigroup<SemiG>(_ semigroup : SemiG) -> OptionSemigroup<A, SemiG> {
        return OptionSemigroup<A, SemiG>(semigroup)
    }
    
    /**
     Obtains an instance of the `Monoid` typeclass for `Option`.
     
     - semigroup: An instance of a `Semigroup` for the wrapped type.
     */
    public static func monoid<SemiG>(_ semigroup : SemiG) -> OptionMonoid<A, SemiG> {
        return OptionMonoid<A, SemiG>(semigroup)
    }
    
    /**
     Obtains an instance of the `ApplicativeError` typeclass for `Option`.
     */
    public static func applicativeError() -> OptionMonadError {
        return OptionMonadError()
    }
    
    /**
     Obtains an instance of the `MonadError` typeclass for `Option`.
     */
    public static func monadError() -> OptionMonadError {
        return OptionMonadError()
    }
    
    /**
     Obtains an instance of the `Eq` typeclass for `Option`.
     */
    public static func eq<EqA>(_ eqa : EqA) -> OptionEq<A, EqA> {
        return OptionEq<A, EqA>(eqa)
    }
    
    /**
     Obtains an instance of the `FunctorFilter` typeclass for `Option`.
     */
    public static func functorFilter() -> OptionFunctorFilter {
        return OptionFunctorFilter()
    }
    
    /**
     Obtains an instance of the `MonadFilter` typeclass for `Option`.
     */
    public static func monadFilter() -> OptionMonadFilter {
        return OptionMonadFilter()
    }
    
    /**
     Obtains an instance of the `Foldable` typeclass for `Option`.
     */
    public static func foldable() -> OptionFoldable {
        return OptionFoldable()
    }
    
    /**
     Obtains an instance of the `Traverse` typeclass for `Option`.
     */
    public static func traverse() -> OptionTraverse {
        return OptionTraverse()
    }
    
    /**
     Obtains an instance of the `TraverseFilter` typeclass for `Option`.
     */
    public static func traverseFilter() -> OptionTraverseFilter {
        return OptionTraverseFilter()
    }
}

/**
 An instance of the `Functor` typeclass for the `Option` data type.
 */
public class OptionFunctor : Functor {
    public typealias F = ForOption
    
    public func map<A, B>(_ fa: OptionOf<A>, _ f: @escaping (A) -> B) -> OptionOf<B> {
        return fa.fix().map(f)
    }
}

/**
 An instance of the `Applicative` typeclass for the `Option` data type.
 */
public class OptionApplicative : OptionFunctor, Applicative {
    public func pure<A>(_ a: A) -> OptionOf<A> {
        return Option.pure(a)
    }
    
    public func ap<A, B>(_ ff: OptionOf<(A) -> B>, _ fa: OptionOf<A>) -> OptionOf<B> {
        return ff.fix().ap(fa.fix())
    }
}

/**
 An instance of the `Monad` typeclass for the `Option` data type.
 */
public class OptionMonad : OptionApplicative, Monad {
    public func flatMap<A, B>(_ fa: OptionOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> OptionOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> OptionOf<Either<A, B>>) -> OptionOf<B> {
        return Option<A>.tailRecM(a, { a in f(a).fix() })
    }
}

/**
 An instance of the `Semigroup` typeclass for the `Option` data type.
 */
public class OptionSemigroup<R, SemiG> : Semigroup where SemiG : Semigroup, SemiG.A == R {
    public typealias A = OptionOf<R>
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combine(_ a: OptionOf<R>, _ b: OptionOf<R>) -> OptionOf<R> {
        let a = Option.fix(a)
        let b = Option.fix(b)
        return a.fold(constant(b),
                      { aSome in b.fold(constant(a),
                                        { bSome in Option.some(semigroup.combine(aSome, bSome)) })
                      })
    }
}

/**
 An instance of the `Monoid` typeclass for the `Option` data type.
 */
public class OptionMonoid<R, SemiG> : OptionSemigroup<R, SemiG>, Monoid where SemiG : Semigroup, SemiG.A == R {
    public var empty : OptionOf<R>{
        return Option<R>.none()
    }
}

/**
 An instance of the `MonadError` typeclass for the `Option` data type.
 */
public class OptionMonadError : OptionMonad, MonadError {
    public typealias E = Unit
    
    public func raiseError<A>(_ e: Unit) -> OptionOf<A> {
        return Option<A>.none()
    }
    
    public func handleErrorWith<A>(_ fa: OptionOf<A>, _ f: @escaping (Unit) -> OptionOf<A>) -> OptionOf<A> {
        return fa.fix().orElse(f(unit).fix())
    }
}

/**
 An instance of the `Eq` typeclass for the `Option` data type.
 */
public class OptionEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = OptionOf<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: OptionOf<R>, _ b: OptionOf<R>) -> Bool {
        let a = Option.fix(a)
        let b = Option.fix(b)
        return a.fold({ b.fold(constant(true), constant(false)) },
                      { aSome in b.fold(constant(false), { bSome in eqr.eqv(aSome, bSome) })})
    }
}

/**
 An instance of the `FunctorFilter` typeclass for the `Option` data type.
 */
public class OptionFunctorFilter : OptionFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: OptionOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> OptionOf<B> {
        return fa.fix().mapFilter(f)
    }
}

/**
 An instance of the `MonadFilter` typeclass for the `Option` data type.
 */
public class OptionMonadFilter : OptionMonad, MonadFilter {
    public func empty<A>() -> OptionOf<A> {
        return Option.empty()
    }
    
    public func mapFilter<A, B>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<ForOption, B> {
        return fa.fix().mapFilter(f)
    }
}

/**
 An instance of the `Foldable` typeclass for the `Option` data type.
 */
public class OptionFoldable : Foldable {
    public typealias F = ForOption
    
    public func foldLeft<A, B>(_ fa: Kind<ForOption, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: Kind<ForOption, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

/**
 An instance of the `Traverse` typeclass for the `Option` data type.
 */
public class OptionTraverse : OptionFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<ForOption, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

/**
 An instance of the `TraverseFilter` typeclass for the `Option` data type.
 */
public class OptionTraverseFilter : OptionTraverse, TraverseFilter {
    public func traverseFilter<A, B, G, Appl>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<G, OptionOf<B>>, _ applicative: Appl) -> Kind<G, Kind<ForOption, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverseFilter(f, applicative)
    }
}


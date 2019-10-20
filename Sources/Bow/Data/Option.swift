import Foundation

/// Witness for the `Option<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForOption {}

/// Higher Kinded Type alias to improve readability of `Kind<ForOption, A>`.
public typealias OptionOf<A> = Kind<ForOption, A>

/// Represents optional values. Instances of this type may represent the presence of a value (`some`) or absence of it (`none`). This type is isomorphic to native Swift `Optional<A>` (usually written `A?`), with the addition of behaving as a Higher Kinded Type.
public final class Option<A>: OptionOf<A> {
    private let value: A?
    /// Constructs an instance of `Option` with presence of a value of the type parameter.
    ///
    /// It is an alias for `Option<A>.pure(_:)`
    ///
    /// - Parameter a: Value to be wrapped in an `Option`.
    /// - Returns: An option wrapping the value passed as an argument.
    public static func some(_ a: A) -> Option<A> {
        return Option(a)
    }

    /// Constucts an instance of `Option` with absence of a value.
    ///
    /// It is an alias for `Option<A>.empty()`
    ///
    /// - Returns: An option with no present value
    public static func none() -> Option<A> {
        return Option(nil)
    }

    /// Converts a native Swift optional into a value of `Option<A>`.
    ///
    /// - Parameter a: Optional value to be converted.
    /// - Returns: An Option with the same structure as the argument.
    public static func fromOptional(_ a: A?) -> Option<A> {
        return Option(a)
    }

    private init(_ value: A?) {
        self.value = value
    }

    /// Safe downcasting.
    ///
    /// - Parameter fa: Option in higher-kind form.
    /// - Returns: Value cast to Option.
    public static func fix(_ fa: OptionOf<A>) -> Option<A> {
        return fa as! Option<A>
    }

    /// Checks if this option contains a value
    public var isDefined: Bool {
        return !isEmpty
    }

    /// Applies a function based on the presence or absence of a value.
    ///
    /// - Parameters:
    ///   - ifEmpty: A closure that is executed when there is no value in the `Option`.
    ///   - f: A closure that is executed where there is a value in the `Option`. In such case, the the inner value is sent as an argument of `f`.
    /// - Returns: Result of applying the corresponding closure based on the value of this object.
    public func fold<B>(_ ifEmpty: () -> B, _ f: (A) -> B) -> B {
        guard let value = self.value else { return ifEmpty() }
        return f(value)
    }

    /// Applies a predicate to the wrapped value of this option, returning it if the value does not match the predicate, or none otherwise.
    ///
    /// - Parameter predicate: Boolean predicate to test the wrapped value.
    /// - Returns: This value if it does not match the predicate, or none otherwise.
    public func filterNot(_ predicate: @escaping (A) -> Bool) -> Kind<ForOption, A> {
        return filter(predicate >>> not)
    }

    /// Obtains the wrapped value, or a default value if absent.
    ///
    /// - Parameter defaultValue: Value to be returned if this option is empty.
    /// - Returns: The value wrapped in this Option, if present, or the value provided as an argument, otherwise.
    public func getOrElse(_ defaultValue: A) -> A {
        return getOrElse(constant(defaultValue))
    }
    
    /// Obtains the wrapped value, or a default value if absent.
    ///
    /// - Parameter defaultValue: Closure to be evaluated if there is no wrapped value in this option.
    /// - Returns: The value wrapped in this Option, if present, or the result of running the closure provided as an argument, otherwise.
    public func getOrElse(_ defaultValue: () -> A) -> A {
        return fold(defaultValue, id)
    }

    /// Obtains this option, or a default value if this option is empty.
    ///
    /// - Parameter defaultValue: Default option value to be returned if this option is empty.
    /// - Returns: This option, if has a present value, or the value provided as an argument, otherwise.
    public func orElse(_ defaultValue: Option<A>) -> Option<A> {
        return orElse(constant(defaultValue))
    }

    /// Obtains this option, or a default value if this option is empty.
    ///
    /// - Parameter defaultValue: Closure returning an option for the empty case.
    /// - Returns: This option, if has a present value, or the result of running the closure provided as an argument, otherwise.
    public func orElse(_ defaultValue: () -> Option<A>) -> Option<A> {
        return fold(defaultValue, Option.some)
    }

    /// Converts this option into a native Swift optional `A?`.
    ///
    /// - Returns: A Swift Optional with the same structure as this value.
    public func toOptional() -> A? {
        return fold(constant(nil), id)
    }

    /// Converts this option into an array.
    ///
    /// - Returns: An empty array if this value is absent, or a singleton array, if present.
    public func toArray() -> [A] {
        return fold(constant([]), { a in [a] })
    }
    
    /// Converts this option into a native Swift optional `A?`
    public var orNil: A? {
        return toOptional()
    }
}

/// Safe downcasting.
///
/// - Parameter fa: Option in higher-kind form.
/// - Returns: Value cast to Option.
public postfix func ^<A>(_ fa: OptionOf<A>) -> Option<A> {
    return Option.fix(fa)
}

// MARK: Conformance of `Option` to `CustomStringConvertible`.
extension Option: CustomStringConvertible {
    public var description: String {
        return fold({ "None" },
                    { a in "Some(\(a))" })
    }
}

// MARK: Conformance of `Option` to `CustomDebugStringConvertible`.
extension Option: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold(constant("None"),
                    { a in "Some(\(a.debugDescription)" })
    }
}

// MARK: Instance of `EquatableK` for `Option`.
extension ForOption: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForOption, A>, _ rhs: Kind<ForOption, A>) -> Bool where A : Equatable {
        let ol = Option.fix(lhs)
        let or = Option.fix(rhs)
        return ol.fold({ or.fold(constant(true), constant(false)) },
                       { a in or.fold(constant(false), { b in a == b })})
    }
}

// MARK: Instance of `Functor` for `Option`.
extension ForOption: Functor {
    public static func map<A, B>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> B) -> Kind<ForOption, B> {
        return Option.fix(fa).fold(Option.none, Option.some <<< f)
    }
}

// MARK: Instance of `Applicative` for `Option`.
extension ForOption: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForOption, A> {
        return Option.some(a)
    }
}

// MARK: Instance of `Selective` for `Option`
extension ForOption: Selective {}

// MARK: Instance of `Monad` for `Option`.
extension ForOption: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<ForOption, B> {
        let option = Option.fix(fa)
        return option.fold(Option<B>.none, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForOption, Either<A, B>>) -> Kind<ForOption, B> {
        let option = Option.fix(f(a))
        return option.fold(Option<B>.none, { either in
            either.fold({ left in tailRecM(left, f) },
                        Option<B>.some)
        })
    }
}

// MARK: Instance of `ApplicativeError` for `Option`.
extension ForOption: ApplicativeError {
    public typealias E = Unit

    public static func raiseError<A>(_ e: Unit) -> Kind<ForOption, A> {
        return Option.none()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForOption, A>, _ f: @escaping (Unit) -> Kind<ForOption, A>) -> Kind<ForOption, A> {
        return Option<A>.fix(fa).orElse(Option<A>.fix(f(unit)))
    }
}

// MARK: Instance of `MonadError` for `Option`.
extension ForOption: MonadError {}

// MARK: Instance of `FunctorFilter` for `Option`.
extension ForOption: FunctorFilter {}

// MARK: Instance of `MonadFilter` for `Option`.
extension ForOption: MonadFilter {
    public static func empty<A>() -> Kind<ForOption, A> {
        return Option.none()
    }
}

// MARK: Instance of `Foldable` for `Option`.
extension ForOption: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForOption, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let option = Option.fix(fa)
        return option.fold({ b },
                           { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ForOption, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let option = Option.fix(fa)
        return option.fold(constant(b),
                           { a in f(a, b) })
    }
}

// MARK: Instance of `Traverse` for `Option`.
extension ForOption: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForOption, B>> {
        let option = Option.fix(fa)
        return option.fold({ G.pure(Option<B>.none()) },
                           { a in G.map(f(a), Option<B>.some)})
    }
}

// MARK: Instance of `TraverseFilter` for `Option`.
extension ForOption: TraverseFilter {
    public static func traverseFilter<A, B, G: Applicative>(_ fa: Kind<ForOption, A>, _ f: @escaping (A) -> Kind<G, Kind<ForOption, B>>) -> Kind<G, Kind<ForOption, B>> {
        let option = Option.fix(fa)
        return option.fold({ G.pure(Option<B>.none()) }, f)
    }
}

// MARK: Instance of `SemigroupK` for `Option`
extension ForOption: SemigroupK {
    public static func combineK<A>(_ x: Kind<ForOption, A>, _ y: Kind<ForOption, A>) -> Kind<ForOption, A> {
        return x^.fold(constant(y), Option.some)
    }
}

// MARK: Instance of `MonoidK` for `Option`
extension ForOption: MonoidK {
    public static func emptyK<A>() -> Kind<ForOption, A> {
        return Option.none()
    }
}

// MARK: Instance of `MonadCombine` for `Option`
extension ForOption: MonadCombine {}

// MARK: Instance of `Semigroup` for `Option`, provided that `A` has an instance of `Semigroup`.
extension Option: Semigroup where A: Semigroup {
    public func combine(_ other: Option<A>) -> Option<A> {
        return self.fold(constant(other),
                         { x in other.fold(constant(self),
                                           { y in .some(x.combine(y)) })
        })
    }
}

// MARK: Instance of `Semigroupal` for `Option`,
extension ForOption: Semigroupal {
    public static func product<A, B>(_ a: Kind<ForOption, A>, _ b: Kind<ForOption, B>) -> Kind<ForOption, (A, B)> {
        ForOption.zip(a, b)
    }
}

// MARK: Instance of `Monoidal` for `Option`,
extension ForOption: Monoidal {
    public static func identity<A>() -> Kind<ForOption, A> {
        Option.none()
    }
}

// MARK: Instance of `Monoid` for `Option`, provided that `A` has an instance of `Monoid`.
extension Option: Monoid where A: Monoid {
    public static func empty() -> Option<A> {
        return Option.none()
    }
}

// MARK: Optional extensions
extension Optional {

    /// Converts this Optional value into a `Bow.Option`.
    ///
    /// This is an alias for `Optional.k()`.
    ///
    /// - Returns: An Option value with the same structure as this value.
    public func toOption() -> Option<Wrapped> {
        return Option<Wrapped>.fromOptional(self)
    }

    /// Converts this Optional value into a `Bow.Option`.
    ///
    /// This is an alias for `Optional.k()`.
    ///
    /// - Returns: An Option value with the same structure as this value.
    public func k() -> Option<Wrapped> {
        return toOption()
    }
}

extension Collection {
    /// Obtains the first element of this collection or `Option.none`.
    public var firstOrNone: Option<Element> {
        return self.first.toOption()
    }
    
    /// Obtains the first element of this collection that matches a predicate.
    ///
    /// - Parameter predicate: Filtering predicate.
    /// - Returns: First element that matches the predicate or `Option.none`.
    public func firstOrNone(_ predicate: (Element) -> Bool) -> Option<Element> {
        return self.first(where: predicate).toOption()
    }
    
    /// Returns an element if it is the single one in this collection or `Option.none`
    public var singleOrNone: Option<Element> {
        return self.count == 1 ? self.first.toOption() : .none()
    }
    
    /// Returns an element if it is the single one matching a predicate.
    ///
    /// - Parameter predicate: Filtering predicate.
    /// - Returns: A value if it is the single one matching the predicate, or `Option.none`.
    public func singleOrNone(_ predicate: (Element) -> Bool) -> Option<Element> {
        return self.filter(predicate).singleOrNone
    }
}

extension Sequence {
    /// Obtains the first element of this sequence or `Option.none`.
    public var firstOrNone: Option<Element> {
        return self.first(where: constant(true)).toOption()
    }
    
    /// Obtains the first element of this sequence that matches a predicate.
    ///
    /// - Parameter predicate: Filtering predicate.
    /// - Returns: First element that matches the predicate or `Option.none`.
    public func firstOrNone(_ predicate: (Element) -> Bool) -> Option<Element> {
        return self.first(where: predicate).toOption()
    }
}

extension BidirectionalCollection {
    /// Obtains the first element of this bidirectional collection or `Option.none`.
    public var firstOrNone: Option<Element> {
        return self.first.toOption()
    }
    
    /// Obtains the first element of this bidirectional collection that matches a predicate.
    ///
    /// - Parameter predicate: Filtering predicate.
    /// - Returns: First element that matches the predicate or `Option.none`.
    public func firstOrNone(_ predicate: (Element) -> Bool) -> Option<Element> {
        return self.first(where: predicate).toOption()
    }
    
    /// Obtains the last element of this bidirectional collection or `Option.none`.
    public var lastOrNone: Option<Element> {
        return self.last.toOption()
    }
    
    /// Obtains the last element of this bidirectional collection that matches a predicate.
    ///
    /// - Parameter predicate: Filtering predicate.
    /// - Returns: Last element that matches the predicate or `Option.none`.
    public func lastOrNone(_ predicate: (Element) -> Bool) -> Option<Element> {
        return self.last(where: predicate).toOption()
    }
    
    /// Returns an element if it is the single one in this collection or `Option.none`
    public var singleOrNone: Option<Element> {
        return self.count == 1 ? self.first.toOption() : .none()
    }
    
    /// Returns an element if it is the single one matching a predicate.
    ///
    /// - Parameter predicate: Filtering predicate.
    /// - Returns: A value if it is the single one matching the predicate, or `Option.none`.
    public func singleOrNone(_ predicate: (Element) -> Bool) -> Option<Element> {
        return self.filter(predicate).singleOrNone
    }
}

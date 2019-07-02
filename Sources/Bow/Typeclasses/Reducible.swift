import Foundation

/// Reducible augments the functions provided by `Foldable` with reducing functions that do not need an initial value.
public protocol Reducible: Foldable {
    /// Eagerly reduces a structure of values from left to right, also performing a transformation of values.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Summary value of this reduction.
    static func reduceLeftTo<A, B>(_ fa : Kind<Self, A>, _ f : (A) -> B, _ g : (B, A) -> B) -> B
    
    /// Lazily reduces a structure of values from right to left, also performing a transformation of values.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Potentially lazy summary value of this reduction.
    static func reduceRightTo<A, B>(_ fa : Kind<Self, A>, _ f : (A) -> B, _ g : (A, Eval<B>) -> Eval<B>) -> Eval<B>
}

// MARK: Related methods

public extension Reducible {
    /// Eagerly reduces a structure of values from left to right without transforming them.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Folding function.
    /// - Returns: Summary value of this reduction.
    static func reduceLeft<A>(_ fa : Kind<Self, A>, _ f : (A, A) -> A) -> A {
        return reduceLeftTo(fa, id, f)
    }

    /// Lazily reduces a structure of values from right to left without transforming them.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Folding function.
    /// - Returns: Potentially lazy summary value of this reduction.
    static func reduceRight<A>(_ fa : Kind<Self, A>, _ f : (A, Eval<A>) -> Eval<A>) -> Eval<A> {
        return reduceRightTo(fa, id, f)
    }

    /// Reduces the elements of a structure down to a single value by applying the provided transformation and aggregation funtions in a left-associative manner.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Optional summary value resulting from the folding process. It will be an `Option.none` if the structure is empty, or a value if not.
    static func reduceLeftToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Option<B> {
        return Option<B>.some(reduceLeftTo(fa, f, g))
    }

    /// Reduces the elements of a structure down to a single value by applying the provided transformation and aggregation functions in a right-associative manner.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Optional summary value resulting from the folding process. It will be an `Option.none` if the structure is empty, or a value if not.
    static func reduceRightToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Option<B>> {
        return Eval<Option<B>>.fix(reduceRightTo(fa, f, g).map(Option<B>.some))
    }

    /// Checks if a structure of values is empty.
    ///
    /// An instance of `Reducible` is never empty.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: `false` if the structure contains any value, `true` otherwise.
    static func isEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return false
    }

    /// Checks if a structure of values is not empty.
    ///
    /// An instance of `Reducible` is always non-empty.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: `true` if the structure contains any value, `false` otherwise.
    static func nonEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return true
    }

    /// Reduces a structure of values to a summary value using the combination capabilities of the `Semigroup` instance of the underlying type.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: Summary value of this reduction.
    static func reduce<A: Semigroup>(_ fa: Kind<Self, A>) -> A {
        return reduceLeft(fa, { b, a in a.combine(b) })
    }

    /// Reduces a structure of values by mapping them to a type with a `Semigroup` instance, and using its combination capabilities.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Mapping function.
    /// - Returns: Summary value of this reduction.
    static func reduceMap<A, B: Semigroup>(_ fa: Kind<Self, A>, _ f: (A) -> B) -> B {
        return reduceLeftTo(fa, f, { b, a in b.combine(f(a)) })
    }
}

// MARK: Syntax for Reducible

public extension Kind where F: Reducible {
    /// Eagerly reduces this structure of values from left to right, also performing a transformation of values.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Summary value of this reduction.
    func reduceLeftTo<B>(_ f: (A) -> B, _ g: (B, A) -> B) -> B {
        return F.reduceLeftTo(self, f, g)
    }

    /// Lazily reduces this structure of values from right to left, also performing a transformation of values.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Potentially lazy summary value of this reduction.
    func reduceRightTo<B>(_ f : (A) -> B, _ g : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return F.reduceRightTo(self, f, g)
    }

    /// Reduces this structure of values by mapping them to a type with a `Semigroup` instance, and using its combination capabilities.
    ///
    /// - Parameters:
    ///   - f: Mapping function.
    /// - Returns: Summary value of this reduction.
    func reduceMap<B: Semigroup>(_ f : (A) -> B) -> B {
        return F.reduceMap(self, f)
    }
}

public extension Kind where F: Reducible, A: Semigroup {
    /// Reduces this structure of values to a summary value using the combination capabilities of the `Semigroup` instance of the underlying type.
    ///
    /// - Returns: Summary value of this reduction.
    func reduce() -> A {
        return F.reduce(self)
    }
}

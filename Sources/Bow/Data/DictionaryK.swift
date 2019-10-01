import Foundation

/// Witness for the `DictionaryK<K, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForDictionaryK {}

/// Partial application of the DictionaryK type constructor, omitting the last parameter.
public final class DictionaryKPartial<K: Hashable>: Kind<ForDictionaryK, K> {}

/// Higher Kinded Type alias to improve readability over `Kind<DictionaryKPartial<K>, A>`
public typealias DictionaryKOf<K: Hashable, A> = Kind<DictionaryKPartial<K>, A>

/// DictionaryK is a Higher Kinded Type wrapper over Swift dictionaries.
public final class DictionaryK<K: Hashable, A>: DictionaryKOf<K, A> {
    private let dictionary: [K: A]

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to DictionaryK.
    public static func fix(_ fa: DictionaryKOf<K, A>) -> DictionaryK<K, A> {
        return fa as! DictionaryK<K, A>
    }

    /// Initializes a `DictionaryK`.
    ///
    /// - Parameter dictionary: A Swift dictionary.
    public init(_ dictionary: [K: A]) {
        self.dictionary = dictionary
    }

    /// Obtains the wrapped dictionary.
    ///
    /// - Returns: A Swift dictionary wrapped in this value.
    public func asDictionary() -> [K: A] {
        return self.dictionary
    }

    /// Zips this dictionary with another one and combines their values with the provided function.
    ///
    /// - Parameters:
    ///   - fb: A dictionary.
    ///   - f: Combining function.
    /// - Returns: Result of zipping the values of both dictionaries and combining their values.
    public func map2<B, Z>(_ fb: DictionaryK<K, B>, _ f: (A, B) -> Z) -> DictionaryK<K, Z> {
        if fb.dictionary.isEmpty {
            return DictionaryK<K, Z>([:])
        } else {
            return Dictionary<K, Z>(uniqueKeysWithValues: self.dictionary.compactMap { k, a in
                fb.dictionary[k].map{ b in (k, f(a, b)) }
            }).k()
        }
    }

    /// Zips this dictionary with a potentially lazy one and combines their values with the provided function.
    ///
    /// - Parameters:
    ///   - fb: A potentially lazy dictionary.
    ///   - f: Combining function.
    /// - Returns: Result of zipping the values of both dictionaries and combining their values.
    public func map2Eval<B, Z>(_ fb: Eval<DictionaryK<K, B>>, _ f: @escaping (A, B) -> Z) -> Eval<DictionaryK<K, Z>> {
        return Eval.fix(fb.map { b in self.map2(b, f) })
    }

    /// Sequential application.
    ///
    /// - Parameter fa: A dictionary.
    /// - Returns: A dictionary with the result of applying the functions in this dictionary to the values in the argument.
    public func ap<AA, B>(_ fa: DictionaryK<K, AA>) -> DictionaryK<K, B> where A == (AA) -> B {
        return flatMap { f in fa.map { a in f(a) }^ }
    }

    /// Applies the provided function to all values in this dictionary, flattening the final result.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A dictionary with the outputs of applying the function to all values in this dictionary.
    public func flatMap<B>(_ f: (A) -> DictionaryK<K, B>) -> DictionaryK<K, B> {
        return Dictionary<K, B>(uniqueKeysWithValues: self.dictionary.compactMap { k, a in
            f(a).dictionary[k].map { v in (k, v) }
        }).k()
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to DictionaryK.
public postfix func ^<K, A>(_ fa: DictionaryKOf<K, A>) -> DictionaryK<K, A> {
    return DictionaryK.fix(fa)
}

// MARK: Convenience functions to convert to DictionaryK
public extension Dictionary {
    /// Creates a `DictionaryK`.
    ///
    /// - Returns: A `DictionaryK` wrapping this Swift dictionary.
    func k() -> DictionaryK<Key, Value> {
        return DictionaryK<Key, Value>(self)
    }
}

// MARK: Instance of `Semigroup` for `DictionaryK`

extension DictionaryK: Semigroup {
    public func combine(_ other: DictionaryK<K, A>) -> DictionaryK<K, A> {
        (self.dictionary.combine(other.dictionary)).k()
    }
}

// MARK: Instance of `Monoid` for `DictionaryK`

extension DictionaryK: Monoid {
    public static func empty() -> DictionaryK<K, A> {
        [:].k()
    }
}

// MARK: Instance of `EquatableK` for `DictionaryK`

extension DictionaryKPartial: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<DictionaryKPartial<K>, A>, _ rhs: Kind<DictionaryKPartial<K>, A>) -> Bool {
        lhs^.asDictionary() == rhs^.asDictionary()
    }
}

// MARK: Instance of `Functor` for `DictionaryK`

extension DictionaryKPartial: Functor {
    public static func map<A, B>(_ fa: Kind<DictionaryKPartial<K>, A>, _ f: @escaping (A) -> B) -> Kind<DictionaryKPartial<K>, B> {
        fa^.asDictionary().mapValues(f).k()
    }
}

// MARK: Instance of `FunctorFilter` for `DictionaryK`

extension DictionaryKPartial: FunctorFilter {
    public static func mapFilter<A, B>(_ fa: Kind<DictionaryKPartial<K>, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<DictionaryKPartial<K>, B> {
        fa.map(f).sequence()^.fold({ DictionaryK.empty() }, id)
    }
}

// MARK: Instance of `Foldable` for `DictionaryK`

extension DictionaryKPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<DictionaryKPartial<K>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        fa^.asDictionary().values.lazy.reduce(b, f)
    }
    
    public static func foldRight<A, B>(_ fa: Kind<DictionaryKPartial<K>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.asDictionary().values.reversed().lazy.reduce(b) { b, a in f(a, b) }
    }
}

// MARK: Instance of `Traverse` for `DictionaryK`

extension DictionaryKPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<DictionaryKPartial<K>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<DictionaryKPartial<K>, B>> {
        var result = G.pure([K: B]())
        fa^.asDictionary().forEach { item in
            result = G.map(f(item.value), result) { x, y in
                y.combine([item.key: x])
            }
        }
        return result.map { x in x.k() }
    }
}

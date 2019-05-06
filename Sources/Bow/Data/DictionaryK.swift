import Foundation

/// Witness for the `DictionaryK<K, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForDictionaryK {}

/// Partial application of the DictionaryK type constructor, omitting the last parameter.
public final class DictionaryKPartial<K>: Kind<ForDictionaryK, K> {}

/// Higher Kinded Type alias to improve readability over `Kind<DictionaryKPartial<K>, A>`
public typealias DictionaryKOf<K, A> = Kind<DictionaryKPartial<K>, A>

/// DictionaryK is a Higher Kinded Type wrapper over Swift dictionaries.
public class DictionaryK<K: Hashable, A>: DictionaryKOf<K, A> {
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

    /// Creates a new value transforming the type using the provided function, preserving the structure of the dictionary.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the dictionary.
    public func map<B>(_ f : (A) -> B) -> DictionaryK<K, B> {
        return DictionaryK<K, B>(self.dictionary.mapValues(f))
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
        return flatMap(fa.map)
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

    /// Eagerly reduces the values of this dictionary to a summary value.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: A summary value resulting from the folding process.
    public func foldLeft<B>(_ b: B, _ f: (B, A) -> B) -> B {
        return self.dictionary.values.reduce(b, f)
    }

    /// Lazily reduces the values of this dictionary to a summary value.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: A summary value resulting from the folding process.
    public func foldRight<B>(_ b: Eval<B>, _ f: (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.dictionary.values.reversed().reduce(b) { b, a in f(a, b) }
    }

    /// Eagerly reduces the values of this dictionary to a summary dictionary.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: A summary dictionary resulting from the folding process.
    public func foldLeft<B>(_ b: DictionaryK<K, B>, _ f: (DictionaryK<K, B>, (K, A)) -> DictionaryK<K, B>) -> DictionaryK<K, B> {
        return self.dictionary.reduce(b) { m, pair in f(m, pair) }
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

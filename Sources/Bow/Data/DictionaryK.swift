import Foundation

public final class ForDictionaryK {}
public final class DictionaryKPartial<K>: Kind<ForDictionaryK, K> {}
public typealias DictionaryKOf<K, A> = Kind<DictionaryKPartial<K>, A>

public class DictionaryK<K : Hashable, A> : DictionaryKOf<K, A> {
    private let dictionary : [K : A]
    
    public static func fix(_ fa : DictionaryKOf<K, A>) -> DictionaryK<K, A> {
        return fa as! DictionaryK<K, A>
    }
    
    public init(_ dictionary : [K : A]) {
        self.dictionary = dictionary
    }
    
    public var isEmpty : Bool {
        return dictionary.isEmpty
    }
    
    public func asDictionary() -> [K : A] {
        return self.dictionary
    }
    
    public func map<B>(_ f : (A) -> B) -> DictionaryK<K, B> {
        return DictionaryK<K, B>(self.dictionary.mapValues(f))
    }
    
    public func map2<B, Z>(_ fb : DictionaryK<K, B>, _ f : (A, B) -> Z) -> DictionaryK<K, Z> {
        if fb.isEmpty {
            return DictionaryK<K, Z>([:])
        } else {
            return Dictionary<K, Z>(uniqueKeysWithValues: self.dictionary.compactMap{ k, a in
                fb.dictionary[k].map{ b in (k, f(a, b)) }
            }).k()
        }
    }
    
    public func map2Eval<B, Z>(_ fb : Eval<DictionaryK<K, B>>, _ f : @escaping (A, B) -> Z) -> Eval<DictionaryK<K, Z>> {
        return fb.map{ b in self.map2(b, f) }
    }
    
    public func ap<AA, B>(_ fa : DictionaryK<K, AA>) -> DictionaryK<K, B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func flatMap<B>(_ f : (A) -> DictionaryK<K, B>) -> DictionaryK<K, B> {
        return Dictionary<K, B>(uniqueKeysWithValues: self.dictionary.compactMap { k, a in
            f(a).dictionary[k].map{ v in (k, v) }
        }).k()
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return self.dictionary.values.reduce(b, f)
    }
    
    public func foldRight<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.dictionary.values.reversed().reduce(b, { b, a in f(a, b) })
    }
    
    public func foldLeft<B>(_ b : DictionaryK<K, B>, _ f : (DictionaryK<K, B>, (K, A)) -> DictionaryK<K, B>) -> DictionaryK<K, B> {
        return self.dictionary.reduce(b, { m, pair in f(m, pair) })
    }
}

extension DictionaryK: Fixed {}

public extension Dictionary {
    public func k() -> DictionaryK<Key, Value> {
        return DictionaryK<Key, Value>(self)
    }
}

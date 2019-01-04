import Foundation

public class ForMapK {}
public typealias MapKOf<K, A> = Kind2<ForMapK, K, A>

public class MapK<K : Hashable, A> : MapKOf<K, A> {
    private let dictionary : [K : A]
    
    public static func fix(_ fa : MapKOf<K, A>) -> MapK<K, A> {
        return fa as! MapK<K, A>
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
    
    public func map<B>(_ f : (A) -> B) -> MapK<K, B> {
        return MapK<K, B>(self.dictionary.mapValues(f))
    }
    
    public func map2<B, Z>(_ fb : MapK<K, B>, _ f : (A, B) -> Z) -> MapK<K, Z> {
        if fb.isEmpty {
            return MapK<K, Z>([:])
        } else {
            return Dictionary<K, Z>(uniqueKeysWithValues: self.dictionary.compactMap{ k, a in
                fb.dictionary[k].map{ b in (k, f(a, b)) }
            }).k()
        }
    }
    
    public func map2Eval<B, Z>(_ fb : Eval<MapK<K, B>>, _ f : @escaping (A, B) -> Z) -> Eval<MapK<K, Z>> {
        return fb.map{ b in self.map2(b, f) }
    }
    
    public func ap<AA, B>(_ fa : MapK<K, AA>) -> MapK<K, B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func flatMap<B>(_ f : (A) -> MapK<K, B>) -> MapK<K, B> {
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
    
    public func foldLeft<B>(_ b : MapK<K, B>, _ f : (MapK<K, B>, (K, A)) -> MapK<K, B>) -> MapK<K, B> {
        return self.dictionary.reduce(b, { m, pair in f(m, pair) })
    }
}

public extension Dictionary {
    public func k() -> MapK<Key, Value> {
        return MapK<Key, Value>(self)
    }
}

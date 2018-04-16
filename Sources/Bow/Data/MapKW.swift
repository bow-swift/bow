//
//  MapKW.swift
//  Bow
//
//  Created by Tomás Ruiz López on 12/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ForMapKW {}

public class MapKW<K : Hashable, A> : Kind2<ForMapKW, K, A> {
    private let dictionary : [K : A]
    
    public static func fix(_ fa : Kind2<ForMapKW, K, A>) -> MapKW<K, A> {
        return fa as! MapKW<K, A>
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
    
    public func map<B>(_ f : (A) -> B) -> MapKW<K, B> {
        return MapKW<K, B>(self.dictionary.mapValues(f))
    }
    
    public func map2<B, Z>(_ fb : MapKW<K, B>, _ f : (A, B) -> Z) -> MapKW<K, Z> {
        if fb.isEmpty {
            return MapKW<K, Z>([:])
        } else {
            return Dictionary<K, Z>(uniqueKeysWithValues: self.dictionary.compactMap{ k, a in
                fb.dictionary[k].map{ b in (k, f(a, b)) }
            }).k()
        }
    }
    
    public func map2Eval<B, Z>(_ fb : Eval<MapKW<K, B>>, _ f : @escaping (A, B) -> Z) -> Eval<MapKW<K, Z>> {
        return fb.map{ b in self.map2(b, f) }
    }
    
    public func ap<B>(_ ff : MapKW<K, (A) -> B>) -> MapKW<K, B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> MapKW<K, B>) -> MapKW<K, B> {
        return Dictionary<K, B>(uniqueKeysWithValues: self.dictionary.compactMap { k, a in
            f(a).dictionary[k].map{ v in (k, v) }
        }).k()
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return self.dictionary.values.reduce(b, f)
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return self.dictionary.values.reversed().reduce(b, { b, a in f(a, b) })
    }
    
    public func foldLeft<B>(_ b : MapKW<K, B>, _ f : (MapKW<K, B>, (K, A)) -> MapKW<K, B>) -> MapKW<K, B> {
        return self.dictionary.reduce(b, { m, pair in f(m, pair) })
    }
}

public extension Dictionary {
    public func k() -> MapKW<Key, Value> {
        return MapKW<Key, Value>(self)
    }
}

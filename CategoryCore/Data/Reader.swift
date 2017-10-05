//
//  Reader.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 5/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class Reader<D, A> : ReaderT<IdF, D, A> {
    public static func pure(_ run : @escaping (D) -> A) -> Reader<D, A> {
        return Reader(run)
    }
    
    public static func ask() -> Reader<D, D> {
        return Kleisli<IdF, D, A>.ask(Id<A>.applicative()) as! Reader<D, D>
    }
    
    public init(_ run : @escaping (D) -> A) {
        super.init(run >> Id<A>.pure)
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Reader<D, B> {
        return self.map(f, Id<A>.functor()) as! Reader<D, B>
    }
    
    public func ap<B>(_ ff : Reader<D, (A) -> B>) -> Reader<D, B> {
        return self.ap(ff, Id<A>.applicative()) as! Reader<D, B>
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Reader<D, B>) -> Reader<D, B> {
        return self.flatMap(f, Id<A>.monad()) as! Reader<D, B>
    }
    
    public func zip<B>(_ other : Reader<D, B>) -> Reader<D, (A, B)> {
        return self.zip(other, Id<A>.monad()) as! Reader<D, (A, B)>
    }
    
    public func andThen<B>(_ other : Reader<A, B>) -> Reader<D, B> {
        return self.andThen(other, Id<A>.monad()) as! Reader<D, B>
    }
    
    public func andThen<B>(_ f : @escaping (A) -> Id<B>) -> Reader<D, B> {
        return self.andThen(f, Id<A>.monad()) as! Reader<D, B>
    }
    
    public func andThen<B>(_ other : Id<B>) -> Reader<D, B> {
        return self.andThen(other, Id<A>.monad()) as! Reader<D, B>
    }
}

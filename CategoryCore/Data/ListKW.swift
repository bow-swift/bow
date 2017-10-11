//
//  ListKW.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 11/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ListKWF {}

public class ListKW<A> : HK<ListKWF, A> {
    private let list : [A]
    
    public static func +(lhs : ListKW<A>, rhs : ListKW<A>) -> ListKW<A> {
        return ListKW(lhs.list + rhs.list)
    }
    
    public static func pure(_ a : A) -> ListKW<A> {
        return ListKW([a])
    }
    
    public static func empty() -> ListKW<A> {
        return ListKW([])
    }
    
    private static func go<B>(_ buf : [B], _ f : (A) -> HK<ListKWF, Either<A, B>>, _ v : ListKW<Either<A, B>>) -> [B] {
        if !v.isEmpty {
            let head = v.list[0]
            return head.fold({ a in go(buf, f, ListKW<Either<A, B>>(f(a).ev().list + v.list.dropFirst())) },
                      { b in
                            let newBuf = buf + [b]
                            return go(newBuf, f, ListKW<Either<A, B>>([Either<A, B>](v.list.dropFirst())))
                      })
        } else {
            return buf
        }
    }
    
    private static func tailRecM<B>(_ a : A, _ f : (A) -> HK<ListKWF, Either<A, B>>) -> ListKW<B> {
        return ListKW<B>(go([], f, f(a).ev()))
    }
    
    public init(_ list : [A]) {
        self.list = list
    }
    
    public var asArray : [A] {
        return list
    }
    
    public var isEmpty : Bool {
        return list.isEmpty
    }
    
    public func map<B>(_ f : (A) -> B) -> ListKW<B> {
        return ListKW<B>(self.list.map(f))
    }
    
    public func ap<B>(_ ff : ListKW<(A) -> B>) -> ListKW<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> ListKW<B>) -> ListKW<B> {
        return ListKW<B>(list.flatMap({ a in f(a).list }))
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return list.reduce(b, f)
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ lkw : ListKW<A>) -> Eval<B> {
            if lkw.list.isEmpty {
                return b
            } else {
                return f(lkw.list[0], Eval.deferEvaluation({ loop(ListKW([A](lkw.list.dropFirst())))  }))
            }
        }
        return Eval.deferEvaluation({ loop(self) })
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, ListKW<B>> where Appl : Applicative, Appl.F == G {
        return foldR(Eval.always({ applicative.pure(ListKW<B>([])) }),
                     { a, eval in applicative.map2Eval(f(a), eval, { x, y in ListKW<B>([x]) + y }) }).value()
    }
    
    public func map2<B, Z>(_ fb : ListKW<B>, _ f : ((A, B)) -> Z) -> ListKW<Z> {
        return self.flatMap { a in
            fb.map{ b in
                f((a, b))
            }
        }
    }
    
    public func mapFilter<B>(_ f : (A) -> Maybe<B>) -> ListKW<B> {
        return flatMap { a in f(a).fold(ListKW<B>.empty, ListKW<B>.pure) }
    }
    
    public func combineK(_ y : ListKW<A>) -> ListKW<A> {
        return self + y
    }
}

public extension HK where F == ListKWF {
    public func ev() -> ListKW<A> {
        return self as! ListKW<A>
    }
}

public extension Array {
    public func k() -> ListKW<Element> {
        return ListKW(self)
    }
}

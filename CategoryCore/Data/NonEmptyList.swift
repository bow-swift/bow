//
//  NonEmptyList.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 11/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class NonEmptyListF {}

public typealias Nel<A> = NonEmptyList<A>

public class NonEmptyList<A> : HK<NonEmptyListF, A> {
    private let head : A
    private let tail : [A]
    
    public static func +(lhs : NonEmptyList<A>, rhs : NonEmptyList<A>) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }
    
    public static func +(lhs : NonEmptyList<A>, rhs : [A]) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + rhs)
    }
    
    public static func +(lhs : NonEmptyList<A>, rhs : A) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + [rhs])
    }
    
    public static func of(_ head : A, _ tail : A...) -> NonEmptyList<A> {
        return NonEmptyList(head: head, tail: tail)
    }
    
    public static func fromArray(_ array : [A]) -> Maybe<NonEmptyList<A>> {
        return array.isEmpty ? Maybe<NonEmptyList<A>>.none() : Maybe<NonEmptyList<A>>.some(NonEmptyList(all: array))
    }
    
    public static func fromArrayUnsafe(_ array : [A]) -> NonEmptyList<A> {
        return NonEmptyList(all: array)
    }
    
    public static func pure(_ a : A) -> NonEmptyList<A> {
        return of(a)
    }
    
    private static func go<B>(_  buf : [B], _ f : @escaping (A) -> HK<NonEmptyListF, Either<A, B>>, _ v : NonEmptyList<Either<A, B>>) -> [B] {
        let head = v.head
        return head.fold({ a in go(buf, f, (f(a) as! NonEmptyList<Either<A, B>>) + v.tail) },
                  { b in
                    let newBuf = buf + [b]
                    let x = NonEmptyList<Either<A, B>>.fromArray(v.tail)
                    return x.fold({ newBuf },
                                  { value in go(newBuf, f, value) })
                  })
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> HK<NonEmptyListF, Either<A, B>>) -> NonEmptyList<B> {
        return NonEmptyList<B>.fromArrayUnsafe(go([], f, f(a) as! NonEmptyList<Either<A, B>>))
    }
    
    public init(head : A, tail : [A]) {
        self.head = head
        self.tail = tail
    }
    
    private init(all : [A]) {
        self.head = all[0]
        self.tail = [A](all.dropFirst(1))
    }
    
    public var count : Int {
        return 1 + tail.count
    }
    
    public let isEmpty = false
    
    public func all() -> [A] {
        return [head] + tail
    }
    
    public func map<B>(_ f : (A) -> B) -> NonEmptyList<B> {
        return NonEmptyList<B>(head: f(head), tail: tail.map(f))
    }
    
    public func flatMap<B>(_ f : (A) -> NonEmptyList<B>) -> NonEmptyList<B> {
        return f(head) + tail.flatMap{ a in f(a).all() }
    }
    
    public func ap<B>(_ ff : NonEmptyList<(A) -> B>) -> NonEmptyList<B> {
        return ff.flatMap(map)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return tail.reduce(f(b, head), f)
    }
    
    public func coflatMap<B>(_ f : @escaping (NonEmptyList<A>) -> B) -> NonEmptyList<B> {
        func consume(_ list : [A], _ buf : [B] = []) -> [B] {
            if list.isEmpty {
                return buf
            } else {
                let tail = [A](list.dropFirst())
                let newBuf = buf + [f(NonEmptyList(head: list[0], tail: tail))]
                return consume(tail, newBuf)
            }
        }
        return NonEmptyList<B>(head: f(self), tail: consume(self.tail))
    }
    
    public func extract() -> A {
        return head
    }
    
    public func combineK(_ y : NonEmptyList<A>) -> NonEmptyList<A> {
        return self + y
    }
}

public extension NonEmptyList where A : Equatable {
    public func contains(element : A) -> Bool {
        return head == element || tail.contains(where: { $0 == element })
    }
    
    public func containsAll(elements: [A]) -> Bool {
        return elements.map(contains).reduce(true, and)
    }
}

extension NonEmptyList : CustomStringConvertible {
    public var description : String {
        return "NonEmptyList(\(self.all())"
    }
}

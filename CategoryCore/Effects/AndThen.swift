//
//  AndThen.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

internal class AndThen<A, B> {
    public static func create(_ f : @escaping (A) throws -> B) -> AndThen<A, B> {
        return Single(f)
    }
    
    public static func create(_ fa : @escaping (A) throws -> B, _ fe : @escaping (Error) throws -> B) -> AndThen<A, B> {
        return ErrorHandler(fa, fe)
    }
    
    func invoke(_ a : A) throws -> B {
        return try runLoop(a, nil, true)
    }
    
    func andThen<C>(_ g : AndThen<B, C>) -> AndThen<A, C> {
        return Concat<A, B, C>(self, g)
    }
    
    func compose<C>(_ g : AndThen<C, A>) -> AndThen<C, B> {
        return Concat<C, A, B>(g, self)
    }
    
    func error(_ anError : Error, _ fe : (Error) -> B) -> B {
        do {
            return try runLoop(nil, anError, false)
        } catch {
            return fe(error)
        }
    }
    
    func error(_ anError : Error, _ fe : Function1<Error, B>) -> B {
        do {
            return try runLoop(nil, anError, false)
        } catch {
            return fe.invoke(error)
        }
    }
    
    func rotateAccum<C>(_ right : AndThen<B, C>) -> AndThen<A, C> {
        return self.rotateAccumChildren(right)
    }
    
    func rotateAccumChildren<C>(_ right : AndThen<B, C>) -> AndThen<A, C>{
        return self.andThen(right)
    }
    
    func runLoopChildren(_ success : A?, _ failure : Error?, _ isSuccess : Bool) throws -> B {
        fatalError("Implement in subclasses")
    }
    
    func runLoop(_ success : A?, _ failure : Error?, _ isSuccess : Bool) throws -> B {
        return try runLoopChildren(success, failure, isSuccess)
    }
}

fileprivate class Single<A, B> : AndThen<A, B> {
    let f : (A) throws -> B
    
    init(_ f : @escaping (A) throws -> B) {
        self.f = f
    }
    
    override func runLoopChildren(_ success: A?, _ failure: Error?, _ isSuccess: Bool) throws -> B {
        if isSuccess {
            let (newSuccess, newFailure, _) = processSuccess(f, success!, failure, isSuccess)
            if let success = newSuccess {
                return success
            } else {
                throw newFailure!
            }
        }
        throw failure!
    }
}

fileprivate class ErrorHandler<A, B> : AndThen<A, B> {
    let fa : (A) throws -> B
    let fe : (Error) throws -> B
    
    init(_ fa : @escaping (A) throws -> B, _ fe : @escaping (Error) throws -> B) {
        self.fa = fa
        self.fe = fe
    }
    
    override func runLoopChildren(_ success: A?, _ failure: Error?, _ isSuccess: Bool) throws -> B {
        let newSuccess : B?, newFailure : Error?
        if isSuccess {
            (newSuccess, newFailure, _) = processSuccess(fa, success!, failure, isSuccess)
        } else {
            (newSuccess, newFailure, _) = processError(fe, failure, isSuccess)
        }
        
        if let success = newSuccess {
            return success
        } else {
            throw newFailure!
        }
    }
}

fileprivate class Concat<A, E, B> : AndThen<A, B> {
    let left : AndThen<A, E>
    let right : AndThen<E, B>
    
    init(_ left : AndThen<A, E>, _ right : AndThen<E, B>) {
        self.left = left
        self.right = right
    }
    
    override func rotateAccumChildren<C>(_ right: AndThen<B, C>) -> AndThen<A, C> {
        return self.left.rotateAccum(self.right.andThen(right))
    }
    
    override func runLoopChildren(_ success: A?, _ failure: Error?, _ isSuccess: Bool) throws -> B {
        let (this, newSuccess, newFailure, newIsSuccess) = processConcat(left, right, success, failure, isSuccess)
        return try this.runLoop(newSuccess, newFailure, newIsSuccess)
    }
}

fileprivate func processSuccess<X, Y>(_ f : (X) throws -> Y, _ success : X, _ failure : Error?, _ isSuccess : Bool) -> (Y?, Error?, Bool) {
    do {
        return (try f(success), failure, isSuccess)
    } catch {
        return (nil, error, false)
    }
}

fileprivate func processError<X>(_ f : (Error) throws -> X, _ failure : Error?, _ isSuccess : Bool) -> (X?, Error?, Bool) {
    do {
        return (try f(failure!), failure, true)
    } catch {
        return (nil, failure, isSuccess)
    }
}

fileprivate func processConcat<X, Y, Z>(_ left : AndThen<X, Y>, _ right : AndThen<Y, Z>, _ success : X?, _ failure : Error?, _ isSuccess : Bool) -> (AndThen<Y, Z>, Y?, Error?, Bool){
    return processConcatChildren(left, right, success, failure, isSuccess)
}

fileprivate func processConcatChildren<A, B, C, X>(_ left : Single<A, B>, _ right: AndThen<B, C>, _ success: A?, _ failure: Error?, _ isSuccess: Bool) -> (AndThen<X, C>, X?, Error?, Bool) {
    if isSuccess {
        let (newSuccess, newFailure, newIsSuccess) = processSuccess(left.f, success!, failure, isSuccess)
        return (right as! AndThen<X, C>, newSuccess as! X?, newFailure, newIsSuccess)
    }
    return (right as! AndThen<X, C>, success as! X?, failure, isSuccess)
}

fileprivate func processConcatChildren<A, B, C, X>(_ left : ErrorHandler<A, B>, _ right: AndThen<B, C>, _ success: A?, _ failure: Error?, _ isSuccess: Bool) -> (AndThen<X, C>, X?, Error?, Bool) {
    if isSuccess {
        let (newSuccess, newFailure, newIsSuccess) = processSuccess(left.fa, success!, failure, isSuccess)
        return (right as! AndThen<X, C>, newSuccess as! X?, newFailure, newIsSuccess)
    } else {
        let (newSuccess, newFailure, newIsSuccess) = processError(left.fe, failure, isSuccess)
        return (right as! AndThen<X, C>, newSuccess as! X?, newFailure, newIsSuccess)
    }
}

fileprivate func processConcatChildren<A, B, C, X>(_ left : AndThen<A, B>, _ right: AndThen<B, C>, _ success: A?, _ failure: Error?, _ isSuccess: Bool) -> (AndThen<X, C>, X?, Error?, Bool) {
    return (left.rotateAccum(right) as! AndThen<X, C>, success as! X?, failure, isSuccess)
}

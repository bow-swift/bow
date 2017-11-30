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
    
    func rotateAccum<E>(_ _right : AndThen<B, E>) -> AndThen<A, E> {
        var me = self as! AndThen<Any?, Any?>
        var right = _right as! AndThen<Any?, Any?>
        var continued = true
        
        while continued {
            (me, right, continued) = me.rotateAccumChildren(right)
        }
        
        return me as! AndThen<A, E>
    }
    
    func rotateAccumChildren(_ right : AndThen<Any?, Any?>) -> (AndThen<Any?, Any?>, AndThen<Any?, Any?>, Bool){
        let me = self as! AndThen<Any?, Any?>
        return (me.andThen(right), right, false)
    }
    
    func runLoop(_ _success : A?, _ _failure : Error?, _ _isSuccess : Bool) throws -> B {
        var this = self as! AndThen<Any?, Any?>
        var success : Any? = _success
        var failure = _failure
        var isSuccess = _isSuccess
        var continues = true
        
        func processSuccess(_ f : (Any?) throws -> Any?) {
            do {
                success = try f(success)
            } catch {
                failure = error
                isSuccess = false
            }
        }
        
        func processError(_ f : (Error) throws -> Any?) {
            do {
                success = try f(failure!)
                isSuccess = true
            } catch {
                failure = error
            }
        }
        
        func processConcat(_ left : AndThen<Any?, Any?>, _ right : AndThen<Any?, Any?>) -> AndThen<Any?, Any?> {
            switch left {
            case is Single<Any?, Any?>:
                if isSuccess {
                    processSuccess((left as! Single<Any?, Any?>).f)
                }
                return right
            case is ErrorHandler<Any?, Any?>:
                if isSuccess {
                    processSuccess((left as! ErrorHandler<Any?, Any?>).fa)
                } else {
                    processError((left as! ErrorHandler<Any?, Any?>).fe)
                }
                return right
            case is Concat<Any?, Any?, Any?>:
                return left.rotateAccum(right)
            default:
                fatalError("No other cases")
            }
        }
        
        while(continues) {
            switch(this) {
            case is Single<Any?, Any?>:
                if isSuccess {
                    processSuccess((this as! Single<Any?, Any?>).f)
                }
                continues = false
            case is ErrorHandler<Any?, Any?>:
                if isSuccess {
                    processSuccess((this as! ErrorHandler).fa)
                } else {
                    processError((this as! ErrorHandler).fe)
                }
                continues = false
            case is Concat<Any?, Any?, Any?>:
                let left = (this as! Concat<Any?, Any?, Any?>).left
                let right = (this as! Concat<Any?, Any?, Any?>).right
                this = processConcat(left, right)
            default:
                fatalError("No other cases for AndThen")
            }
        }
        
        if isSuccess {
            return success as! B
        } else {
            throw failure!
        }
        
    }
}

fileprivate class Single<A, B> : AndThen<A, B> {
    let f : (A) throws -> B
    
    init(_ f : @escaping (A) throws -> B) {
        self.f = f
    }
}

fileprivate class ErrorHandler<A, B> : AndThen<A, B> {
    let fa : (A) throws -> B
    let fe : (Error) throws -> B
    
    init(_ fa : @escaping (A) throws -> B, _ fe : @escaping (Error) throws -> B) {
        self.fa = fa
        self.fe = fe
    }
}

fileprivate class Concat<A, E, B> : AndThen<A, B> {
    let left : AndThen<A, E>
    let right : AndThen<E, B>
    
    init(_ left : AndThen<A, E>, _ right : AndThen<E, B>) {
        self.left = left
        self.right = right
    }
    
    override func rotateAccumChildren(_ right: AndThen<Any?, Any?>) -> (AndThen<Any?, Any?>, AndThen<Any?, Any?>, Bool) {
        let me = self as! Concat<Any?, Any?, Any?>
        return (me.left, me.right.andThen(right), true)
    }
}

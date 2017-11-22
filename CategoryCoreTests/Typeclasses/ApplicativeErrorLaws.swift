//
//  ApplicativeErrorLaws.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 22/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import CategoryCore

enum CategoryError : Error {
    case common
    case fatal
    case unknown
    
    static var eq : CategoryErrorEq {
        return CategoryErrorEq()
    }
}

class CategoryErrorEq : Eq {
    typealias A = CategoryError
    
    func eqv(_ a: CategoryError, _ b: CategoryError) -> Bool {
        switch (a, b) {
        case (.common, .common), (.fatal, .fatal), (.unknown, .unknown): return true
        default: return false
        }
    }
}

extension CategoryError : Arbitrary {
    static var arbitrary: Gen<CategoryError> {
        return Gen<CategoryError>.fromElements(of: [CategoryError.common, CategoryError.fatal, CategoryError.unknown])
    }
}

fileprivate var genEither : Gen<Either<CategoryError, Int>> {
    return Gen.zip(CategoryError.arbitrary, Int.arbitrary).map({ (error, number) in arc4random_uniform(2) == 0 ? Either.left(error) : Either.right(number) })
}

class ApplicativeErrorLaws<F> {
    
    static func check<ApplErr, EqF, EqEither>(applicativeError : ApplErr, eq : EqF, eqEither : EqEither) where
        ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError,
        EqF : Eq, EqF.A == HK<F, Int>,
        EqEither : Eq, EqEither.A == HK<F, HK2<EitherF, CategoryError, Int>> {
        handle(applicativeError, eq)
        handleWith(applicativeError, eq)
        handleWithPure(applicativeError, eq)
        attemptError(applicativeError, eqEither)
        attemptSuccess(applicativeError, eqEither)
        attemptFromEitherConsistentWithPure(applicativeError, eqEither)
        catchesError(applicativeError, eq)
        catchesSuccess(applicativeError, eq)
    }
    
    private static func handle<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Applicative error handle") <- forAll { (error : CategoryError, a : Int) in
            let f = { (_ : CategoryError) in a }
            return eq.eqv(applicativeError.handleError(applicativeError.raiseError(error), f),
                          applicativeError.pure(f(error)))
        }
    }
    
    private static func handleWith<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Applicative error handle with") <- forAll { (error : CategoryError, a : Int) in
            let f = { (_ : CategoryError) in applicativeError.pure(a) }
            return eq.eqv(applicativeError.handleErrorWith(applicativeError.raiseError(error), f),
                          f(error))
        }
    }
    
    private static func handleWithPure<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Applicative error handle with pure") <- forAll { (error : CategoryError, a : Int) in
            let f = { (_ : CategoryError) in applicativeError.pure(a) }
            return eq.eqv(applicativeError.handleErrorWith(applicativeError.pure(a), f),
                          applicativeError.pure(a))
        }
    }
    
    private static func attemptError<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, HK2<EitherF, CategoryError, Int>> {
        property("Attempt error") <- forAll { (error : CategoryError) in
            let a = applicativeError.attempt(applicativeError.raiseError(error)) as HK<F, Either<CategoryError, Int>>
            let b = applicativeError.pure(Either<CategoryError, Int>.left(error))
            
            return eq.eqv(applicativeError.map(a, { aa in aa as HK2<EitherF, CategoryError, Int> }),
                          applicativeError.map(b, { bb in bb as HK2<EitherF, CategoryError, Int> }))
        }
    }
    
    private static func attemptSuccess<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, HK2<EitherF, CategoryError, Int>> {
        property("Attempt success") <- forAll { (a : Int) in
            let x = applicativeError.attempt(applicativeError.pure(a)) as HK<F, Either<CategoryError, Int>>
            let y = applicativeError.pure(Either<CategoryError, Int>.right(a))
            
            return eq.eqv(applicativeError.map(x, { xx in xx as HK2<EitherF, CategoryError, Int> }),
                          applicativeError.map(y, { yy in yy as HK2<EitherF, CategoryError, Int> }))
        }
    }
    
    private static func attemptFromEitherConsistentWithPure<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, HK2<EitherF, CategoryError, Int>> {
        property("Attempt from either consistent with pure") <- forAll { (a : CategoryError, b : Int) in
            let either = arc4random_uniform(2) == 0 ? Either.left(a) : Either.right(b)
            let x = applicativeError.attempt(applicativeError.fromEither(either))
            let y = applicativeError.pure(either)
            return eq.eqv(applicativeError.map(x, { xx in xx as HK2<EitherF, CategoryError, Int> }),
                          applicativeError.map(y, { yy in yy as HK2<EitherF, CategoryError, Int> }))
        }
    }
    
    private static func catchesError<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Catch") <- forAll { (error : CategoryError) in
            let f : () throws -> Int = { throw error }
            return eq.eqv(applicativeError.catchError(f, recover: { e in e as! CategoryError }),
                          applicativeError.raiseError(error))
        }
    }
    
    private static func catchesSuccess<ApplErr, EqF>(_ applicativeError : ApplErr, _ eq : EqF) where ApplErr : ApplicativeError, ApplErr.F == F, ApplErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Catch") <- forAll { (a : Int) in
            let f : () throws -> Int = { return a }
            return eq.eqv(applicativeError.catchError(f, recover: { e in e as! CategoryError }),
                          applicativeError.pure(a))
        }
    }
}

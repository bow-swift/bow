import XCTest
import SwiftCheck
@testable import Bow

class ListKTest: XCTestCase {
    
    var generator : (Int) -> ListKOf<Int> {
        return { a in ListK<Int>.pure(a) }
    }
    
    let eq = ListK.eq(Int.order)
    let eqUnit = ListK.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForListK>.check(functor: ListK<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForListK>.check(applicative: ListK<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForListK>.check(monad: ListK<Int>.monad(), eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("ListK semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<ListKOf<Int>>.check(
                semigroup: ListK<Int>.semigroup(),
                a: ListK<Int>.pure(a),
                b: ListK<Int>.pure(b),
                c: ListK<Int>.pure(c),
                eq: self.eq)
        }
        
        property("ListK semigroupK algebra semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(
                semigroup: ListK<Int>.semigroupK().algebra(),
                a: ListK<Int>.pure(a),
                b: ListK<Int>.pure(b),
                c: ListK<Int>.pure(c),
                eq: self.eq)
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws.check(semigroupK: ListK<Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidLaws() {
        property("ListK monoid laws") <- forAll() { (a : Int) in
            return MonoidLaws<ListKOf<Int>>.check(monoid: ListK<Int>.monoid(), a: ListK<Int>.pure(a), eq: self.eq)
        }
    }
    
    func testMonoidKLaws() {
        MonoidKLaws.check(monoidK: ListK<Int>.monoidK(), generator: self.generator, eq: self.eq)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForListK>.check(functorFilter: ListK<Int>.functorFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForListK>.check(monadFilter: ListK<Int>.monadFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForListK>.check(foldable: ListK<Int>.foldable(), generator: self.generator)
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<ForListK>.check(monadCombine: ListK<Int>.monadCombine(), eq: self.eq)
    }
}

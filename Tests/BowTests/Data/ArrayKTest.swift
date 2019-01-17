import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class ArrayKTest: XCTestCase {
    
    var generator : (Int) -> ArrayKOf<Int> {
        return { a in ArrayK<Int>.pure(a) }
    }
    
    let eq = ArrayK.eq(Int.order)
    let eqUnit = ArrayK.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForArrayK>.check(functor: ArrayK<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForArrayK>.check(applicative: ArrayK<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForArrayK>.check(monad: ArrayK<Int>.monad(), eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("ArrayK semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<ArrayKOf<Int>>.check(
                semigroup: ArrayK<Int>.semigroup(),
                a: ArrayK<Int>.pure(a),
                b: ArrayK<Int>.pure(b),
                c: ArrayK<Int>.pure(c),
                eq: self.eq)
        }
        
        property("ArrayK semigroupK algebra semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(
                semigroup: ArrayK<Int>.semigroupK().algebra(),
                a: ArrayK<Int>.pure(a),
                b: ArrayK<Int>.pure(b),
                c: ArrayK<Int>.pure(c),
                eq: self.eq)
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws.check(semigroupK: ArrayK<Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidLaws() {
        property("ArrayK monoid laws") <- forAll() { (a : Int) in
            return MonoidLaws<ArrayKOf<Int>>.check(monoid: ArrayK<Int>.monoid(), a: ArrayK<Int>.pure(a), eq: self.eq)
        }
        
        property("ArrayK monoidK algebra monoid laws") <- forAll() { (a : Int) in
            return MonoidLaws<ArrayKOf<Int>>.check(monoid: ArrayK<Int>.monoidK().algebra(), a: ArrayK<Int>.pure(a), eq: self.eq)
        }
    }
    
    func testMonoidKLaws() {
        MonoidKLaws.check(monoidK: ArrayK<Int>.monoidK(), generator: self.generator, eq: self.eq)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForArrayK>.check(functorFilter: ArrayK<Int>.functorFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForArrayK>.check(monadFilter: ArrayK<Int>.monadFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForArrayK>.check(foldable: ArrayK<Int>.foldable(), generator: self.generator)
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<ForArrayK>.check(monadCombine: ArrayK<Int>.monadCombine(), eq: self.eq)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForArrayK>.check(traverse: ArrayK<Int>.traverse(),
                                     functor: ArrayK<Int>.functor(),
                                     generator: self.generator,
                                     eq: self.eq)
    }
}

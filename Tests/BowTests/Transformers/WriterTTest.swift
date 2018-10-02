import XCTest
import SwiftCheck
@testable import Bow

class WriterTTest: XCTestCase {
    
    var generator : (Int) -> WriterTOf<ForId, Int, Int> {
        return { a in WriterT.pure(a, Int.sumMonoid, Id<Any>.applicative()) }
    }
    
    let eq = WriterT.eq(Id.eq(Tuple.eq(Int.order, Int.order)))
    let eqUnit = WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<ForId, Int>>.check(functor: WriterT<ForId, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<WriterTPartial<ForId, Int>>.check(applicative: WriterT<ForId, Int, Int>.applicative(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<WriterTPartial<ForId, Int>>.check(monad: WriterT<ForId, Int, Int>.monad(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ForListK, Int>>.check(
            semigroupK: WriterT<ForListK, Int, Int>.semigroupK(ListK<Int>.semigroupK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListK<Int>.applicative()) },
            eq: WriterT<ForListK, Int, Int>.eq(ListK.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testSemigroupLaws() {
        property("Semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(semigroup: WriterT<ForListK, Int, Int>.semigroupK(ListK<Int>.semigroupK()).algebra(),
                                       a: WriterT.pure(a, Int.sumMonoid, ListK<Int>.applicative()),
                                       b: WriterT.pure(b, Int.sumMonoid, ListK<Int>.applicative()),
                                       c: WriterT.pure(c, Int.sumMonoid, ListK<Int>.applicative()),
                                       eq: WriterT<ForListK, Int, Int>.eq(ListK.eq(Tuple.eq(Int.order, Int.order))))
        }
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ForListK, Int>>.check(
            monoidK: WriterT<ForListK, Int, Int>.monoidK(ListK<Int>.monoidK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListK<Int>.applicative()) },
            eq: WriterT<ForListK, Int, Int>.eq(ListK.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonoidLaws() {
        property("Monoid laws") <- forAll { (a : Int) in
            return MonoidLaws.check(monoid: WriterT<ForListK, Int, Int>.monoidK(ListK<Int>.monoidK()).algebra(),
                                    a: WriterT.pure(a, Int.sumMonoid, ListK<Int>.applicative()),
                                    eq: WriterT<ForListK, Int, Int>.eq(ListK.eq(Tuple.eq(Int.order, Int.order))))
        }
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<ForOption, Int>>.check(
            functorFilter: WriterT<ForOption, Int, Int>.monadFilter(Option<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Option<Int>.applicative()) },
            eq: WriterT<ForOption, Int, Int>.eq(Option.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<ForOption, Int>>.check(
            monadFilter: WriterT<ForOption, Int, Int>.monadFilter(Option<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Option<Int>.applicative()) },
            eq: WriterT<ForOption, Int, Int>.eq(Option.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<ForId, Int>, Int>.check(
            monadWriter: WriterT<ForId, Int, Int>.writer(Id<Int>.monad(), Int.sumMonoid),
            monoid: Int.sumMonoid,
            eq: self.eq,
            eqUnit: WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq()))),
            eqTuple: WriterT.eq(Id.eq(Tuple.eq(Int.order, TupleEq(Int.order, Int.order)))))
    }
}

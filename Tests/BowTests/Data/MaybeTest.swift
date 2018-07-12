import XCTest
import SwiftCheck
@testable import Bow

class UnitEq : Eq {
    typealias A = ()
    
    func eqv(_ a: (), _ b: ()) -> Bool {
        return true
    }
}

class MaybeTest: XCTestCase {
    
    var generator : (Int) -> Maybe<Int> {
        return { a in a % 2 == 0 ? Maybe.pure(a) : Maybe.none() }
    }
    
    let eq = Maybe.eq(Int.order)
    let eqUnit = Maybe.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForMaybe>.check(functor: Maybe<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForMaybe>.check(applicative: Maybe<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForMaybe>.check(monad: Maybe<Int>.monad(), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ForMaybe, Bow.Unit>.check(applicativeError: Maybe<Int>.monadError(), eq: Maybe.eq(Int.order), eqEither: Maybe.eq(Either.eq(UnitEq(), Int.order)), gen: { () } )
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<ForMaybe, Bow.Unit>.check(monadError: Maybe<Int>.monadError(), eq: self.eq, gen: { () })
    }
    
    func testSemigroupLaws() {
        property("Maybe semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<MaybeOf<Int>>.check(
                semigroup: Maybe<Int>.semigroup(Int.sumMonoid),
                a: Maybe.pure(a),
                b: Maybe.pure(b),
                c: Maybe.pure(c),
                eq: self.eq)
        }
    }
    
    func testMonoidLaws() {
        property("Maybe monoid laws") <- forAll { (a : Int) in
            return MonoidLaws<MaybeOf<Int>>.check(
                monoid: Maybe<Int>.monoid(Int.sumMonoid),
                a: Maybe.pure(a),
                eq: self.eq)
        }
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForMaybe>.check(functorFilter: Maybe<Int>.functorFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForMaybe>.check(monadFilter: Maybe<Int>.monadFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Maybe.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForMaybe>.check(foldable: Maybe<Int>.foldable(), generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForMaybe>.check(traverse: Maybe<Int>.traverse(), functor: Maybe<Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testFromToOption() {
        property("fromOption - toOption isomorphism") <- forAll { (x : Int?, y : Int) in
            let maybe = y % 2 == 0 ? Maybe<Int>.none() : Maybe<Int>.some(y)
            return Maybe.fromOption(x).toOption() == x &&
                Maybe.eq(Int.order).eqv(Maybe.fromOption(maybe.toOption()), maybe)
        }
    }
    
    func testDefinedOrEmpty() {
        property("Maybe cannot be simultaneously empty and defined") <- forAll { (x : Int?) in
            let maybe = Maybe.fromOption(x)
            return xor(maybe.isEmpty, maybe.isDefined)
        }
    }
    
    func testGetOrElse() {
        property("getOrElse consistent with orElse") <- forAll { (x : Int?, y : Int) in
            let maybe = Maybe.fromOption(x)
            return Maybe.eq(Int.order).eqv(Maybe<Int>.pure(maybe.getOrElse(y)),
                                           maybe.orElse(Maybe.pure(y)))
        }
    }
    
    func testFilter() {
        property("filter is opposite of filterNot") <- forAll { (x : Int?, predicate : ArrowOf<Int, Bool>) in
            let maybe = Maybe.fromOption(x)
            let eq = Maybe.eq(Int.order)
            let none = Maybe<Int>.none()
            return xor(eq.eqv(maybe.filter(predicate.getArrow), none), eq.eqv(maybe.filterNot(predicate.getArrow), none))
        }
    }
    
    func testExistForAll() {
        property("exists and forall are equivalent") <- forAll { (x : Int?, predicate : ArrowOf<Int, Bool>) in
            let maybe = Maybe.fromOption(x)
            return maybe.exists(predicate.getArrow) == maybe.forall(predicate.getArrow)
        }
    }
}

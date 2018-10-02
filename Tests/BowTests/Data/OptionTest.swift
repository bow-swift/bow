import XCTest
import SwiftCheck
@testable import Bow

class UnitEq : Eq {
    typealias A = ()
    
    func eqv(_ a: (), _ b: ()) -> Bool {
        return true
    }
}

class OptionTest: XCTestCase {
    
    var generator : (Int) -> Option<Int> {
        return { a in a % 2 == 0 ? Option.pure(a) : Option.none() }
    }
    
    let eq = Option.eq(Int.order)
    let eqUnit = Option.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForOption>.check(functor: Option<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForOption>.check(applicative: Option<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForOption>.check(monad: Option<Int>.monad(), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ForOption, Bow.Unit>.check(applicativeError: Option<Int>.monadError(), eq: Option.eq(Int.order), eqEither: Option.eq(Either.eq(UnitEq(), Int.order)), gen: { () } )
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<ForOption, Bow.Unit>.check(monadError: Option<Int>.monadError(), eq: self.eq, gen: { () })
    }
    
    func testSemigroupLaws() {
        property("Option semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<OptionOf<Int>>.check(
                semigroup: Option<Int>.semigroup(Int.sumMonoid),
                a: Option.pure(a),
                b: Option.pure(b),
                c: Option.pure(c),
                eq: self.eq)
        }
    }
    
    func testMonoidLaws() {
        property("Option monoid laws") <- forAll { (a : Int) in
            return MonoidLaws<OptionOf<Int>>.check(
                monoid: Option<Int>.monoid(Int.sumMonoid),
                a: Option.pure(a),
                eq: self.eq)
        }
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForOption>.check(functorFilter: Option<Int>.functorFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForOption>.check(monadFilter: Option<Int>.monadFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Option.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForOption>.check(foldable: Option<Int>.foldable(), generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForOption>.check(traverse: Option<Int>.traverse(), functor: Option<Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testTraverseFilterLaws() {
        TraverseFilterLaws<ForOption>.check(traverseFilter: Option<Int>.traverseFilter(), applicative: Option<Int>.applicative(), eq: Option.eq(self.eq))
    }
    
    func testFromToOption() {
        property("fromOption - toOption isomorphism") <- forAll { (x : Int?, y : Int) in
            let option = y % 2 == 0 ? Option<Int>.none() : Option<Int>.some(y)
            return Option.fromOption(x).toOption() == x &&
                Option.eq(Int.order).eqv(Option.fromOption(option.toOption()), option)
        }
    }
    
    func testDefinedOrEmpty() {
        property("Option cannot be simultaneously empty and defined") <- forAll { (x : Int?) in
            let option = Option.fromOption(x)
            return xor(option.isEmpty, option.isDefined)
        }
    }
    
    func testGetOrElse() {
        property("getOrElse consistent with orElse") <- forAll { (x : Int?, y : Int) in
            let option = Option.fromOption(x)
            return Option.eq(Int.order).eqv(Option<Int>.pure(option.getOrElse(y)),
                                           option.orElse(Option.pure(y)))
        }
    }
    
    func testFilter() {
        property("filter is opposite of filterNot") <- forAll { (x : Int?, predicate : ArrowOf<Int, Bool>) in
            let option = Option.fromOption(x)
            let eq = Option.eq(Int.order)
            let none = Option<Int>.none()
            return xor(eq.eqv(option.filter(predicate.getArrow), none), eq.eqv(option.filterNot(predicate.getArrow), none))
        }
    }
    
    func testExistForAll() {
        property("exists and forall are equivalent") <- forAll { (x : Int?, predicate : ArrowOf<Int, Bool>) in
            let option = Option.fromOption(x)
            return option.exists(predicate.getArrow) == option.forall(predicate.getArrow)
        }
    }
}

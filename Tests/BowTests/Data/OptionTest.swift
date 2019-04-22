import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class OptionTest: XCTestCase {
    
    var generator: (Int) -> Option<Int> {
        return { a in a % 2 == 0 ? Option.some(a) : Option.none() }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForOption>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForOption>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForOption>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForOption>.check()
    }
    
    func testSemigroupLaws() {
        property("Option semigroup laws") <- forAll { (a: Int, b: Int, c: Int) in
            return SemigroupLaws<Option<Int>>.check(
                a: Option.some(a),
                b: Option.some(b),
                c: Option.some(c))
        }
    }
    
    func testMonoidLaws() {
        property("Option monoid laws") <- forAll { (a: Int) in
            return MonoidLaws<Option<Int>>.check(a: Option.some(a))
        }
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForOption>.check(generator: self.generator)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForOption>.check(generator: self.generator)
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForOption>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForOption>.check(generator: self.generator)
    }
    
    func testTraverseFilterLaws() {
        TraverseFilterLaws<ForOption>.check()
    }
    
    func testFromToOption() {
        property("fromOption - toOption isomorphism") <- forAll { (x: Int?, y: Int) in
            let option = y % 2 == 0 ? Option<Int>.none() : Option<Int>.some(y)
            return Option.fromOptional(x).toOptional() == x &&
                Option.fromOptional(option.toOptional()) == option
        }
    }
    
    func testDefinedOrEmpty() {
        property("Option cannot be simultaneously empty and defined") <- forAll { (x: Int?) in
            let option = Option.fromOptional(x)
            return xor(option.isEmpty, option.isDefined)
        }
    }
    
    func testGetOrElse() {
        property("getOrElse consistent with orElse") <- forAll { (x: Int?, y: Int) in
            let option = Option.fromOptional(x)
            return Option<Int>.pure(option.getOrElse(y)) == Option.fix(option).orElse(Option.some(y))
        }
    }
    
    func testFilter() {
        property("filter is opposite of filterNot") <- forAll { (x: Int, predicate: ArrowOf<Int, Bool>) in
            let option = Option.fromOptional(x)
            let none = Option<Int>.none()
            return xor(option.filter(predicate.getArrow) == none, option.filterNot(predicate.getArrow) == none)
        }
    }
    
    func testExistForAll() {
        property("exists and forall are equivalent") <- forAll { (x: Int, predicate: ArrowOf<Int, Bool>) in
            let option = Option.fromOptional(x)
            return option.exists(predicate.getArrow) == option.forall(predicate.getArrow)
        }
    }
}

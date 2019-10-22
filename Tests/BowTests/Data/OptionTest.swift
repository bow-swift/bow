import XCTest
import SwiftCheck
import BowLaws
import Bow

class OptionTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForOption, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForOption>.check()
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
        SemigroupLaws<Option<Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Option<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForOption>.check()
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<ForOption>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForOption>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForOption>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Option<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForOption>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForOption>.check()
    }
    
    func testTraverseFilterLaws() {
        TraverseFilterLaws<ForOption>.check()
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<ForOption>.check()
    }
	
	func testSemigroupalLaws() {
        SemigroupalLaws<ForOption>.check(isEqual: isEqual(_:_:))
	}
    
    func testMonoidalLaws() {
        func isMonoidalEqual<A, B>(_ fa: Kind<ForOption, A>, _ fb: Kind<ForOption, B>) -> Bool {
            fa.isEmpty && fb.isEmpty
        }
        MonoidalLaws<ForOption>.check(isEqual: isMonoidalEqual)
    }
    
    func testFromToOption() {
        property("fromOption - toOption isomorphism") <~ forAll { (x: Int?, option: Option<Int>) in
            return Option.fromOptional(x).toOptional() == x &&
                Option.fromOptional(option.toOptional()) == option
        }
    }
    
    func testDefinedOrEmpty() {
        property("Option cannot be simultaneously empty and defined") <~ forAll { (option: Option<Int>) in
            return xor(option.isEmpty, option.isDefined)
        }
    }
    
    func testGetOrElse() {
        property("getOrElse consistent with orElse") <~ forAll { (option: Option<Int>, y: Int) in
            return Option<Int>.pure(option.getOrElse(y)) == Option.fix(option).orElse(Option.some(y))
        }
    }
    
    func testFilter() {
        property("filter is opposite of filterNot") <~ forAll { (option: Option<Int>, predicate: ArrowOf<Int, Bool>) in
            let none = Option<Int>.none()
            return xor(option.filter(predicate.getArrow) == none, option.filterNot(predicate.getArrow) == none) || option.isEmpty
        }
    }
    
    func testExistForAll() {
        property("exists and forall are equivalent") <~ forAll { (option: Option<Int>, predicate: ArrowOf<Int, Bool>) in
            return option.exists(predicate.getArrow) == option.forall(predicate.getArrow) || option.isEmpty
        }
    }
}

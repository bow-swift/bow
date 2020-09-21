import XCTest
import SwiftCheck
import BowLaws
import Bow

class OptionTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<OptionPartial, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<OptionPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<OptionPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<OptionPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<OptionPartial>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Option<Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Option<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<OptionPartial>.check()
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<OptionPartial>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<OptionPartial>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<OptionPartial>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Option<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<OptionPartial>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<OptionPartial>.check()
    }
    
    func testTraverseFilterLaws() {
        TraverseFilterLaws<OptionPartial>.check()
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<OptionPartial>.check()
    }
	
	func testSemigroupalLaws() {
        SemigroupalLaws<OptionPartial>.check(isEqual: isEqual(_:_:))
	}
    
    func testMonoidalLaws() {
        func isMonoidalEqual<A, B>(_ fa: OptionOf<A>, _ fb: OptionOf<B>) -> Bool {
            fa.isEmpty && fb.isEmpty
        }
        MonoidalLaws<OptionPartial>.check(isEqual: isMonoidalEqual)
    }
    
    func testFromToOption() {
        property("fromOption - toOption isomorphism") <~ forAll { (x: Int?, option: Option<Int>) in
            Option.fromOptional(x).toOptional() == x &&
                Option.fromOptional(option.toOptional()) == option
        }
    }
    
    func testDefinedOrEmpty() {
        property("Option cannot be simultaneously empty and defined") <~ forAll { (option: Option<Int>) in
            xor(option.isEmpty, option.isDefined)
        }
    }
    
    func testGetOrElse() {
        property("getOrElse consistent with orElse") <~ forAll { (option: Option<Int>, y: Int) in
            Option<Int>.pure(option.getOrElse(y)) == option.orElse(Option.some(y))
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
            option.exists(predicate.getArrow) == option.forall(predicate.getArrow) || option.isEmpty
        }
    }
   
   func testExpressibleByNilLiteralDirectNilAssignmentForLet() {
      let none: Option<Int> = nil
      XCTAssertEqual(none, Option<Int>.none())
   }
   
   func testExpressibleByNilLiteralDirectNilAssignmentForVar() {
      var none: Option<String> = nil
      XCTAssertEqual(none, Option<String>.none())
   }
   
   func testExpressibleByNilLiteralDefaultInitializationForEmbeddedOption() {
      // This test is primarily for the type checker
      let noneLet: Option<Option<[Int]>>
      if (constant(true)()) {
         noneLet = Option.some(Option.some([10]))
      } else {
         noneLet = nil
      }
      XCTAssertEqual(noneLet, Option.some(Option.some([10])))
   }
   
   func testExpressibleByNilLiteralEquality() {
      var optionInt: Option<Int> = nil
      XCTAssertEqual(optionInt, nil)
      optionInt = .some(10)
      XCTAssertEqual(optionInt, .some(10))
   }
   
   func testExpressibleByNilLiteralSwitch() {
      let optionInt: Option<Int> = nil
      switch optionInt {
      case Option.some(10): XCTFail("Should not match Option.some(10)")
      case nil: XCTAssert(true)
      default: break
      }
   }
   
   func testExpressibleByNilLiteralInFunctionArguments() {
      func testFn<A, B>(_ a: Option<A>, _ b: Option<B> = nil) -> Option<(A,B)> { Option.zip(a, b)^ }
      let result: Option<(Int, String)> = testFn(nil)
      XCTAssertEqual(result.map { (a,b) in "\(a)\(b)" }, Option<String>.none())
   }
}

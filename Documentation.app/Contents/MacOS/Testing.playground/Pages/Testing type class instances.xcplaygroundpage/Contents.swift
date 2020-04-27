// nef:begin:header
/*
 layout: docs
 title: Testing type class instances
 */
// nef:end
// nef:begin:hidden
import Bow
import BowLaws
import SwiftCheck
// nef:end
/*:
 # Testing type class instances
 
 {:.beginner}
 beginner
 
 Type classes model abstract behavior that is pervasive to a range of multiple types, and enable ad-hoc polymorphism. One important aspect of type classes, besides providing a common API to work with different implementations, is that they must obey a set of algebraic laws. However, Swift does not have a way of enforcing laws on the implementation of instances for our type classes.
 
 In order to do so, we can use property-based testing to encode these algebraic laws as properties, and then generate random inputs to test them.
 
 Bow already provides modules that contain laws for the type classes included in the main modules of the library, together with generators for all data types. A summary of these modules can be found in the following table:
 
 | Module | Description | Swift import |
 | ------ | ----------- | ------------ |
 | Laws | Laws for type classes in the core module | `import BowLaws` |
 | OpticsLaws | Laws for optics | `import BowOpticsLaws` |
 | EffectsLaws | Laws for effects | `import BowEffectsLaws` |
 | Generators | Generators for data types in the core module | `import BowGenerators` |
 | FreeGenerators | Generators for data types in BowFree | `import BowFreeGenerators` |
 | EffectsGenerators | Generators for data types in BowEffects | `import BowEffectsGenerators` |
 | RxGenerators | Generators for data types in BowRx | `import BowRxGenerators` |

 ## Testing type class instances
 
 Consider the following data type:
 */
struct Invoice {
    let lines: [String]
    let total: Double
}
/*:
 We can implement its instance of `Semigroup` and `Monoid` to let us combine multiple invoices into a single one, and provide an empty invoice, respectively:
 */
extension Invoice: Semigroup {
    func combine(_ other: Invoice) -> Invoice {
        Invoice(lines: self.lines + other.lines,
                total: self.total + other.total)
    }
}

extension Invoice: Monoid {
    static func empty() -> Invoice {
        Invoice(lines: [], total: 0)
    }
}
/*:
 Now that we have our instances, we would like to verify the laws for `Semigroup` and `Monoid`. But first, we need to be able to generate invoices (implement `Arbitrary`), and compare them (implement `Equatable`).
 
 The `Equatable` implementation is straightforward:
 */
extension Invoice: Equatable {
    static func ==(lhs: Invoice, rhs: Invoice) -> Bool {
        lhs.lines == rhs.lines &&
        lhs.total == rhs.total
    }
}
/*:
 In order to create an arbitrary generator of `Invoice`, we need to generate each of its parts, and then combine them to create an `Invoice`. We won't go into much detail on this, as it belongs to the SwiftCheck library, but basic types already provide arbitrary generators:
 */
extension Invoice: Arbitrary {
    static var arbitrary: Gen<Invoice> {
        Gen.zip([String].arbitrary, Double.arbitrary)
            .map(Invoice.init)
    }
}
/*:
 With these we can already write our tests to verify the laws:
 */
func testInvoiceSemigroup() {
    SemigroupLaws<Invoice>.check()
}

func testInvoiceMonoid() {
    MonoidLaws<Invoice>.check()
}

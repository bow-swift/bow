import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension Id: Arbitrary where A: Arbitrary {
    public static var arbitrary: Gen<Id<A>> {
        return A.arbitrary.map(Id.init)
    }
}

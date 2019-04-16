import Foundation
import Bow

public extension Id {
    static func toPValue<B>() -> PIso<Id<A>, Id<B>, A, B> {
        return PIso<Id<A>, Id<B>, A, B>(
            get: { x in x.value },
            reverseGet: Id<B>.init)
    }

    static func toValue() -> Iso<Id<A>, A> {
        return toPValue()
    }
}

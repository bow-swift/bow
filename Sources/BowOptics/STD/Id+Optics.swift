import Foundation
import Bow

// MARK: Optics extensions
public extension Id {
    /// Provides a polymorphic Iso between Id and a raw type.
    ///
    /// - Returns: A polymorphic Iso between Id and a raw type.
    static func toPValue<B>() -> PIso<Id<A>, Id<B>, A, B> {
        return PIso<Id<A>, Id<B>, A, B>(
            get: { x in x.value },
            reverseGet: Id<B>.init)
    }

    /// Provides an Iso bewteen Id and its wrapped type.
    static var toValue: Iso<Id<A>, A> {
        return toPValue()
    }
}

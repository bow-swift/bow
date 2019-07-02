import Foundation
import Bow

// MARK: Optics extensions
public extension NonEmptyArray {
    /// Provides a lens between a NonEmptyArray and its head.
    static var headLens: Lens<NonEmptyArray<A>, A> {
        return Lens<NonEmptyArray<A>, A>(
            get: { x in x.head },
            set: { (nea, newHead) in NonEmptyArray(head: newHead, tail: nea.tail) })
    }

    /// Provides a lens between a NonEmptyArray and its tail.
    static var tailLens: Lens<NonEmptyArray<A>, [A]> {
        return Lens<NonEmptyArray<A>, [A]>(
            get: { x in x.tail },
            set: { (nea, newTail) in NonEmptyArray(head: nea.head, tail: newTail) })
    }
}

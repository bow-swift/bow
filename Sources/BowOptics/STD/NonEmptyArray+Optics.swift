import Foundation
import Bow

public extension NonEmptyArray {
    static var headLens: Lens<NonEmptyArray<A>, A> {
        return Lens<NonEmptyArray<A>, A>(
            get: { x in x.head },
            set: { (nea, newHead) in NonEmptyArray(head: newHead, tail: nea.tail) })
    }

    static var tailLens: Lens<NonEmptyArray<A>, [A]> {
        return Lens<NonEmptyArray<A>, [A]>(
            get: { x in x.tail },
            set: { (nea, newTail) in NonEmptyArray(head: nea.head, tail: newTail) })
    }
}

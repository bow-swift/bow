import Foundation
import Bow

public extension NonEmptyArray {
    static func head() -> Lens<NonEmptyArray<A>, A> {
        return Lens<NonEmptyArray<A>, A>(
            get: { x in x.head },
            set: { (nea, newHead) in NonEmptyArray(head: newHead, tail: nea.tail) })
    }

    static func tail() -> Lens<NonEmptyArray<A>, [A]> {
        return Lens<NonEmptyArray<A>, [A]>(
            get: { x in x.tail },
            set: { (nea, newTail) in NonEmptyArray(head: nea.head, tail: newTail) })
    }
}

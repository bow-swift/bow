import Foundation
import Bow

public extension NonEmptyArray {
    public static func head() -> Lens<NonEmptyArray<A>, A> {
        return Lens<NonEmptyArray<A>, A>(
            get: { x in x.head },
            set: { (nel, newHead) in NonEmptyArray(head: newHead, tail: nel.tail) })
    }
    
    public static func tail() -> Lens<NonEmptyArray<A>, [A]> {
        return Lens<NonEmptyArray<A>, [A]>(
            get: { x in x.tail },
            set: { (nel, newTail) in NonEmptyArray(head: nel.head, tail: newTail) })
    }
}

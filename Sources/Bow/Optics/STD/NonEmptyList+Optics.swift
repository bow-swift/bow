import Foundation

public extension NonEmptyList {
    public static func head() -> Lens<NonEmptyList<A>, A> {
        return Lens<NonEmptyList<A>, A>(
            get: { x in x.head },
            set: { (nel, newHead) in NonEmptyList(head: newHead, tail: nel.tail) })
    }
    
    public static func tail() -> Lens<NonEmptyList<A>, [A]> {
        return Lens<NonEmptyList<A>, [A]>(
            get: { x in x.tail },
            set: { (nel, newTail) in NonEmptyList(head: nel.head, tail: newTail) })
    }
}

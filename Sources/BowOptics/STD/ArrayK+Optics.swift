import Foundation
import Bow

// MARK: Optics extensions
public extension ArrayK {
    /// Provides a polymorphic Iso between ArrayK and Option of NonEmptyArray.
    ///
    /// - Returns: A polymorphic Iso between ArrayK and Option of NonEmptyArray.
    static func toPOptionNEA<B>() -> PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyArray<A>>, Option<NonEmptyArray<B>>> {
        return PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyArray<A>>, Option<NonEmptyArray<B>>>(
            get: { nea in nea.isEmpty ?
                Option<NonEmptyArray<A>>.none() :
                Option<NonEmptyArray<A>>.some(NonEmptyArray<A>(head: nea.asArray[0], tail: Array(nea.asArray.dropFirst()))) },
            reverseGet: { option in
                option.fold(ArrayK<B>.empty, { nea in ArrayK<B>(nea.all()) })
        })
    }

    /// Provides an Iso between ArrayK and Option of NonEmptyArray
    static var toOptionNEA: Iso<ArrayK<A>, Option<NonEmptyArray<A>>> {
        return toPOptionNEA()
    }
    
    /// Provides an AffineTraversal to retrieve the first element of an ArrayK
    static var head: AffineTraversal<ArrayK<A>, A> {
        return firstOption
    }
    
    /// Provides an AffineTraversal to retrieve the tail of an ArrayK
    static var tail: AffineTraversal<ArrayK<A>, ArrayK<A>> {
        return tailOption
    }
}

// MARK: Optics extensions
public extension Array {
    /// Provides a polymorphic Iso between Array and ArrayK
    ///
    /// - Returns: A polymorphic Iso between Array and ArrayK
    static func toPArrayK<B>() -> PIso<Array<Element>, Array<B>, ArrayK<Element>, ArrayK<B>> {
        return PIso<Array<Element>, Array<B>, ArrayK<Element>, ArrayK<B>>(
            get: ArrayK<Element>.init,
            reverseGet: { arrayK in arrayK.asArray })
    }

    /// Provides an Iso between Array and ArrayK
    static var toArrayK: Iso<Array<Element>, ArrayK<Element>> {
        return toPArrayK()
    }
    
    /// Provides an AffineTraversal to retrieve the first element of an Array
    static var head: AffineTraversal<Array<Element>, Element> {
        return firstOption
    }
    
    /// Provides an AffineTraversal to retrieve the tail of an Array.
    static var tail: AffineTraversal<Array<Element>, Array<Element>> {
        return tailOption
    }
}

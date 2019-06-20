import Foundation
import Bow

public extension ArrayK {
    static func toPOptionNEA<B>() -> PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyArray<A>>, Option<NonEmptyArray<B>>> {
        return PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyArray<A>>, Option<NonEmptyArray<B>>>(
            get: { nea in nea.isEmpty ?
                Option<NonEmptyArray<A>>.none() :
                Option<NonEmptyArray<A>>.some(NonEmptyArray<A>(head: nea.asArray[0], tail: Array(nea.asArray.dropFirst()))) },
            reverseGet: { option in
                option.fold(ArrayK<B>.empty, { nea in ArrayK<B>(nea.all()) })
        })
    }

    static var toOptionNEA: Iso<ArrayK<A>, Option<NonEmptyArray<A>>> {
        return toPOptionNEA()
    }
}

public extension Array {
    static func toPArrayK<B>() -> PIso<Array<Element>, Array<B>, ArrayK<Element>, ArrayK<B>> {
        return PIso<Array<Element>, Array<B>, ArrayK<Element>, ArrayK<B>>(
            get: ArrayK<Element>.init,
            reverseGet: { arrayK in arrayK.asArray })
    }

    static var toArrayK: Iso<Array<Element>, ArrayK<Element>> {
        return toPArrayK()
    }
    
    static var head: Optional<Array<Element>, Element> {
        return firstOption
    }
    
    static var tail: Optional<Array<Element>, Array<Element>> {
        return tailOption
    }
}

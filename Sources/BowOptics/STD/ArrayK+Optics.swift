import Foundation
import Bow

public extension ArrayK {
    public static func toPOptionNEA<B>() -> PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyArray<A>>, Option<NonEmptyArray<B>>> {
        return PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyArray<A>>, Option<NonEmptyArray<B>>>(
            get: { list in list.isEmpty ?
                Option<NonEmptyArray<A>>.none() :
                Option<NonEmptyArray<A>>.some(NonEmptyArray<A>(head: list.asArray[0], tail: Array(list.asArray.dropFirst()))) },
            reverseGet: { option in
                option.fold(ArrayK<B>.empty, { nel in ArrayK<B>(nel.all()) })
        })
    }
    
    public static func toOptionNEA() -> Iso<ArrayK<A>, Option<NonEmptyArray<A>>> {
        return toPOptionNEA()
    }
}

public extension Array {
    public static func toPArrayK<B>() -> PIso<Array<Element>, Array<B>, ArrayK<Element>, ArrayK<B>> {
        return PIso<Array<Element>, Array<B>, ArrayK<Element>, ArrayK<B>>(
            get: ArrayK<Element>.init,
            reverseGet: { list in list.asArray })
    }
    
    public static func toArrayK() -> Iso<Array<Element>, ArrayK<Element>> {
        return toPArrayK()
    }
}

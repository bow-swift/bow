import Foundation
import Bow

public extension ArrayK {
    public static func toPOptionNel<B>() -> PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyList<A>>, Option<NonEmptyList<B>>> {
        return PIso<ArrayK<A>, ArrayK<B>, Option<NonEmptyList<A>>, Option<NonEmptyList<B>>>(
            get: { list in list.isEmpty ?
                Option<NonEmptyList<A>>.none() :
                Option<NonEmptyList<A>>.some(NonEmptyList<A>(head: list.asArray[0], tail: Array(list.asArray.dropFirst()))) },
            reverseGet: { option in
                option.fold(ArrayK<B>.empty, { nel in ArrayK<B>(nel.all()) })
        })
    }
    
    public static func toOptionNel() -> Iso<ArrayK<A>, Option<NonEmptyList<A>>> {
        return toPOptionNel()
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

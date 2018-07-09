import Foundation

public extension ListK {
    public static func toPMaybeNel<B>() -> PIso<ListK<A>, ListK<B>, Maybe<NonEmptyList<A>>, Maybe<NonEmptyList<B>>> {
        return PIso<ListK<A>, ListK<B>, Maybe<NonEmptyList<A>>, Maybe<NonEmptyList<B>>>(
            get: { list in list.isEmpty ?
                Maybe<NonEmptyList<A>>.none() :
                Maybe<NonEmptyList<A>>.some(NonEmptyList<A>(head: list.asArray[0], tail: Array(list.asArray.dropFirst()))) },
            reverseGet: { maybe in
                maybe.fold(ListK<B>.empty, { nel in ListK<B>(nel.all()) })
        })
    }
    
    public static func toMaybeNel() -> Iso<ListK<A>, Maybe<NonEmptyList<A>>> {
        return toPMaybeNel()
    }
}

public extension Array {
    public static func toPListK<B>() -> PIso<Array<Element>, Array<B>, ListK<Element>, ListK<B>> {
        return PIso<Array<Element>, Array<B>, ListK<Element>, ListK<B>>(
            get: ListK<Element>.init,
            reverseGet: { list in list.asArray })
    }
    
    public static func toListK() -> Iso<Array<Element>, ListK<Element>> {
        return toPListK()
    }
}

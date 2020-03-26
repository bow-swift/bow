import Bow
import SwiftCheck

// MARK: Generator for Property-based Testing

extension DictionaryK: Arbitrary where A: Arbitrary, K: Arbitrary {
    public static var arbitrary: Gen<DictionaryK<K, A>> {
        Dictionary.arbitrary.map(DictionaryK.init)
    }
}

// MARK: Instance of ArbitraryK for DictionaryK

extension DictionaryKPartial: ArbitraryK where K: Hashable & Arbitrary {
    public static func generate<A: Arbitrary>() -> DictionaryKOf<K, A> {
        DictionaryK.arbitrary.generate
    }
}

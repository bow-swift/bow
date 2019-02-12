@testable import Bow

class MonadCombineLaws<F: MonadCombine & EquatableK> {
    static func check() {
        AlternativeLaws<F>.check()
        MonadFilterLaws<F>.check(generator: F.pure)
    }
}

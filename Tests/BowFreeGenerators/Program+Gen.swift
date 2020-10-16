import Bow
@testable import BowFree
import BowGenerators
import SwiftCheck

// MARK: Instance of `ArbitraryK` for `Free`

extension ProgramPartial: ArbitraryK where F: ArbitraryK {
    public static func generate<A: Arbitrary>() -> ProgramOf<F, A> {
        Program<F, A>.arbitrary.generate
    }
}

extension Program: Arbitrary where F: ArbitraryK, A: Arbitrary {
    public static var arbitrary: Gen<Program<F, A>> {
        Free<CoyonedaPartial<F>, A>.arbitrary.map(Program.init)
    }
}

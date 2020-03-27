import SwiftCheck

infix operator <~

public func <~(checker: AssertiveQuickCheck, test: @autoclosure @escaping () -> Testable) {
    checker <- test
}

public func <~(checker: AssertiveQuickCheck, test: () -> Testable) {
    checker <- test
}

public func <~(checker: ReportiveQuickCheck, test: () -> Testable) {
    checker <- test
}

public func <~(checker: ReportiveQuickCheck, test: @autoclosure @escaping () -> Testable) {
    checker <~ test
}

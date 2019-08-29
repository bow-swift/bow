import SwiftCheck

infix operator <~

public func <~(checker: AssertiveQuickCheck, test: @autoclosure @escaping () -> Testable) {
    return checker <- test
}

public func <~(checker: AssertiveQuickCheck, test: () -> Testable) {
    return checker <- test
}

public func <~(checker: ReportiveQuickCheck, test: () -> Testable) {
    return checker <- test
}

public func <~(checker: ReportiveQuickCheck, test: @autoclosure @escaping () -> Testable) {
    return checker <~ test
}

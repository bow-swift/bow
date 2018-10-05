import Foundation

public class Validation<E> {
    private let disjunctionSequence : [Either<E, Any>]
    
    public init(_ disjunctionSequence : Either<E, Any>...) {
        self.disjunctionSequence = disjunctionSequence
    }
    
    public var failures : [E] {
        return self.disjunctionSequence.filter { x in x.isLeft }.map{ x in x.swap().get() }
    }
    
    public var hasFailures : Bool {
        return !failures.isEmpty
    }
}

fileprivate func any<L, R>(_ x : Either<L, R>) -> Either<L, Any> {
    return x.map{ a in a as Any }
}

public func validate<L, R, R1, R2>(_ p1 : Either<L, R1>,
                                   _ p2 : Either<L, R2>,
                                   _ ifValid : (R1, R2) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get()))
    }
}

public func validate<L, R, R1, R2, R3>(_ p1 : Either<L, R1>,
                                       _ p2 : Either<L, R2>,
                                       _ p3 : Either<L, R3>,
                                       _ ifValid : (R1, R2, R3) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4>(_ p1 : Either<L, R1>,
                                           _ p2 : Either<L, R2>,
                                           _ p3 : Either<L, R3>,
                                           _ p4 : Either<L, R4>,
                                           _ ifValid : (R1, R2, R3, R4) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5>(_ p1 : Either<L, R1>,
                                               _ p2 : Either<L, R2>,
                                               _ p3 : Either<L, R3>,
                                               _ p4 : Either<L, R4>,
                                               _ p5 : Either<L, R5>,
                                               _ ifValid : (R1, R2, R3, R4, R5) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6>(_ p1 : Either<L, R1>,
                                                   _ p2 : Either<L, R2>,
                                                   _ p3 : Either<L, R3>,
                                                   _ p4 : Either<L, R4>,
                                                   _ p5 : Either<L, R5>,
                                                   _ p6 : Either<L, R6>,
                                                   _ ifValid : (R1, R2, R3, R4, R5, R6) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7>(_ p1 : Either<L, R1>,
                                                       _ p2 : Either<L, R2>,
                                                       _ p3 : Either<L, R3>,
                                                       _ p4 : Either<L, R4>,
                                                       _ p5 : Either<L, R5>,
                                                       _ p6 : Either<L, R6>,
                                                       _ p7 : Either<L, R7>,
                                                       _ ifValid : (R1, R2, R3, R4, R5, R6, R7) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8>(_ p1 : Either<L, R1>,
                                                           _ p2 : Either<L, R2>,
                                                           _ p3 : Either<L, R3>,
                                                           _ p4 : Either<L, R4>,
                                                           _ p5 : Either<L, R5>,
                                                           _ p6 : Either<L, R6>,
                                                           _ p7 : Either<L, R7>,
                                                           _ p8 : Either<L, R8>,
                                                           _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9>(_ p1 : Either<L, R1>,
                                                               _ p2 : Either<L, R2>,
                                                               _ p3 : Either<L, R3>,
                                                               _ p4 : Either<L, R4>,
                                                               _ p5 : Either<L, R5>,
                                                               _ p6 : Either<L, R6>,
                                                               _ p7 : Either<L, R7>,
                                                               _ p8 : Either<L, R8>,
                                                               _ p9 : Either<L, R9>,
                                                               _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ p17 : Either<L, R17>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16), any(p17))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get(), p17.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ p17 : Either<L, R17>,
    _ p18 : Either<L, R18>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16), any(p17), any(p18))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get(), p17.get(), p18.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ p17 : Either<L, R17>,
    _ p18 : Either<L, R18>,
    _ p19 : Either<L, R19>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16), any(p17), any(p18), any(p19))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get(), p17.get(), p18.get(), p19.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ p17 : Either<L, R17>,
    _ p18 : Either<L, R18>,
    _ p19 : Either<L, R19>,
    _ p20 : Either<L, R20>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16), any(p17), any(p18), any(p19), any(p20))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get(), p17.get(), p18.get(), p19.get(), p20.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ p17 : Either<L, R17>,
    _ p18 : Either<L, R18>,
    _ p19 : Either<L, R19>,
    _ p20 : Either<L, R20>,
    _ p21 : Either<L, R21>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16), any(p17), any(p18), any(p19), any(p20), any(p21))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get(), p17.get(), p18.get(), p19.get(), p20.get(), p21.get()))
    }
}

public func validate<L, R, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22>(
    _ p1 : Either<L, R1>,
    _ p2 : Either<L, R2>,
    _ p3 : Either<L, R3>,
    _ p4 : Either<L, R4>,
    _ p5 : Either<L, R5>,
    _ p6 : Either<L, R6>,
    _ p7 : Either<L, R7>,
    _ p8 : Either<L, R8>,
    _ p9 : Either<L, R9>,
    _ p10 : Either<L, R10>,
    _ p11 : Either<L, R11>,
    _ p12 : Either<L, R12>,
    _ p13 : Either<L, R13>,
    _ p14 : Either<L, R14>,
    _ p15 : Either<L, R15>,
    _ p16 : Either<L, R16>,
    _ p17 : Either<L, R17>,
    _ p18 : Either<L, R18>,
    _ p19 : Either<L, R19>,
    _ p20 : Either<L, R20>,
    _ p21 : Either<L, R21>,
    _ p22 : Either<L, R22>,
    _ ifValid : (R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22) -> R) -> Either<[L], R> {
    let validation = Validation(any(p1), any(p2), any(p3), any(p4), any(p5), any(p6), any(p7), any(p8), any(p9), any(p10), any(p11), any(p12), any(p13), any(p14), any(p15), any(p16), any(p17), any(p18), any(p19), any(p20), any(p21), any(p22))
    if (validation.hasFailures) {
        return Either.left(validation.failures)
    } else {
        return Either.right(ifValid(p1.get(), p2.get(), p3.get(), p4.get(), p5.get(), p6.get(), p7.get(), p8.get(), p9.get(), p10.get(), p11.get(), p12.get(), p13.get(), p14.get(), p15.get(), p16.get(), p17.get(), p18.get(), p19.get(), p20.get(), p21.get(), p22.get()))
    }
}

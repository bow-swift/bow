import Foundation
import Bow

func isEqual<F: EquatableK & Functor>(_ fa: Kind<F, ()>, _ fb: Kind<F, ()>) -> Bool {
    return fa.map { 0 } == fb.map { 0 }
}

func isEqual<F: EquatableK & Functor, A: Equatable, B: Equatable>(_ fa: Kind<F, (A, B)>, _ fb: Kind<F, (A, B)>) -> Bool {
    return fa.map { x in x.0 } == fb.map { y in y.0 } &&
        fa.map { x in x.1 } == fb.map { y in y.1 }
}

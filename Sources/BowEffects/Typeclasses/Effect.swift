import Foundation
import Bow

public protocol Effect: Async {
    static func runAsync<A>(_ fa: Kind<Self, A>, _ callback: @escaping (Either<E, A>) -> Kind<Self, ()>) -> Kind<Self, ()>
}

// MARK: Syntax for Effect
public extension Kind where F: Effect {
    func runAsync(_ callback: @escaping (Either<F.E, A>) -> Kind<F, ()>) -> Kind<F, ()> {
        return F.runAsync(self, callback)
    }
}

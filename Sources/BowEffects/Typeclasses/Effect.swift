import Foundation
import Bow

public protocol Effect : Async {
    func runAsync<A>(_ fa : Kind<F, A>, _ callback : @escaping (Either<Error, A>) -> Kind<F, ()>) -> Kind<F, ()>
}

import Foundation

public protocol Effect : Async {
    func runAsync<A>(_ fa : Kind<F, A>, _ callback : @escaping (Either<Error, A>) -> Kind<F, Unit>) -> Kind<F, Unit>
}

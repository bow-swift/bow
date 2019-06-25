import Bow

public protocol UnsafeRun: MonadError {
    static func runBlocking<A>(_ fa: @escaping () -> Kind<Self, A>) -> A
    static func runNonBlocking<A>(_ fa: @escaping () -> Kind<Self, A>, _ callback: Callback<E, A>)
}

// MARK: Syntax for UnsafeRun

public extension Kind where F: UnsafeRun {
    static func runBlocking(_ fa: @escaping () -> Kind<F, A>) -> A {
        return F.runBlocking(fa)
    }

    static func runNonBlocking(_ fa: @escaping () -> Kind<F, A>, _ callback: Callback<F.E, A>) {
        return F.runNonBlocking(fa, callback)
    }
}

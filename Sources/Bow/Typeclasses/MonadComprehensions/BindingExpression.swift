open class BindingExpression<F: Monad> {
    internal let bound: BoundVar<F, Any>
    
    public init(_ bound: BoundVar<F, Any>) {
        self.bound = bound
    }
    
    open func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        fatalError("bind must be implemented in subclasses")
    }
}

class MonadBindingExpression<F: Monad>: BindingExpression<F> {
    internal let fa: () -> Kind<F, Any>
    
    public init(_ bound: BoundVar<F, Any>, _ fa: @escaping () -> Kind<F, Any>) {
        self.fa = fa
        super.init(bound)
    }
    
    override func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        return fa.flatMap{ x in
            bound.bind(x)
            return self.fa()
        }
    }
}

infix operator <- : AssignmentPrecedence
prefix operator |<-

internal func erased<F: Functor, A>(_ value: Kind<F, A>) -> Kind<F, Any> {
    return value.map { x in x as Any }
}

public func <-<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    return MonadBindingExpression(bound.erased, fa >>> erased)
}

public func <-<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> A) -> BindingExpression<F> {
    return MonadBindingExpression(bound.erased, fa >>> F.pure >>> erased)
}

public func <-<F: Monad, A, B>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar2(bounds.0, bounds.1).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar3(bounds.0, bounds.1, bounds.2).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar4(bounds.0, bounds.1, bounds.2, bounds.3).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D, E>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar5(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D, E, G>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar6(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D, E, G, H>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar7(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D, E, G, H, I>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar8(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6, bounds.7).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D, E, G, H, I, J>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>, BoundVar<F, J>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I, J)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar9(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6, bounds.7, bounds.8).erased, fa >>> erased)
}

public func <-<F: Monad, A, B, C, D, E, G, H, I, J, K>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>, BoundVar<F, J>, BoundVar<F, K>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I, J, K)>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar10(bounds.0, bounds.1, bounds.2, bounds.3, bounds.4, bounds.5, bounds.6, bounds.7, bounds.8, bounds.9).erased, fa >>> erased)
}

public prefix func |<-<F: Monad, A>(_ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar(), fa >>> erased)
}

public prefix func |<-<F: Monad, A>(_ fa: @autoclosure @escaping () -> A) -> BindingExpression<F> {
    return MonadBindingExpression(BoundVar(), fa >>> F.pure)
}

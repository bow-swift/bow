internal class ListenBindingExpression<F: MonadWriter>: BindingExpression<F> {
    let f: (F.W) -> Any
    
    init(_ bound: BoundVar<F, Any>, _ f: @escaping (F.W) -> Any) {
        self.f = f
        super.init(bound)
    }
    
    override func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        let r: Kind<F, Any> = fa.map { x in
            bound.bind(x)
            return x
        }
        
        return r.listens(f).map { x in x as Any }
    }
}

/// Holds a function for a `MonadWriter.listens` operation.
public struct ListenHandler<F: MonadWriter, B> {
    let f: (F.W) -> B
    
    init(_ f: @escaping (F.W) -> B) {
        self.f = f
    }
}

/// Utility function for `MonadWriter.tell` in monad comprehensions.
///
/// - Parameter w: Value for `MonadWriter.tell`.
/// - Returns: A binding expression.
public func tellWriter<F: MonadWriter>(_ w: F.W) -> BindingExpression<F> {
    return |<-F.tell(w)
}

/// Utility function for `MonadWriter.listen` in monad comprehensions.
///
/// - Returns: A listen handler.
public func listenWriter<F: MonadWriter>() -> ListenHandler<F, F.W> {
    return ListenHandler(id)
}

/// Utility function for `MonadWriter.listens` in monad comprehensions.
///
/// - Parameter f: Function for `MonadWriter.listens`.
/// - Returns: A listen handler.
public func listensWriter<F: MonadWriter, B>(_ f: @escaping (F.W) -> B) -> ListenHandler<F, B> {
    return ListenHandler(f)
}

internal class CensorBindingExpression<F: MonadWriter>: BindingExpression<F> {
    let f: (F.W) -> F.W
    
    init(_ bound: BoundVar<F, Any>, _ f: @escaping (F.W) -> F.W) {
        self.f = f
        super.init(bound)
    }
    
    public override func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        return fa.map { x in
            bound.bind(x)
            return x
        }.censor(self.f)
    }
}

/// Holds a function for a `MonadWriter.censor` operation.
public struct CensorHandler<F: MonadWriter> {
    let f: (F.W) -> F.W
    
    init(_ f: @escaping (F.W) -> F.W) {
        self.f = f
    }
}

/// Utility function for `MonadWriter.censor` in monad comprehensions.
///
/// - Parameter f: Function for `MonadWriter.censor`.
/// - Returns: A censor handler.
public func censorWriter<F: MonadWriter>(_ f: @escaping (F.W) -> F.W) -> CensorHandler<F> {
    return CensorHandler(f)
}

/// Creates a binding expression for a `MonadWriter.listen` operation in monad comprehensions.
///
/// - Parameters:
///   - bounds: A tuple of bound variables.
///   - handler: A listen handler.
/// - Returns: A binding expression.
public func <-<F: MonadWriter, A, B>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>), _ handler: ListenHandler<F, A>) -> BindingExpression<F> {
    return ListenBindingExpression(BoundVar2(bounds.0, bounds.1).erased, handler.f)
}

/// Creates a binding expression for a `MonadWriter.censor` operation in monad comprehensions.
///
/// - Parameters:
///   - bound: A bound variable.
///   - handler: A censor handler.
/// - Returns: A binding expression.
public func <-<F: MonadWriter, A>(_ bound: BoundVar<F, A>, _ handler: CensorHandler<F>) -> BindingExpression<F> {
    return CensorBindingExpression(bound.erased, handler.f)
}

/// Creates a binding expression for a `MonadWriter.censor` that discards the produced value.
///
/// - Parameter handler: A censor handler.
/// - Returns: A binding expression.
public prefix func |<-<F: MonadWriter>(_ handler: CensorHandler<F>) -> BindingExpression<F> {
    return CensorBindingExpression(BoundVar(), handler.f)
}

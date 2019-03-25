import Foundation

/// Reader is a special case of ReaderT / Kleisli where F is `Id`, so it is equivalent to functions `(D) -> A`.
public typealias Reader<D, A> = ReaderT<ForId, D, A>

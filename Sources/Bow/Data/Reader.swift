import Foundation

/// Reader is a special case of ReaderT / Kleisli where F is `Id`, so it is equivalent to functions `(D) -> A`.
public typealias Reader<D, A> = ReaderT<ForId, D, A>

/// Alias over `ReaderTPartial<ForId, D>`
public typealias ReaderPartial<D> = ReaderTPartial<ForId, D>

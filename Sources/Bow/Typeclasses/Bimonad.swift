import Foundation

/// A Bimonad has the same capabilities as `Monad` and `Comonad`.
public protocol Bimonad: Monad, Comonad {}

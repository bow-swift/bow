import Foundation

/// An Alternative is an `Applicative` with `MonoidK` capabilities.
public protocol Alternative: Applicative, MonoidK {}

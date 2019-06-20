import Bow

public protocol AutoFold: AutoLens {}

public extension AutoFold {
    static func fold<T>(for path: WritableKeyPath<Self, Array<T>>) -> Fold<Self, T> {
        return Self.lens(for: path) + Array<T>.fold
    }
    
    static func fold<T>(for path: WritableKeyPath<Self, ArrayK<T>>) -> Fold<Self, T> {
        return Self.lens(for: path) + ArrayK<T>.fold
    }
    
    static func fold<T, F: Foldable>(for path: WritableKeyPath<Self, Kind<F, T>>) -> Fold<Self, T> {
        return Self.lens(for: path) + Kind<F, T>.foldK
    }
}

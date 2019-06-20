import Bow

public protocol AutoTraversal: AutoLens {}

public extension AutoTraversal {
    static func traversal<T>(for path: WritableKeyPath<Self, Array<T>>) -> Traversal<Self, T> {
        return Self.lens(for: path) + Array<T>.traversal
    }
    
    static func traversal<T>(for path: WritableKeyPath<Self, ArrayK<T>>) -> Traversal<Self, T> {
        return Self.lens(for: path) + ArrayK<T>.traversal
    }
    
    static func traversal<T, F: Traverse>(for path: WritableKeyPath<Self, Kind<F, T>>) -> Traversal<Self, T> {
        return Self.lens(for: path) + Kind<F, T>.traversalK
    }
}

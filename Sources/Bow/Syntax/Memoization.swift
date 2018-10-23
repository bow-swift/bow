import Foundation

public func memoize<A, B>(_ f : @escaping (A) -> B) -> (A) -> B where A : Hashable {
    var cached = Dictionary<A, B>()
    
    return { a in
        if let cachedResult = cached[a] {
            return cachedResult
        }
        let result = f(a)
        cached[a] = result
        return result
    }
}

public func memoize<A, B>(_ f : @escaping ((A) -> B, A) -> B) -> (A) -> B where A : Hashable {
    var cached = Dictionary<A, B>()
    
    func wrap(_ a : A) -> B {
        if let cachedResult = cached[a] {
            return cachedResult
        }
        let result = f(wrap, a)
        cached[a] = result
        return result
    }
    
    return wrap
}

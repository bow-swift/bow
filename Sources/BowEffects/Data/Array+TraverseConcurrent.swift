import Foundation
import Bow

public extension Array {
    /// Maps each element of this array to an effect, evaluates them in parallel and collects the results.
    ///
    /// - Parameters:
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func parTraverse<G: Concurrent, B>(_ f: @escaping (Element) -> Kind<G, B>) -> Kind<G, [B]> {
        self.k().parTraverse(f).map { array in array^.asArray }
    }
    
    /// Evaluate each effect in this array in parallel of values and collects the results.
    ///
    /// - Returns: Results collected under the context of the effects.
    func parSequence<G: Concurrent, A>() -> Kind<G, [A]> where Element == Kind<G, A> {
        self.k().parSequence().map { array in array^.asArray }
    }
    
    /// A parallel traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    func parFlatTraverse<G: Concurrent, B>(_ f: @escaping (Element) -> Kind<G, [B]>) -> Kind<G, [B]> {
        self.k().parFlatTraverse { element in f(element).map { x in x.k() } }
            .map { array in array^.asArray }
    }
}

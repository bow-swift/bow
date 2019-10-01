import Foundation

// MARK: Type class functions for Array

public extension Array {
    /// Eagerly folds this array to a summary value from left to right.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process.
    func foldLeft<B>(_ b: B, _ f: @escaping (B, Element) -> B) -> B {
        self.k().foldLeft(b, f)
    }
    
    /// Lazily folds this array to a summary value from right to left.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process.
    func foldRight<B>(_ b: Eval<B>, _ f: @escaping (Element, Eval<B>) -> Eval<B>) -> Eval<B> {
        self.k().foldRight(b, f)
    }
    
    /// Transforms the elements of this array to a type with a `Monoid` instance and folds them using the empty and combine methods of such `Monoid` instance.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: Summary value resulting from the transformation and folding process.
    func foldMap<B: Monoid>(_ f: @escaping (Element) -> B) -> B {
        self.k().foldMap(f)
    }
    
    /// Performs a monadic left fold from this array to the target monad.
    ///
    /// - Parameters:
    ///   - b: Initial value for the fold.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process in the context of the target monad.
    func foldM<G: Monad, B>(_ b: B, _ f: @escaping (B, Element) -> Kind<G, B>) -> Kind<G, B> {
        self.k().foldM(b, f)
    }
    
    /// Performs a monadic left fold by mapping the values in this array to ones in the target monad context and using the `Monoid` instance to combine them.
    ///
    /// - Parameters:
    ///   - f: Trasnforming function.
    /// - Returns: Summary value resulting from the transformation and folding process in the context of the target monad.
    func foldMapM<G: Monad, B: Monoid>(_ f: @escaping (Element) -> Kind<G, B>) -> Kind<G, B> {
        self.k().foldMapM(f)
    }
    
    /// Combines the elements of this array using their `MonoidK` instance.
    ///
    /// - Parameter fga: Structure to be reduced.
    /// - Returns: A value in the context providing the `MonoidK` instance.
    func reduceK<G: MonoidK, A>() -> Kind<G, A> where Element == Kind<G, A> {
        self.k().reduceK()
    }
    
    /// Maps each element of this array to an effect, evaluates them from left to right and collects the results.
    ///
    /// - Parameters:
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func traverse<G: Applicative, B>(_ f: @escaping (Element) -> Kind<G, B>) -> Kind<G, [B]> {
        self.k().traverse(f).map { array in array^.asArray }
    }
    
    /// Evaluate each effect in this array of values and collects the results.
    ///
    /// - Returns: Results collected under the context of the effects.
    func sequence<G: Applicative, A>() -> Kind<G, [A]> where Element == Kind<G, A> {
        self.k().sequence().map { array in array^.asArray }
    }
    
    /// A traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    func flatTraverse<G: Applicative, B>(_ f: @escaping (Element) -> Kind<G, [B]>) -> Kind<G, [B]> {
        self.k().flatTraverse { element in f(element).map { x in x.k() } }
            .map { array in array^.asArray }
    }
}

public extension Array where Element: Monoid {
    /// Folds this array provided that its element type has an instance of `Monoid`.
    ///
    /// It uses the monoid empty value as initial value and the combination method for the fold.
    ///
    /// - Returns: Summary value resulting from the folding process.
    func combineAll() -> Element {
        self.k().combineAll()
    }
}

// MARK: Instance of `Semigroup` for `Array`

extension Array: Semigroup {
    public func combine(_ other: Array<Element>) -> Array<Element> {
        return self + other
    }
}

// MARK: Instance of `Monoid` for `Array`

extension Array: Monoid {
    public static func empty() -> Array<Element> {
        return []
    }
}

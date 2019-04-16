import Foundation

/// NonEmptyReducible defines a `Reducible` in terms of another type that has an instance of `Foldable` and a method that is able to split a structure of values in a first value and the rest of the values in the structure.
public protocol NonEmptyReducible: Reducible {
    associatedtype G: Foldable

    /// Divides a structure of values into a tuple that represents the first value of the structure (first component of the tuple) and the rest of values of the structure (second component of the tuple)
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: Tuple containing the first and rest of values in the structure.
    static func split<A>(_ fa: Kind<Self, A>) -> (A, Kind<G, A>)
}

public extension NonEmptyReducible {
    // Docs inherited from `Foldable`
    static func foldLeft<A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let (a, ga) = split(fa)
        return G.foldLeft(ga, f(b, a), f)
    }

    // Docs inherited from `Foldable`
    static func foldRight<A, B>(_ fa: Kind<Self, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.fix(Eval<(A, Kind<G, A>)>.always({ self.split(fa) }).flatMap { (a, ga) in f(a, G.foldRight(ga, b, f)) })
    }

    // Docs inherited from `Reducible`
    static func reduceLeftTo<A, B>(_ fa: Kind<Self, A>, _ f: (A) -> B, _ g: @escaping (B, A) -> B) -> B {
        let (a, ga) = split(fa)
        return G.foldLeft(ga, f(a), { b, a in g(b, a) })
    }

    // Docs inherited from `Reducible`
    static func reduceRightTo<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.fix(Eval.always({ split(fa) }).flatMap { input -> Eval<B> in
            let (a, ga) = input
            let evalOpt = G.reduceRightToOption(ga, f, g)
            let res = evalOpt.flatMap { option in
                option.fold({ Eval.later({ f(a) })},
                            { b in g(a, Eval.now(b)) })
            }
            return Eval.fix(res)
        })
    }

    /// Folds a structure of values provided that its type has an instance of `Monoid`.
    ///
    /// It uses the monoid empty value as initial value and the combination method for the fold.
    ///
    /// - Parameter fa: Value to be folded.
    /// - Returns: Summary value resulting from the folding process.
    static func fold<A: Monoid>(_ fa: Kind<Self, A>) -> A {
        let (a, ga) = split(fa)
        return a.combine(G.fold(ga))
    }

    /// Looks for an element that matches a given predicate.
    ///
    /// - Parameters:
    ///   - fa: Structure of values where the element matching the predicate needs to be found.
    ///   - f: Predicate.
    /// - Returns: A value if there is any that matches the predicate, or `Option.none`.
    static func find<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Option<A> {
        let (a, ga) = split(fa)
        return f(a) ? Option.some(a) : G.find(ga, f)
    }

    /// Checks if any element in a structure matches a given predicate.
    ///
    /// - Parameters:
    ///   - fa: Structure of values where the element matching the predicate needs to be found.
    ///   - predicate: Predicate.
    /// - Returns: A boolean value indicating if any elements in the structure match the predicate.
    static func exists<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        let (a, ga) = split(fa)
        return predicate(a) || G.exists(ga, predicate)
    }

    /// Checks if all elements in a structure match a given predicate.
    ///
    /// - Parameters:
    ///   - fa: Structure of values where all elements should match the predicate.
    ///   - predicate: Predicate.
    /// - Returns: A boolean value indicating if all elements in the structure match the predicate.
    static func forall<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        let (a, ga) = split(fa)
        return predicate(a) && G.forall(ga, predicate)
    }

    /// Counts how many elements a structure contains.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: An integer value with the count of how many elements are contained in the structure.
    static func count<A>(_ fa: Kind<Self, A>) -> Int64 {
        let (_, tail) = split(fa)
        return 1 + G.count(tail)
    }

    /// Obtains a specific element of a structure of elements given its indexed position.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - index: Indexed position of the element to retrieve.
    /// - Returns: A value if there is any at the given position, or `Option.none` otherwise.
    static func get<A>(_ fa: Kind<Self, A>, _ index: Int64) -> Option<A> {
        if index == 0 {
            return Option.some(split(fa).0)
        } else {
            return G.get(split(fa).1, index - 1)
        }
    }

    /// Performs a monadic left fold from the source context to the target monad.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - b: Initial value for the fold.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process in the context of the target monad.
    static func foldM<H: Monad, A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> Kind<H, B>) -> Kind<H, B> {
        let (a, ga) = split(fa)
        return H.flatMap(f(b, a), { bb in G.foldM(ga, bb, f)})
    }
}

// MARK Syntax for NonEmptyReducible {

public extension Kind where F: NonEmptyReducible {
    /// Divides this structure of values into a tuple that represents the first value of the structure (first component of the tuple) and the rest of values of the structure (second component of the tuple)
    ///
    /// - Returns: Tuple containing the first and rest of values in the structure.
    func split() -> (A, Kind<F.G, A>) {
        return F.split(self)
    }
}

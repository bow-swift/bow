import Foundation

/// Foldable describes types that have the ability to be folded to a summary value.
public protocol Foldable {
    /// Eagerly folds a value to a summary value from left to right.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process.
    static func foldLeft<A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B

    /// Lazily folds a value to a summary value from right to left.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process.
    static func foldRight<A, B>(_ fa: Kind<Self, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B>
}

public extension Foldable {
    /// Folds a structure of values provided that its type has an instance of `Monoid`.
    ///
    /// It uses the monoid empty value as initial value and the combination method for the fold.
    ///
    /// - Parameter fa: Value to be folded.
    /// - Returns: Summary value resulting from the folding process.
    static func fold<A: Monoid>(_ fa : Kind<Self, A>) -> A {
        return foldLeft(fa, A.empty(), { acc, a in acc.combine(a) })
    }

    /// Reduces the elements of a structure down to a single value by applying the provided transformation and aggregation funtions in a left-associative manner.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Optional summary value resulting from the folding process. It will be an `Option.none` if the structure is empty, or a value if not.
    static func reduceLeftToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Option<B> {
        return Option.fix(foldLeft(fa, Option.empty, { option, a in
            Option.fix(option).fold(constant(Option.some(f(a))),
                                    { b in Option.some(g(b, a)) })
        }))
    }

    /// Reduces the elements of a structure down to a single value by applying the provided transformation and aggregation functions in a right-associative manner.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Optional summary value resulting from the folding process. It will be an `Option.none` if the structure is empty, or a value if not.
    static func reduceRightToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Option<B>> {
        return Eval.fix(foldRight(fa, Eval.now(Option.empty), { a, lb in
            Eval.fix(Eval.fix(lb).flatMap({ option in
                Option.fix(option).fold({ Eval.later({ Option.some(f(a)) }) },
                                        { b in Eval.fix(g(a, Eval.now(b)).map(Option.some)) })
            }))
        }).map { x in Option.fix(x) })
    }

    /// Reduces the elements of a structure down to a single value by applying the provided aggregation function in a left-associative manner.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - f: Folding function.
    /// - Returns: Optional summary value resulting from the folding process.
    static func reduceLeftOption<A>(_ fa: Kind<Self, A>, _ f: @escaping (A, A) -> A) -> Option<A> {
        return reduceLeftToOption(fa, id, f)
    }

    /// Reduces the elements of a structure down to a single value by applying the provided aggregation function in a right-associative manner.
    ///
    /// - Parameters:
    ///   - fa: Value to be folded.
    ///   - f: Folding function.
    /// - Returns: Optional summary value resulting from the folding process.
    static func reduceRightOption<A>(_ fa: Kind<Self, A>, _ f: @escaping (A, Eval<A>) -> Eval<A>) -> Eval<Option<A>> {
        return reduceRightToOption(fa, id, f)
    }

    /// Folds a structure of values provided that its type has an instance of `Monoid`.
    ///
    /// It uses the monoid empty value as initial value and the combination method for the fold.
    ///
    /// - Parameter fa: Value to be folded.
    /// - Returns: Summary value resulting from the folding process.
    static func combineAll<A: Monoid>(_ fa: Kind<Self, A>) -> A {
        return fold(fa)
    }

    /// Transforms the elements of a structure to a type with a `Monoid` instance and folds them using the empty and combine methods of such `Monoid` instance.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed and folded.
    ///   - f: Transforming function.
    /// - Returns: Summary value resulting from the transformation and folding process.
    static func foldMap<A, B: Monoid>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B) -> B {
        return foldLeft(fa, B.empty(), { b, a in b.combine(f(a)) })
    }

    /// Traverses a structure of values, transforming them with a provided function and discarding the result of its effect.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Transforming function.
    /// - Returns: Unit in the context of the effect of the result of the transforming function.
    static func traverse_<G: Applicative, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Unit> {
        return foldRight(fa, Eval.always({ G.pure(unit) }), { a, acc in
            G.map2Eval(f(a), acc, { _, _ in unit })
        }).value()
    }

    /// Traverses a structure of effects, performing them and discarding their result.
    ///
    /// - Parameter fga: Structure of effects.
    /// - Returns: Unit in the context of the effects contained in the structure.
    static func sequence_<G: Applicative, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<G, Unit> {
        return traverse_(fga, id)
    }

    /// Looks for an element that matches a given predicate.
    ///
    /// - Parameters:
    ///   - fa: Structure of values where the element matching the predicate needs to be found.
    ///   - f: Predicate.
    /// - Returns: A value if there is any that matches the predicate, or `Option.none`.
    static func find<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Option<A> {
        return foldRight(fa, Eval.now(Option.none()), { a, lb in
            f(a) ? Eval.now(Option.some(a)) : lb
        }).value()
    }

    /// Checks if any element in a structure matches a given predicate.
    ///
    /// - Parameters:
    ///   - fa: Structure of values where the element matching the predicate needs to be found.
    ///   - predicate: Predicate.
    /// - Returns: A boolean value indicating if any elements in the structure match the predicate.
    static func exists<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldRight(fa, Eval.false, { a, lb in
            predicate(a) ? Eval.true : lb
        }).value()
    }

    /// Checks if all elements in a structure match a given predicate.
    ///
    /// - Parameters:
    ///   - fa: Structure of values where all elements should match the predicate.
    ///   - predicate: Predicate.
    /// - Returns: A boolean value indicating if all elements in the structure match the predicate.
    static func forall<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldRight(fa, Eval.true, { a, lb in
            predicate(a) ? lb : Eval.false
        }).value()
    }

    /// Checks if a structure of values is empty.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: `false` if the structure contains any value, `true` otherwise.
    static func isEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return foldRight(fa, Eval.true, { _, _ in Eval.false }).value()
    }

    /// Checks if a structure of values is not empty.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: `true` if the structure contains any value, `false` otherwise.
    static func nonEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return !isEmpty(fa)
    }

    /// Performs a monadic left fold from the source context to the target monad.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - b: Initial value for the fold.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process in the context of the target monad.
    static func foldM<G: Monad, A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> Kind<G, B>) -> Kind<G, B> {
        return foldLeft(fa, G.pure(b), { gb, a in G.flatMap(gb, { b in f(b, a) }) })
    }

    /// Performs a monadic left fold by mapping the values in a structure to ones in the target monad context and using the `Monoid` instance to combine them.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - f: Trasnforming function.
    /// - Returns: Summary value resulting from the transformation and folding process in the context of the target monad.
    static func foldMapM<G: Monad, A, B: Monoid>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, B> {
        return foldM(fa, B.empty(), { b, a in G.map(f(a), { bb in b.combine(bb) }) })
    }

    /// Obtains a specific element of a structure of elements given its indexed position.
    ///
    /// - Parameters:
    ///   - fa: Structure of values.
    ///   - index: Indexed position of the element to retrieve.
    /// - Returns: A value if there is any at the given position, or `Option.none` otherwise.
    static func get<A>(_ fa: Kind<Self, A>, _ index: Int64) -> Option<A> {
        return Either.fix(foldM(fa, Int64(0), { i, a in
            (i == index) ?
                Either<A, Int64>.left(a) :
                Either<A, Int64>.right(i + 1)
        })).fold(Option<A>.some,
                 constant(Option<A>.none()))
    }

    /// Counts how many elements a structure contains.
    ///
    /// - Parameter fa: Structure of values.
    /// - Returns: An integer value with the count of how many elements are contained in the structure.
    static func count<A>(_ fa: Kind<Self, A>) -> Int64 {
        return foldMap(fa, constant(1))
    }
    
    /// Combines the elements of an structure using their `MonoidK` instance.
    /// 
    /// - Parameter fga: Structure to be reduced.
    /// - Returns: A value in the context providing the `MonoidK` instance.
    static func foldK<A, G: MonoidK>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<G, A> {
        return reduceK(fga)
    }
    
    /// Combines the elements of an structure using their `MonoidK` instance.
    ///
    /// - Parameter fga: Structure to be reduced.
    /// - Returns: A value in the context providing the `MonoidK` instance.
    static func reduceK<A, G: MonoidK>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<G, A> {
        return foldLeft(fga, Kind<G, A>.emptyK(), { b, a in b.combineK(a) })
    }
}

// MARK: Syntax for Foldable

public extension Kind where F: Foldable {
    /// Eagerly folds this value to a summary value from left to right.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process.
    func foldLeft<B>(_ b: B, _ f: @escaping (B, A) -> B) -> B {
        return F.foldLeft(self, b, f)
    }

    /// Lazily folds this value to a summary value from right to left.
    ///
    /// - Parameters:
    ///   - b: Initial value for the folding process.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process.
    func foldRight<B>(_ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return F.foldRight(self, b, f)
    }

    /// Reduces the elements of this structure down to a single value by applying the provided transformation and aggregation funtions in a left-associative manner.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Optional summary value resulting from the folding process. It will be an `Option.none` if the structure is empty, or a value if not.
    func reduceLeftToOption<B>(_ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Option<B> {
        return F.reduceLeftToOption(self, f, g)
    }

    /// Reduces the elements of this structure down to a single value by applying the provided transformation and aggregation functions in a right-associative manner.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    ///   - g: Folding function.
    /// - Returns: Optional summary value resulting from the folding process. It will be an `Option.none` if the structure is empty, or a value if not.
    func reduceRightToOption<B>(_ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Option<B>> {
        return F.reduceRightToOption(self, f, g)
    }

    /// Reduces the elements of this structure down to a single value by applying the provided aggregation function in a left-associative manner.
    ///
    /// - Parameters:
    ///   - f: Folding function.
    /// - Returns: Optional summary value resulting from the folding process.
    func reduceLeftOption(_ f: @escaping (A, A) -> A) -> Option<A> {
        return F.reduceLeftOption(self, f)
    }

    /// Reduces the elements of this structure down to a single value by applying the provided aggregation function in a right-associative manner.
    ///
    /// - Parameters:
    ///   - f: Folding function.
    /// - Returns: Optional summary value resulting from the folding process.
    func reduceRightOption(_ f: @escaping (A, Eval<A>) -> Eval<A>) -> Eval<Option<A>> {
        return F.reduceRightOption(self, f)
    }
    
    /// Transforms the elements of this structure to a type with a `Monoid` instance and folds them using the empty and combine methods of such `Monoid` instance.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed and folded.
    ///   - f: Transforming function.
    /// - Returns: Summary value resulting from the transformation and folding process.
    func foldMap<B: Monoid>(_ f: @escaping (A) -> B) -> B {
        return F.foldMap(self, f)
    }

    /// Traverses this structure of values, transforming them with a provided function and discarding the result of its effect.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: Unit in the context of the effect of the result of the transforming function.
    func traverse_<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Unit> {
        return F.traverse_(self, f)
    }

    /// Traverses this structure of effects, performing them and discarding their result.
    ///
    /// - Returns: Unit in the context of the effects contained in the structure.
    func sequence_<G: Applicative, AA>() -> Kind<G, Unit> where A == Kind<G, AA> {
        return F.sequence_(self)
    }

    /// Looks for an element that matches a given predicate.
    ///
    /// - Parameters:
    ///   - f: Predicate.
    /// - Returns: A value if there is any that matches the predicate, or `Option.none`.
    func find(_ f: @escaping (A) -> Bool) -> Option<A> {
        return F.find(self, f)
    }

    /// Checks if any element in this structure matches a given predicate.
    ///
    /// - Parameters:
    ///   - predicate: Predicate.
    /// - Returns: A boolean value indicating if any elements in the structure match the predicate.
    func exists(_ predicate: @escaping (A) -> Bool) -> Bool {
        return F.exists(self, predicate)
    }

    /// Checks if all elements in this structure match a given predicate.
    ///
    /// - Parameters:
    ///   - predicate: Predicate.
    /// - Returns: A boolean value indicating if all elements in the structure match the predicate.
    func forall(_ predicate: @escaping (A) -> Bool) -> Bool {
        return F.forall(self, predicate)
    }

    /// Checks if this structure of values is empty.
    ///
    /// - Returns: `false` if the structure contains any value, `true` otherwise.
    var isEmpty: Bool {
        return F.isEmpty(self)
    }

    /// Checks if this structure of values is not empty.
    ///
    /// - Returns: `true` if the structure contains any value, `false` otherwise.
    var nonEmpty: Bool {
        return F.nonEmpty(self)
    }

    /// Performs a monadic left fold from the source context to the target monad.
    ///
    /// - Parameters:
    ///   - b: Initial value for the fold.
    ///   - f: Folding function.
    /// - Returns: Summary value resulting from the folding process in the context of the target monad.
    func foldM<G: Monad, B>(_ b: B, _ f: @escaping (B, A) -> Kind<G, B>) -> Kind<G, B> {
        return F.foldM(self, b, f)
    }

    /// Performs a monadic left fold by mapping the values in this structure to ones in the target monad context and using the `Monoid` instance to combine them.
    ///
    /// - Parameters:
    ///   - f: Trasnforming function.
    /// - Returns: Summary value resulting from the transformation and folding process in the context of the target monad.
    func foldMapM<G: Monad, B: Monoid>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, B> {
        return F.foldMapM(self, f)
    }

    /// Obtains a specific element of a structure of elements given its indexed position.
    ///
    /// - Parameters:
    ///   - index: Indexed position of the element to retrieve.
    /// - Returns: A value if there is any at the given position, or `Option.none` otherwise.
    func get(_ index: Int64) -> Option<A> {
        return F.get(self, index)
    }

    /// Counts how many elements this structure contains.
    ///
    /// - Returns: An integer value with the count of how many elements are contained in the structure.
    var count: Int64 {
        return F.count(self)
    }
    
    func foldK<G: MonoidK, B>() -> Kind<G, B> where A == Kind<G, B> {
        return F.foldK(self)
    }
    
    func reduceK<G: MonoidK, B>() -> Kind<G, B> where A == Kind<G, B> {
        return F.reduceK(self)
    }
}

public extension Kind where F: Foldable, A: Monoid {
    /// Folds this structure of values provided that its type has an instance of `Monoid`.
    ///
    /// It uses the monoid empty value as initial value and the combination method for the fold.
    ///
    /// - Returns: Summary value resulting from the folding process.
    func fold() -> A {
        return F.fold(self)
    }

    /// Folds this structure of values provided that its type has an instance of `Monoid`.
    ///
    /// It uses the monoid empty value as initial value and the combination method for the fold.
    ///
    /// - Returns: Summary value resulting from the folding process.
    func combineAll() -> A {
        return F.combineAll(self)
    }
}

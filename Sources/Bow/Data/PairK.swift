import Foundation

/// Witness for the `PairK<F, G, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForPairK {}

/// Partial application of the `PairK` type constructor, omitting the last parameter.
public final class PairKPartial<F, G>: Kind2<ForPairK, F, G> {}

/// Higher Kinded Type alias to improve readability over `Kind<PairKPartial<F, G>, A>`.
public typealias PairKOf<F, G, A> = Kind<PairKPartial<F, G>, A>

/// `PairK` is a product type for kinds. Represents a type where you hold both a `Kind<F, A>` and a `Kind<G, A>`.
public final class PairK<F, G, A>: PairKOf<F, G, A> {
    fileprivate let run: Pair<Kind<F, A>, Kind<G, A>>

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to `PairK`.
    public static func fix(_ fa: PairKOf<F, G, A>) -> PairK<F, G, A> {
        fa as! PairK<F, G, A>
    }

    /// Initialises a `PairK` from two values.
    ///
    /// - Parameters:
    ///   - fa: Value of the first component of the pair.
    ///   - ga: Value of the second component of the pair.
    public init(_ fa: Kind<F, A>, _ ga: Kind<G, A>) {
        self.run = Pair(fa, ga)
    }

    /// Initialises a `PairK` from a `Pair`.
    ///
    /// - Parameter pair: `Pair` value to initialise this `PairK`.
    public init(_ pair: Pair<Kind<F, A>, Kind<G, A>>) {
        self.run = pair
    }

    /// The value of the first component of this pair.
    var first: Kind<F, A> {
        run.first
    }

    /// The value of the second component of this pair.
    var second: Kind<G, A> {
        run.second
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to `PairK`.
public postfix func ^ <F, G, A>(_ fa: PairKOf<F, G, A>) -> PairK<F, G, A> {
    PairK.fix(fa)
}

extension PairK where F: Applicative, G: Applicative {
    /// Initialises a `PairK` from the provided values lifting them to `F` and `G`.
    ///
    /// - Parameters:
    ///   - a1: Value of the first component of the pair.
    ///   - a2: Value of the second component of the pair.
    public convenience init(_ a1: A, _ a2: A) {
        self.init(F.pure(a1), G.pure(a2))
    }
}

// MARK: Instance of EquatableK for PairK.
extension PairKPartial: EquatableK where F: EquatableK, G: EquatableK {
    public static func eq<A>(_ lhs: PairKOf<F, G, A>, _ rhs: PairKOf<F, G, A>) -> Bool where A : Equatable {
        lhs^.first == rhs^.first && lhs^.second == rhs^.second
    }
}

// MARK: Instance of HashableK for PairK.
extension PairKPartial: HashableK where F: HashableK, G: HashableK {
    public static func hash<A>(_ fa: PairKOf<F, G, A>, into hasher: inout Hasher) where A : Hashable {
        hasher.combine(fa^.run)
    }
}

// MARK: Instance of Invariant for PairK.
extension PairKPartial: Invariant where F: Functor, G: Functor {}

// MARK: Instance of Functor for PairK.
extension PairKPartial: Functor where F: Functor, G: Functor {
    public static func map<A, B>(_ fa: PairKOf<F, G, A>, _ f: @escaping (A) -> B) -> PairKOf<F, G, B> {
        PairK(fa^.run.bimap({ F.map($0, f) }, { G.map($0, f) }))
    }
}

// MARK: Instance of Applicative for PairK.
extension PairKPartial: Applicative where F: Applicative, G: Applicative {
    public static func pure<A>(_ a: A) -> PairKOf<F, G, A> {
        PairK(a, a)
    }

    public static func ap<A, B>(_ ff: PairKOf<F, G, (A) -> B>, _ fa: PairKOf<F, G, A>) -> PairKOf<F, G, B> {
        PairK(
            F.ap(ff^.first, fa^.first),
            G.ap(ff^.second, fa^.second)
        )
    }
}

// MARK: Instance of Selective for PairK
extension PairKPartial: Selective where F: Monad, G: Monad {}

// MARK: Instance of Monad for PairK
extension PairKPartial: Monad where F: Monad, G: Monad {
    public static func flatMap<A, B>(_ fa: PairKOf<F, G, A>, _ f: @escaping (A) -> PairKOf<F, G, B>) -> PairKOf<F, G, B> {
        PairK(
            F.flatMap(fa^.first) { f($0)^.first },
            G.flatMap(fa^.second) { f($0)^.second }
        )
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> PairKOf<F, G, Either<A, B>>) -> PairKOf<F, G, B> {
        PairK(
            F.tailRecM(a, { f($0)^.first }),
            G.tailRecM(a, { f($0)^.second })
        )
    }
}

// MARK: Instance of FunctorFilter for PairK
extension PairKPartial: FunctorFilter where F: MonadFilter, G: MonadFilter {}

// MARK: Instance of MonadFilter for PairK
extension PairKPartial: MonadFilter where F: MonadFilter, G: MonadFilter {
    public static func empty<A>() -> PairKOf<F, G, A> {
        PairK(F.empty(), G.empty())
    }
}

// MARK: Instance of SemigroupK for PairK
extension PairKPartial: SemigroupK where F: SemigroupK, G: SemigroupK {
    public static func combineK<A>(
        _ x: PairKOf<F, G, A>,
        _ y: PairKOf<F, G, A>) -> PairKOf<F, G, A> {
        PairK(
            x^.first.combineK(y^.first),
            x^.second.combineK(y^.second)
        )
    }
}

// MARK: Instance of MonoidK for PairK
extension PairKPartial: MonoidK where F: MonoidK, G: MonoidK {
    public static func emptyK<A>() -> PairKOf<F, G, A> {
        PairK(F.emptyK(), G.emptyK())
    }
}

// MARK: Instance of ApplicativeError for PairK
extension PairKPartial: ApplicativeError where F: MonadError, G: MonadError, F.E == G.E {
    public typealias E = F.E

    public static func raiseError<A>(_ e: E) -> PairKOf<F, G, A> {
        PairK(F.raiseError(e), G.raiseError(e))
    }

    public static func handleErrorWith<A>(
        _ fa: PairKOf<F, G, A>,
        _ f: @escaping (E) -> PairKOf<F, G, A>) -> PairKOf<F, G, A> {
        PairK(
            fa^.first.handleErrorWith { f($0)^.first },
            fa^.second.handleErrorWith { f($0)^.second }
        )
    }
}

// MARK: Instance of MonadError for PairK
extension PairKPartial: MonadError where F: MonadError, G: MonadError, F.E == G.E {}

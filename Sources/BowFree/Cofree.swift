import Foundation
import Bow

/// Witness for the Cofree<F, A> data type. To be used in simulated Higher Kinded Types.
public final class ForCofree {}

/// Partial application of the Cofree type constructor, omitting the last parameter.
public final class CofreePartial<F: Functor>: Kind<ForCofree, F> {}

/// Higher Kinded Type alias to improve readability.
public typealias CofreeOf<F: Functor, A> = Kind<CofreePartial<F>, A>

/// Cofree is a type that, given any Functor, is able to provide a Comonad instance, that can be interpreted into a more restrictive one.
public final class Cofree<F: Functor, A>: CofreeOf<F, A> {
    /// First value wrapped in this comonad.
    public let head: A
    
    /// A potentially lazy way of obtaining further values in this comonadic structure.
    public let tail: Eval<Kind<F, Cofree<F, A>>>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Cofree.
    public static func fix(_ fa: CofreeOf<F, A>) -> Cofree<F, A> {
        fa as! Cofree<F, A>
    }
    
    /// Initializes a Cofree value.
    ///
    /// - Parameters:
    ///   - head: Value to be wrapped.
    ///   - tail: A description of the potential values in the comonadic context.
    public init(_ head: A, _ tail: Eval<Kind<F, Cofree<F, A>>>) {
        self.head = head
        self.tail = tail
    }
    
    /// Obtains the values in the context of this Cofree comonad.
    ///
    /// - Returns: The result of evaluating the tail of this Cofree.
    public func tailForced() -> Kind<F, Cofree<F, A>> {
        tail.value()
    }
    
    /// Constructs a Cofree from a seed and an unfolding function.
    ///
    /// - Parameters:
    ///   - a: Seed.
    ///   - f: Unfolding function.
    /// - Returns: A Cofree value resulting from the unfolding process.
    public static func unfold(
        _ a: A,
        _ f: @escaping (A) -> Kind<F, A>
    ) -> Cofree<F, A> {
        create(a, f)
    }

    /// Constructs a Cofree from a seed and an unfolding function.
    ///
    /// - Parameters:
    ///   - a: Seed.
    ///   - f: Unfolding function.
    /// - Returns: A Cofree value resulting from the unfolding process.
    public static func create(
        _ a: A,
        _ f: @escaping (A) -> Kind<F, A>
    ) -> Cofree<F, A> {
        Cofree(a, Eval.later {
            f(a).map { inA in create(inA, f) }
        })
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Cofree.
public postfix func ^<F, A>(_ fa: CofreeOf<F, A>) -> Cofree<F, A> {
    Cofree.fix(fa)
}

public extension Cofree where F: Traverse {
    /// Folds this structure into a single value.
    ///
    /// - Parameter folder: Folding function to collapse this structure.
    /// - Returns: Result from the folding process.
    func cata<B>(_ folder: @escaping (A, Kind<F, B>) -> Eval<B>) -> Eval<B> {
        self.tailForced().traverse { cof in
            cof.cata(folder)
        }.flatMap { sb in
            folder(self.extract(), sb)
        }^
    }
    
    /// Folds this structure into a monadic value.
    ///
    /// - Parameters:
    ///   - folder: Folding function to collaps this structure.
    ///   - inclusion: A natural transformation into the target Monad.
    /// - Returns: A value in the new monadic context.
    func cataM<B, M: Monad>(
        _ folder: @escaping (A, Kind<F, B>) -> Kind<M, B>,
        _ inclusion: FunctionK<ForEval, M>
    ) -> Kind<M, B> {
        func loop(_ ev: Cofree<F, A>) -> Eval<Kind<M, B>> {
            let looped = ev.tailForced().traverse { cof in
                inclusion.invoke(Eval.defer { loop(cof) })
                    .flatten()
            }
            let folded = looped.flatMap { fb in folder(ev.head, fb) }
            return Eval.now(folded)
        }
        return inclusion.invoke(loop(self)).flatten()
    }
}

// MARK: Instance of Invariant for Cofree

extension CofreePartial: Invariant {}

// MARK: Instance of Functor for Cofree

extension CofreePartial: Functor {
    public static func map<A, B>(
        _ fa: CofreeOf<F, A>,
        _ f: @escaping (A) -> B
    ) -> CofreeOf<F, B> {
        Cofree<F, B>(
            f(fa^.head),
            fa^.tail.map { fco in
                fco.map { co in
                    co.map(f)^
                }
            }^)
    }
}

// MARK: Instance of Comonad for Cofree

extension CofreePartial: Comonad {
    public static func coflatMap<A, B>(
        _ fa: CofreeOf<F, A>,
        _ f: @escaping (CofreeOf<F, A>) -> B
    ) -> CofreeOf<F, B> {
        Cofree<F, B>(
            f(fa),
            fa^.tail.map { co in
                co.map { x in x.coflatMap(f)^ }
            }^
        )
    }

    public static func extract<A>(
        _ fa: CofreeOf<F, A>
    ) -> A {
        fa^.head
    }
}

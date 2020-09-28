import Foundation
import Bow

public final class ForCofree {}
public final class CofreePartial<F: Functor>: Kind<ForCofree, F> {}
public typealias CofreeOf<F: Functor, A> = Kind<CofreePartial<F>, A>

public final class Cofree<F: Functor, A>: CofreeOf<F, A> {
    public let head: A
    public let tail: Eval<Kind<F, Cofree<F, A>>>

    public static func fix(_ fa: CofreeOf<F, A>) -> Cofree<F, A> {
        fa as! Cofree<F, A>
    }

    public init(_ head: A, _ tail: Eval<Kind<F, Cofree<F, A>>>) {
        self.head = head
        self.tail = tail
    }

    public func tailForced() -> Kind<F, Cofree<F, A>> {
        tail.value()
    }

    public static func unfold(_ a: A, _ f: @escaping (A) -> Kind<F, A>) -> Cofree<F, A> {
        create(a, f)
    }

    public static func create(_ a: A, _ f: @escaping (A) -> Kind<F, A>) -> Cofree<F, A> {
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
    func cata<B>(_ folder: @escaping (A, Kind<F, B>) -> Eval<B>) -> Eval<B> {
        self.tailForced().traverse { cof in
            cof.cata(folder)
        }.flatMap { sb in
            folder(self.extract(), sb)
        }^
    }

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
                co.map { _ in fa^.coflatMap(f)^ }
            }^
        )
    }

    public static func extract<A>(
        _ fa: CofreeOf<F, A>
    ) -> A {
        fa^.head
    }
}

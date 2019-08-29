import Foundation
import Bow

public final class ForCofree {}
public final class CofreePartial<S>: Kind<ForCofree, S> {}
public typealias CofreeOf<S, A> = Kind<CofreePartial<S>, A>
public typealias CofreeEval<S, A> = Kind<S, Cofree<S, A>>

public class Cofree<S, A>: CofreeOf<S, A> {
    fileprivate let head: A
    fileprivate let tail: Eval<CofreeEval<S, A>>

    public static func fix(_ fa: CofreeOf<S, A>) -> Cofree<S, A> {
        return fa as! Cofree<S, A>
    }

    public init(_ head: A, _ tail: Eval<CofreeEval<S, A>>) {
        self.head = head
        self.tail = tail
    }

    public func tailForced() -> CofreeEval<S, A> {
        return tail.value()
    }

    public func mapBranchingRoot(_ functionK: FunctionK<S, S>) -> Cofree<S, A> {
        return Cofree(head, Eval.fix(tail.map{ coevsa in functionK.invoke(coevsa) }))
    }

    public func runTail() -> Cofree<S, A> {
        return Cofree(head, Eval.now(tail.value()))
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Cofree.
public postfix func ^<S, A>(_ fa: CofreeOf<S, A>) -> Cofree<S, A> {
    return Cofree.fix(fa)
}

public extension Cofree where S: Functor {
    static func unfold(_ a: A, _ f: @escaping (A) -> Kind<S, A>) -> Cofree<S, A> {
        return create(a, f)
    }

    static func create(_ a: A, _ f: @escaping (A) -> Kind<S, A>) -> Cofree<S, A> {
        return Cofree(a, Eval.later({ S.map(f(a), { inA in create(inA, f) }) }))
    }

    func transform<B>(_ f: @escaping (A) -> B, _ g: @escaping (Cofree<S, A>) -> Cofree<S, B>) -> Cofree<S, B> {
        return Cofree<S, B>(f(head), Eval.fix(tail.map{ coevsa in S.map(coevsa, g) }))
    }

    func mapBranchingS<T>(_ functionK: FunctionK<S, T>) -> Cofree<T, A> {
        return Cofree<T, A>(head, Eval.fix(tail.map { ce in functionK.invoke(S.map(ce, { cof in cof.mapBranchingS(functionK) })) }))
    }

    func mapBranchingT<T: Functor>(_ functionK: FunctionK<S, T>) -> Cofree<T, A> {
        return Cofree<T, A>(head, Eval.fix(tail.map{ ce in T.map(functionK.invoke(ce), { cof in cof.mapBranchingT(functionK) }) }))
    }

    func run() -> Cofree<S, A> {
        return Cofree(head, Eval.now(Eval.fix(tail.map{ coevsa in S.map(coevsa, { cof in cof.run() }) }).value()))
    }
}

public extension Cofree where S: Traverse {
    func cata<B>(_ folder: @escaping (A, Kind<S, B>) -> Eval<B>) -> Eval<B> {
        let ev = Eval.fix(S.traverse(self.tailForced(), { cof in cof.cata(folder) }))
        return Eval.fix(ev.flatMap { sb in folder(self.extract(), sb) })
    }

    func cataM<B, M: Monad>(_ folder: @escaping (A, Kind<S, B>) -> Kind<M, B>, _ inclusion: FunctionK<ForEval, M>) -> Kind<M, B> {
        func loop(_ ev : Cofree<S, A>) -> Eval<Kind<M, B>> {
            let looped = S.traverse(ev.tailForced(), { cof in  M.flatten(inclusion.invoke(Eval.defer({ loop(cof) }))) })
            let folded = M.flatMap(looped, { fb in folder(ev.head, fb) })
            return Eval.now(folded)
        }
        return M.flatten(inclusion.invoke(loop(self)))
    }
}

extension CofreePartial: Invariant where S: Functor {}

extension CofreePartial: Functor where S: Functor {
    public static func map<A, B>(_ fa: Kind<CofreePartial<S>, A>, _ f: @escaping (A) -> B) -> Kind<CofreePartial<S>, B> {
        return Cofree.fix(fa).transform(f, { cofsa in Cofree.fix(cofsa.map(f)) })
    }
}

extension CofreePartial: Comonad where S: Functor {
    public static func coflatMap<A, B>(_ fa: Kind<CofreePartial<S>, A>, _ f: @escaping (Kind<CofreePartial<S>, A>) -> B) -> Kind<CofreePartial<S>, B> {
        let cofree = Cofree.fix(fa)
        return Cofree<S, B>(f(fa), Eval.fix(cofree.tail.map { coevsa in S.map(coevsa, { _ in Cofree.fix(cofree.coflatMap(f)) }) }))
    }

    public static func extract<A>(_ fa: Kind<CofreePartial<S>, A>) -> A {
        return Cofree.fix(fa).head
    }
}

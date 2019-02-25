import Foundation
import Bow

public final class ForPTraversal {}
public final class PTraversalPartial<S, T, A>: Kind3<ForPTraversal, S, T, A> {}
public typealias PTraversalOf<S, T, A, B> = Kind<PTraversalPartial<S, T, A>, B>

public typealias Traversal<S, A> = PTraversal<S, S, A, A>
public typealias ForTraversal = ForPTraversal
public typealias TraversalOf<S, A> = PTraversalOf<S, S, A, A>
public typealias TraversalPartial<S> = Kind<ForPTraversal, S>

open class PTraversal<S, T, A, B>: PTraversalOf<S, T, A, B> {
    
    open func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        fatalError("modifyF must be implemented in subclasses")
    }

    public static func identity() -> Traversal<S, S> {
        return Iso<S, S>.identity().asTraversal()
    }
    
    public static func codiagonal() -> Traversal<Either<S, S>, S> {
        return CodiagonalTraversal()
    }
    
    public static func void() -> Traversal<S, A> {
        return Optional<S, A>.void().asTraversal()
    }
    
    public static func fromTraverse<T: Traverse>() -> PTraversal<Kind<T, A>, Kind<T, B>, A, B> {
        return TraverseTraversal()
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ set : @escaping (B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get2Traversal(get1: get1,
                             get2: get2,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get3Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ get4 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get4Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ get4 : @escaping (S) -> A,
                            _ get5 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get5Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ get4 : @escaping (S) -> A,
                            _ get5 : @escaping (S) -> A,
                            _ get6 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get6Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ get4 : @escaping (S) -> A,
                            _ get5 : @escaping (S) -> A,
                            _ get6 : @escaping (S) -> A,
                            _ get7 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get7Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             get7: get7,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ get4 : @escaping (S) -> A,
                            _ get5 : @escaping (S) -> A,
                            _ get6 : @escaping (S) -> A,
                            _ get7 : @escaping (S) -> A,
                            _ get8 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get8Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             get7: get7,
                             get8: get8,
                             set: set)
    }
    
    public static func from(_ get1 : @escaping (S) -> A,
                            _ get2 : @escaping (S) -> A,
                            _ get3 : @escaping (S) -> A,
                            _ get4 : @escaping (S) -> A,
                            _ get5 : @escaping (S) -> A,
                            _ get6 : @escaping (S) -> A,
                            _ get7 : @escaping (S) -> A,
                            _ get8 : @escaping (S) -> A,
                            _ get9 : @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get9Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             get7: get7,
                             get8: get8,
                             get9: get9,
                             set: set)
    }
    
    public static func +<C, D>(lhs : PTraversal<S, T, A, B>, rhs : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PTraversal<S, T, A, B>, rhs : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : PTraversal<S, T, A, B>, rhs : Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PTraversal<S, T, A, B>, rhs : POptional<A, B, C, D>) -> PTraversal<S, T, C, D>{
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PTraversal<S, T, A, B>, rhs : PPrism<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PTraversal<S, T, A, B>, rhs : PLens<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PTraversal<S, T, A, B>, rhs : PIso<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R  {
        return Const.fix(self.modifyF(s, { b in Const<R, B>(f(b)) })).value
    }
    
    public func getAll(_ s : S) -> ArrayK<A> {
        return ArrayK.fix(foldMap(s, { a in ArrayK([a]) }))
    }
    
    public func set(_ s : S, _ b : B) -> T {
        return modify(s, constant(b))
    }
    
    public func size(_ s : S) -> Int {
        return foldMap(s, constant(1))
    }
    
    public func isEmpty(_ s : S) -> Bool {
        return foldMap(s, constant(false))
    }
    
    public func nonEmpty(_ s : S) -> Bool {
        return !isEmpty(s)
    }
    
    public func headOption(_ s : S) -> Option<A> {
        return foldMap(s, FirstOption.init).const.value
    }
    
    public func lastOption(_ s : S) -> Option<A> {
        return foldMap(s, LastOption.init).const.value
    }
    
    public func choice<U, V>(_ other : PTraversal<U, V, A, B>) -> PTraversal<Either<S, U>, Either<T, V>, A, B> {
        return ChoiceTraversal(first: self, second: other)
    }
    
    public func compose<C, D>(_ other : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return ComposeTraversal(first: self, second: other)
    }
    
    public func compose<C, D>(_ other : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter().compose(other)
    }
    
    public func compose<C>(_ other : Fold<A, C>) -> Fold<S, C> {
        return self.asFold().compose(other)
    }
    
    public func compose<C, D>(_ other : POptional<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal())
    }
    
    public func compose<C, D>(_ other : PPrism<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal())
    }
    
    public func compose<C, D>(_ other : PLens<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal())
    }
    
    public func compose<C, D>(_ other : PIso<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal())
    }
    
    public func asSetter() -> PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    public func asFold() -> Fold<S, A> {
        return TraversalFold(traversal: self)
    }
    
    public func find(_ s : S, _ predicate : @escaping (A) -> Bool) -> Option<A> {
        return foldMap(s, { a in
            predicate(a) ? FirstOption(a) : FirstOption(Option.none())
        }).const.value
    }
    
    public func modify(_ s: S, _ f : @escaping (A) -> B) -> T {
        return Id.fix(modifyF(s, { a in Id.pure(f(a)) })).value
    }
    
    public func exists(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constant(false), constant(true))
    }
    
    public func forall(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return foldMap(s, predicate)
    }
}

extension PTraversal where A: Monoid {
    public func fold(_ s: S) -> A {
        return foldMap(s, id)
    }

    public func combineAll(_ s: S) -> A {
        return fold(s)
    }
}

fileprivate class ChoiceTraversal<S, T, U, V, A, B> : PTraversal<Either<S, U>, Either<T, V>, A, B> {
    private let first : PTraversal<S, T, A, B>
    private let second : PTraversal<U, V, A, B>
    
    init(first : PTraversal<S, T, A, B>, second : PTraversal<U, V, A, B>) {
        self.first = first
        self.second = second
    }

    override func modifyF<F: Applicative>(_ s: Either<S, U>, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, Either<T, V>> {
        return s.fold({ s in F.map(first.modifyF(s, f), { t in
            Either.left(t) }) },
                      { u in F.map(second.modifyF(u, f), { v in
                        Either.right(v) }) })
    }

}

fileprivate class TraversalFold<S, T, A, B> : Fold<S, A> {
    private let traversal : PTraversal<S, T, A, B>
    
    init(traversal : PTraversal<S, T, A, B>) {
        self.traversal = traversal
    }
    
    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return traversal.foldMap(s, f)
    }
}

fileprivate class CodiagonalTraversal<S> : Traversal<Either<S, S>, S> {
    override func modifyF<F>(_ s: Either<S, S>, _ f: @escaping (S) -> Kind<F, S>) -> Kind<F, Either<S, S>> where F : Applicative {
        return s.bimap(f, f)
            .fold({ fa in F.map(fa, Either.left) },
                  { fa in F.map(fa, Either.right) })
    }
}

fileprivate class TraverseTraversal<T: Traverse, A, B>: PTraversal<Kind<T, A>, Kind<T, B>, A, B> {
    override func modifyF<F: Applicative>(_ s: Kind<T, A>, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, Kind<T, B>> {
        return T.traverse(s, f)
    }
}

fileprivate class Get2Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let set : (B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         set : @escaping (B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     { b1, b2 in self.set(b1, b2, s) })
    }
}

fileprivate class Get3Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let set : (B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         set : @escaping (B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     { b1, b2, b3 in self.set(b1, b2, b3, s) })
    }
}

fileprivate class Get4Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let get4 : (S) -> A
    private let set : (B, B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         get4 : @escaping (S) -> A,
         set : @escaping (B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     { b1, b2, b3, b4 in self.set(b1, b2, b3, b4, s) })
    }
}

fileprivate class Get5Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let get4 : (S) -> A
    private let get5 : (S) -> A
    private let set : (B, B, B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         get4 : @escaping (S) -> A,
         get5 : @escaping (S) -> A,
         set : @escaping (B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     { b1, b2, b3, b4, b5 in self.set(b1, b2, b3, b4, b5, s) })
    }
}

fileprivate class Get6Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let get4 : (S) -> A
    private let get5 : (S) -> A
    private let get6 : (S) -> A
    private let set : (B, B, B, B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         get4 : @escaping (S) -> A,
         get5 : @escaping (S) -> A,
         get6 : @escaping (S) -> A,
         set : @escaping (B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     { b1, b2, b3, b4, b5, b6 in self.set(b1, b2, b3, b4, b5, b6, s) })
    }
}

fileprivate class Get7Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let get4 : (S) -> A
    private let get5 : (S) -> A
    private let get6 : (S) -> A
    private let get7 : (S) -> A
    private let set : (B, B, B, B, B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         get4 : @escaping (S) -> A,
         get5 : @escaping (S) -> A,
         get6 : @escaping (S) -> A,
         get7 : @escaping (S) -> A,
         set : @escaping (B, B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.get7 = get7
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     f(self.get7(s)),
                     { b1, b2, b3, b4, b5, b6, b7 in self.set(b1, b2, b3, b4, b5, b6, b7, s) })
    }
}

fileprivate class Get8Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let get4 : (S) -> A
    private let get5 : (S) -> A
    private let get6 : (S) -> A
    private let get7 : (S) -> A
    private let get8 : (S) -> A
    private let set : (B, B, B, B, B, B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         get4 : @escaping (S) -> A,
         get5 : @escaping (S) -> A,
         get6 : @escaping (S) -> A,
         get7 : @escaping (S) -> A,
         get8 : @escaping (S) -> A,
         set : @escaping (B, B, B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.get7 = get7
        self.get8 = get8
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     f(self.get7(s)),
                     f(self.get8(s)),
                     { b1, b2, b3, b4, b5, b6, b7, b8 in self.set(b1, b2, b3, b4, b5, b6, b7, b8, s) })
    }
}

fileprivate class Get9Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1 : (S) -> A
    private let get2 : (S) -> A
    private let get3 : (S) -> A
    private let get4 : (S) -> A
    private let get5 : (S) -> A
    private let get6 : (S) -> A
    private let get7 : (S) -> A
    private let get8 : (S) -> A
    private let get9 : (S) -> A
    private let set : (B, B, B, B, B, B, B, B, B, S) -> T
    
    init(get1 : @escaping (S) -> A,
         get2 : @escaping (S) -> A,
         get3 : @escaping (S) -> A,
         get4 : @escaping (S) -> A,
         get5 : @escaping (S) -> A,
         get6 : @escaping (S) -> A,
         get7 : @escaping (S) -> A,
         get8 : @escaping (S) -> A,
         get9 : @escaping (S) -> A,
         set : @escaping (B, B, B, B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.get7 = get7
        self.get8 = get8
        self.get9 = get9
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     f(self.get7(s)),
                     f(self.get8(s)),
                     f(self.get9(s)),
                     { b1, b2, b3, b4, b5, b6, b7, b8, b9 in self.set(b1, b2, b3, b4, b5, b6, b7, b8, b9, s) })
    }
}

fileprivate class ComposeTraversal<S, T, A, B, C, D> : PTraversal<S, T, C, D> {
    private let first : PTraversal<S, T, A, B>
    private let second : PTraversal<A, B, C, D>
    
    init(first : PTraversal<S, T, A, B>, second : PTraversal<A, B, C, D>) {
        self.first = first
        self.second = second
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (C) -> Kind<F, D>) -> Kind<F, T> {
        return self.first.modifyF(s, { a in
            self.second.modifyF(a, f)
        })
    }
}

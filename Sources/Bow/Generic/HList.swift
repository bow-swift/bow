import Foundation

public class HList {
    public var count : Int {
        fatalError("count must be overriden in subclasses")
    }
}

public class HNil : HList {
    public static var instance : HNil {
        return HNil()
    }
    
    override public var count: Int {
        return 0
    }
}

public class HCons<H, T : HList> : HList {
    public let head : H
    public let tail : T
    
    public init(_ head : H, _ tail : T) {
        self.head = head
        self.tail = tail
    }
    
    override public var count: Int {
        return 1 + tail.count
    }
}

public typealias HList1<A> = HCons<A, HNil>
public typealias HList2<A, B> = HCons<A, HCons<B, HNil>>
public typealias HList3<A, B, C> = HCons<A, HCons<B, HCons<C, HNil>>>
public typealias HList4<A, B, C, D> = HCons<A, HCons<B, HCons<C, HCons<D, HNil>>>>
public typealias HList5<A, B, C, D, E> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HNil>>>>>
public typealias HList6<A, B, C, D, E, F> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HNil>>>>>>
public typealias HList7<A, B, C, D, E, F, G> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HNil>>>>>>>
public typealias HList8<A, B, C, D, E, F, G, H> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HNil>>>>>>>>
public typealias HList9<A, B, C, D, E, F, G, H, I> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HNil>>>>>>>>>
public typealias HList10<A, B, C, D, E, F, G, H, I, J> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HNil>>>>>>>>>>
public typealias HList11<A, B, C, D, E, F, G, H, I, J, K> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HNil>>>>>>>>>>>
public typealias HList12<A, B, C, D, E, F, G, H, I, J, K, L> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HNil>>>>>>>>>>>>
public typealias HList13<A, B, C, D, E, F, G, H, I, J, K, L, M> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HNil>>>>>>>>>>>>>
public typealias HList14<A, B, C, D, E, F, G, H, I, J, K, L, M, N> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HNil>>>>>>>>>>>>>>
public typealias HList15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HNil>>>>>>>>>>>>>>>
public typealias HList16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HNil>>>>>>>>>>>>>>>>
public typealias HList17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HCons<Q, HNil>>>>>>>>>>>>>>>>>
public typealias HList18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HCons<Q, HCons<R, HNil>>>>>>>>>>>>>>>>>>
public typealias HList19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HCons<Q, HCons<R, HCons<S, HNil>>>>>>>>>>>>>>>>>>>
public typealias HList20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HCons<Q, HCons<R, HCons<S, HCons<T, HNil>>>>>>>>>>>>>>>>>>>>
public typealias HList21<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HCons<Q, HCons<R, HCons<S, HCons<T, HCons<U, HNil>>>>>>>>>>>>>>>>>>>>>
public typealias HList22<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V> = HCons<A, HCons<B, HCons<C, HCons<D, HCons<E, HCons<F, HCons<G, HCons<H, HCons<I, HCons<J, HCons<K, HCons<L, HCons<M, HCons<N, HCons<O, HCons<P, HCons<Q, HCons<R, HCons<S, HCons<T, HCons<U, HCons<V, HNil>>>>>>>>>>>>>>>>>>>>>>

// Factory functions

public func hListOf<A>(_ a : A) -> HList1<A> {
    return HCons(a, HNil.instance)
}

public func hListOf<A, B>(_ a : A, _ b : B) -> HList2<A, B> {
    return HCons(a, HCons(b, HNil.instance))
}

public func hListOf<A, B, C>(_ a : A, _ b : B, _ c : C) -> HList3<A, B, C> {
    return HCons(a, HCons(b, HCons(c, HNil.instance)))
}

public func hListOf<A, B, C, D>(_ a : A, _ b : B, _ c : C, _ d : D) -> HList4<A, B, C, D> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HNil.instance))))
}

public func hListOf<A, B, C, D, E>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E) -> HList5<A, B, C, D, E> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HNil.instance)))))
}

public func hListOf<A, B, C, D, E, F>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F) -> HList6<A, B, C, D, E, F> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HNil.instance))))))
}

public func hListOf<A, B, C, D, E, F, G>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G) -> HList7<A, B, C, D, E, F, G> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HNil.instance)))))))
}

public func hListOf<A, B, C, D, E, F, G, H>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H) -> HList8<A, B, C, D, E, F, G, H> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HNil.instance))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I) -> HList9<A, B, C, D, E, F, G, H, I> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HNil.instance)))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J) -> HList10<A, B, C, D, E, F, G, H, I, J> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HNil.instance))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K) -> HList11<A, B, C, D, E, F, G, H, I, J, K> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HNil.instance)))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L) -> HList12<A, B, C, D, E, F, G, H, I, J, K, L> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HNil.instance))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M) -> HList13<A, B, C, D, E, F, G, H, I, J, K, L, M> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HNil.instance)))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N) -> HList14<A, B, C, D, E, F, G, H, I, J, K, L, M, N> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HNil.instance))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O) -> HList15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HNil.instance)))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P) -> HList16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HNil.instance))))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P, _ q : Q) -> HList17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HCons(q, HNil.instance)))))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P, _ q : Q, _ r : R) -> HList18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HCons(q, HCons(r, HNil.instance))))))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P, _ q : Q, _ r : R, _ s : S) -> HList19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HCons(q, HCons(r, HCons(s, HNil.instance)))))))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P, _ q : Q, _ r : R, _ s : S, _ t : T) -> HList20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HCons(q, HCons(r, HCons(s, HCons(t, HNil.instance))))))))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P, _ q : Q, _ r : R, _ s : S, _ t : T, _ u : U) -> HList21<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HCons(q, HCons(r, HCons(s, HCons(t, HCons(u, HNil.instance)))))))))))))))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V>(_ a : A, _ b : B, _ c : C, _ d : D, _ e : E, _ f : F, _ g : G, _ h : H, _ i : I, _ j : J, _ k : K, _ l : L, _ m : M, _ n : N, _ o : O, _ p : P, _ q : Q, _ r : R, _ s : S, _ t : T, _ u : U, _ v : V) -> HList21<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HCons(k, HCons(l, HCons(m, HCons(n, HCons(o, HCons(p, HCons(q, HCons(r, HCons(s, HCons(t, HCons(u, HCons(v, HNil.instance))))))))))))))))))))))
}

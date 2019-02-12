import Foundation

public class HList {
    public var count: Int {
        fatalError("count must be overriden in subclasses")
    }
}

public class HNil: HList {
    public static var instance: HNil {
        return HNil()
    }
    
    override public var count: Int {
        return 0
    }
}

public class HCons<H, T: HList> : HList {
    public let head: H
    public let tail: T
    
    public init(_ head: H, _ tail: T) {
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

// Factory functions

public func hListOf<A>(_ a: A) -> HList1<A> {
    return HCons(a, HNil.instance)
}

public func hListOf<A, B>(_ a: A, _ b: B) -> HList2<A, B> {
    return HCons(a, HCons(b, HNil.instance))
}

public func hListOf<A, B, C>(_ a: A, _ b: B, _ c: C) -> HList3<A, B, C> {
    return HCons(a, HCons(b, HCons(c, HNil.instance)))
}

public func hListOf<A, B, C, D>(_ a: A, _ b: B, _ c: C, _ d: D) -> HList4<A, B, C, D> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HNil.instance))))
}

public func hListOf<A, B, C, D, E>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> HList5<A, B, C, D, E> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HNil.instance)))))
}

public func hListOf<A, B, C, D, E, F>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> HList6<A, B, C, D, E, F> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HNil.instance))))))
}

public func hListOf<A, B, C, D, E, F, G>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> HList7<A, B, C, D, E, F, G> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HNil.instance)))))))
}

public func hListOf<A, B, C, D, E, F, G, H>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> HList8<A, B, C, D, E, F, G, H> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HNil.instance))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> HList9<A, B, C, D, E, F, G, H, I> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HNil.instance)))))))))
}

public func hListOf<A, B, C, D, E, F, G, H, I, J>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> HList10<A, B, C, D, E, F, G, H, I, J> {
    return HCons(a, HCons(b, HCons(c, HCons(d, HCons(e, HCons(f, HCons(g, HCons(h, HCons(i, HCons(j, HNil.instance))))))))))
}

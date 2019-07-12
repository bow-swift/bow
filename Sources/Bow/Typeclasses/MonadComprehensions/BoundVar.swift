public class BoundVar<F: Monad, A> {
    private var value: A? = nil
    
    public static func make() -> BoundVar<F, A> {
        return BoundVar<F, A>()
    }
    
    internal init() {}
    
    internal func bind(_ value: A) {
        self.value = value
    }
    
    public var get: A {
        return value!
    }
    
    internal var erased: BoundVar<F, Any> {
        return ErasedBoundVar<F, A>(self)
    }
}

public extension Monad {
    static func `var`<A>(_ type: A.Type) -> BoundVar<Self, A> {
        return BoundVar.make()
    }
}

private class ErasedBoundVar<F: Monad, A>: BoundVar<F, Any> {
    private var boundVar: BoundVar<F, A>
    
    fileprivate init(_ boundVar: BoundVar<F, A>) {
        self.boundVar = boundVar
    }
    
    override func bind(_ value: Any) {
        boundVar.bind(value as! A)
    }
}

internal class BoundVar2<F: Monad, A, B>: BoundVar<F, (A, B)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>) {
        self.a = a
        self.b = b
    }
    
    override func bind(_ value: (A, B)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
    }
}

internal class BoundVar3<F: Monad, A, B, C>: BoundVar<F, (A, B, C)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    override func bind(_ value: (A, B, C)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
    }
}

internal class BoundVar4<F: Monad, A, B, C, D>: BoundVar<F, (A, B, C, D)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    
    override func bind(_ value: (A, B, C, D)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
    }
}

internal class BoundVar5<F: Monad, A, B, C, D, E>: BoundVar<F, (A, B, C, D, E)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    let e: BoundVar<F, E>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>, _ e: BoundVar<F, E>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
    }
    
    override func bind(_ value: (A, B, C, D, E)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
        self.e.bind(value.4)
    }
}

internal class BoundVar6<F: Monad, A, B, C, D, E, G>: BoundVar<F, (A, B, C, D, E, G)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    let e: BoundVar<F, E>
    let g: BoundVar<F, G>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>, _ e: BoundVar<F, E>, _ g: BoundVar<F, G>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.g = g
    }
    
    override func bind(_ value: (A, B, C, D, E, G)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
        self.e.bind(value.4)
        self.g.bind(value.5)
    }
}

internal class BoundVar7<F: Monad, A, B, C, D, E, G, H>: BoundVar<F, (A, B, C, D, E, G, H)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    let e: BoundVar<F, E>
    let g: BoundVar<F, G>
    let h: BoundVar<F, H>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>, _ e: BoundVar<F, E>, _ g: BoundVar<F, G>, _ h: BoundVar<F, H>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.g = g
        self.h = h
    }
    
    override func bind(_ value: (A, B, C, D, E, G, H)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
        self.e.bind(value.4)
        self.g.bind(value.5)
        self.h.bind(value.6)
    }
}

internal class BoundVar8<F: Monad, A, B, C, D, E, G, H, I>: BoundVar<F, (A, B, C, D, E, G, H, I)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    let e: BoundVar<F, E>
    let g: BoundVar<F, G>
    let h: BoundVar<F, H>
    let i: BoundVar<F, I>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>, _ e: BoundVar<F, E>, _ g: BoundVar<F, G>, _ h: BoundVar<F, H>, _ i: BoundVar<F, I>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.g = g
        self.h = h
        self.i = i
    }
    
    override func bind(_ value: (A, B, C, D, E, G, H, I)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
        self.e.bind(value.4)
        self.g.bind(value.5)
        self.h.bind(value.6)
        self.i.bind(value.7)
    }
}

internal class BoundVar9<F: Monad, A, B, C, D, E, G, H, I, J>: BoundVar<F, (A, B, C, D, E, G, H, I, J)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    let e: BoundVar<F, E>
    let g: BoundVar<F, G>
    let h: BoundVar<F, H>
    let i: BoundVar<F, I>
    let j: BoundVar<F, J>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>, _ e: BoundVar<F, E>, _ g: BoundVar<F, G>, _ h: BoundVar<F, H>, _ i: BoundVar<F, I>, _ j: BoundVar<F, J>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.g = g
        self.h = h
        self.i = i
        self.j = j
    }
    
    override func bind(_ value: (A, B, C, D, E, G, H, I, J)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
        self.e.bind(value.4)
        self.g.bind(value.5)
        self.h.bind(value.6)
        self.i.bind(value.7)
        self.j.bind(value.8)
    }
}

internal class BoundVar10<F: Monad, A, B, C, D, E, G, H, I, J, K>: BoundVar<F, (A, B, C, D, E, G, H, I, J, K)> {
    let a: BoundVar<F, A>
    let b: BoundVar<F, B>
    let c: BoundVar<F, C>
    let d: BoundVar<F, D>
    let e: BoundVar<F, E>
    let g: BoundVar<F, G>
    let h: BoundVar<F, H>
    let i: BoundVar<F, I>
    let j: BoundVar<F, J>
    let k: BoundVar<F, K>
    
    init(_ a: BoundVar<F, A>, _ b: BoundVar<F, B>, _ c: BoundVar<F, C>, _ d: BoundVar<F, D>, _ e: BoundVar<F, E>, _ g: BoundVar<F, G>, _ h: BoundVar<F, H>, _ i: BoundVar<F, I>, _ j: BoundVar<F, J>, _ k: BoundVar<F, K>) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.g = g
        self.h = h
        self.i = i
        self.j = j
        self.k = k
    }
    
    override func bind(_ value: (A, B, C, D, E, G, H, I, J, K)) {
        self.a.bind(value.0)
        self.b.bind(value.1)
        self.c.bind(value.2)
        self.d.bind(value.3)
        self.e.bind(value.4)
        self.g.bind(value.5)
        self.h.bind(value.6)
        self.i.bind(value.7)
        self.j.bind(value.8)
        self.k.bind(value.9)
    }
}

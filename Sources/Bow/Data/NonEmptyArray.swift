import Foundation

public final class ForNonEmptyArray {}
public typealias NonEmptyArrayOf<A> = Kind<ForNonEmptyArray, A>
public typealias NEA<A> = NonEmptyArray<A>

public final class NonEmptyArray<A>: NonEmptyArrayOf<A> {
    public let head: A
    public let tail: [A]
    
    public static func +(lhs: NonEmptyArray<A>, rhs: NonEmptyArray<A>) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }
    
    public static func +(lhs : NonEmptyArray<A>, rhs: [A]) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + rhs)
    }
    
    public static func +(lhs: NonEmptyArray<A>, rhs: A) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + [rhs])
    }
    
    public static func of(_ head: A, _ tail: A...) -> NonEmptyArray<A> {
        return NonEmptyArray(head: head, tail: tail)
    }
    
    public static func fromArray(_ array: [A]) -> Option<NonEmptyArray<A>> {
        return array.isEmpty ? Option<NonEmptyArray<A>>.none() : Option<NonEmptyArray<A>>.some(NonEmptyArray(all: array))
    }
    
    public static func fromArrayUnsafe(_ array: [A]) -> NonEmptyArray<A> {
        return NonEmptyArray(all: array)
    }
    
    public static func fix(_ fa: NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
        return fa as! NonEmptyArray<A>
    }
    
    public init(head: A, tail: [A]) {
        self.head = head
        self.tail = tail
    }
    
    private init(all: [A]) {
        self.head = all[0]
        self.tail = [A](all.dropFirst(1))
    }

    public func all() -> [A] {
        return [head] + tail
    }
    
    public func getOrNone(_ i: Int) -> Option<A> {
        let a = all()
        if i >= 0 && i < a.count {
            return Option<A>.some(a[i])
        } else {
            return Option<A>.none()
        }
    }

    public subscript(index: Int) -> Option<A> {
        return getOrNone(index)
    }
}

public postfix func ^<A>(_ fa: NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
    return NonEmptyArray.fix(fa)
}

public extension NonEmptyArray where A: Equatable {
    public func contains(element : A) -> Bool {
        return head == element || tail.contains(where: { $0 == element })
    }
    
    public func containsAll(elements: [A]) -> Bool {
        return elements.map(contains).reduce(true, and)
    }
}

extension NonEmptyArray: CustomStringConvertible {
    public var description: String {
        return "NonEmptyArray(\(self.all())"
    }
}

extension NonEmptyArray: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        let contentsString = self.all().map { x in x.debugDescription }.joined(separator: ", ")
        return "NonEmptyArray(\(contentsString))"
    }
}

extension ForNonEmptyArray: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForNonEmptyArray, A>, _ rhs: Kind<ForNonEmptyArray, A>) -> Bool where A : Equatable {
        return NEA.fix(lhs).all() == NEA.fix(rhs).all()
    }
}

extension ForNonEmptyArray: Functor {
    public static func map<A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ f: @escaping (A) -> B) -> Kind<ForNonEmptyArray, B> {
        return NonEmptyArray.fromArrayUnsafe(NonEmptyArray.fix(fa).all().map(f))
    }
}

extension ForNonEmptyArray: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForNonEmptyArray, A> {
        return NonEmptyArray(head: a, tail: [])
    }
}

extension ForNonEmptyArray: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ f: @escaping (A) -> Kind<ForNonEmptyArray, B>) -> Kind<ForNonEmptyArray, B> {
        let nea = NonEmptyArray.fix(fa)
        return NEA.fix(f(nea.head)) + nea.tail.flatMap{ a in NEA.fix(f(a)).all() }
    }

    private static func go<A, B>(_ buf: [B], _ f: @escaping (A) -> NonEmptyArrayOf<Either<A, B>>, _ v: NonEmptyArray<Either<A, B>>) -> [B] {
        let head = v.head
        return head.fold({ a in go(buf, f, NonEmptyArray.fix(f(a)) + v.tail) },
                         { b in
                            let newBuf = buf + [b]
                            let x = NonEmptyArray<Either<A, B>>.fromArray(v.tail)
                            return x.fold({ newBuf },
                                          { value in go(newBuf, f, value) })
        })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForNonEmptyArray, Either<A, B>>) -> Kind<ForNonEmptyArray, B> {
        return NonEmptyArray.fromArrayUnsafe(go([], f, NonEmptyArray.fix(f(a))))
    }
}

extension ForNonEmptyArray: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ f: @escaping (Kind<ForNonEmptyArray, A>) -> B) -> Kind<ForNonEmptyArray, B> {
        func consume(_ array : [A], _ buf : [B] = []) -> [B] {
            if array.isEmpty {
                return buf
            } else {
                let tail = [A](array.dropFirst())
                let newBuf = buf + [f(NonEmptyArray(head: array[0], tail: tail))]
                return consume(tail, newBuf)
            }
        }
        let nea = NonEmptyArray.fix(fa)
        return NonEmptyArray(head: f(nea), tail: consume(nea.tail))
    }

    public static func extract<A>(_ fa: Kind<ForNonEmptyArray, A>) -> A {
        return NonEmptyArray.fix(fa).head
    }
}

extension ForNonEmptyArray: Bimonad {}

extension ForNonEmptyArray: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let nea = NonEmptyArray.fix(fa)
        return nea.tail.reduce(f(b, nea.head), f)
    }

    public static func foldRight<A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let nea = NonEmptyArray.fix(fa)
        return nea.all().k().foldRight(b, f)
    }
}

extension ForNonEmptyArray: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForNonEmptyArray, B>> {
        let nea = NonEmptyArray.fix(fa)
        let arrayTraverse = nea.all().k().traverse(f)
        return G.map(arrayTraverse, { x in NonEmptyArray.fromArrayUnsafe(ArrayK.fix(x).asArray) })
    }
}

extension ForNonEmptyArray: SemigroupK {
    public static func combineK<A>(_ x: Kind<ForNonEmptyArray, A>, _ y: Kind<ForNonEmptyArray, A>) -> Kind<ForNonEmptyArray, A> {
        return NonEmptyArray.fix(x) + NonEmptyArray.fix(y)
    }
}

extension NonEmptyArray: Semigroup {
    public func combine(_ other: NonEmptyArray<A>) -> NonEmptyArray<A> {
        return self + other
    }
}

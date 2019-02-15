import Foundation

public final class ForArrayK {}
public typealias ArrayKOf<A> = Kind<ForArrayK, A>

public final class ArrayK<A>: ArrayKOf<A> {
    fileprivate let array: [A]
    
    public static func +(lhs: ArrayK<A>, rhs: ArrayK<A>) -> ArrayK<A> {
        return ArrayK(lhs.array + rhs.array)
    }

    public static func fix(_ fa: ArrayKOf<A>) -> ArrayK<A> {
        return fa as! ArrayK<A>
    }
    
    public init(_ array: [A]) {
        self.array = array
    }
    
    public var asArray: [A] {
        return array
    }

    public func firstOrNone() -> Option<A> {
        if let first = asArray.first { return Option.some(first) }
        return Option.none()
    }
    
    public func getOrNone(_ i: Int) -> Option<A> {
        if i >= 0 && i < array.count {
            return Option<A>.some(array[i])
        } else {
            return Option<A>.none()
        }
    }

    public subscript(index: Int) -> Option<A> {
        return getOrNone(index)
    }
}

public extension Array {
    public func k() -> ArrayK<Element> {
        return ArrayK(self)
    }
}

extension ArrayK : CustomStringConvertible {
    public var description : String {
        let contentsString = self.array.map { x in "\(x)" }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

extension ArrayK : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        let contentsString = self.array.map { x in x.debugDescription }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

extension ForArrayK: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForArrayK, A>, _ rhs: Kind<ForArrayK, A>) -> Bool where A : Equatable {
        return ArrayK.fix(lhs).array == ArrayK.fix(rhs).array
    }
}

extension ForArrayK: Functor {
    public static func map<A, B>(_ fa: Kind<ForArrayK, A>, _ f: @escaping (A) -> B) -> Kind<ForArrayK, B> {
        return ArrayK(ArrayK.fix(fa).array.map(f))
    }
}

extension ForArrayK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForArrayK, A> {
        return ArrayK([a])
    }
}

extension ForArrayK: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForArrayK, A>, _ f: @escaping (A) -> Kind<ForArrayK, B>) -> Kind<ForArrayK, B> {
        let fixed = ArrayK<A>.fix(fa)
        return ArrayK<B>(fixed.array.flatMap({ a in ArrayK.fix(f(a)).array }))
    }

    private static func go<A, B>(_ buf : [B], _ f : (A) -> ArrayKOf<Either<A, B>>, _ v : ArrayK<Either<A, B>>) -> [B] {
        if !v.isEmpty {
            let head = v.array[0]
            return head.fold({ a in go(buf, f, ArrayK<Either<A, B>>(ArrayK<Either<A, B>>.fix(f(a)).array + v.array.dropFirst())) },
                             { b in
                                let newBuf = buf + [b]
                                return go(newBuf, f, ArrayK<Either<A, B>>([Either<A, B>](v.array.dropFirst())))
            })
        }
        return buf
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForArrayK, Either<A, B>>) -> Kind<ForArrayK, B> {
        return ArrayK<B>(go([], f, ArrayK.fix(f(a))))
    }
}

extension ForArrayK: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForArrayK, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return ArrayK.fix(fa).array.reduce(b, f)
    }

    public static func foldRight<A, B>(_ fa: Kind<ForArrayK, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ lkw : ArrayK<A>) -> Eval<B> {
            if lkw.array.isEmpty {
                return b
            } else {
                return f(lkw.array[0], Eval.deferEvaluation({ loop(ArrayK([A](lkw.array.dropFirst())))  }))
            }
        }
        return Eval.deferEvaluation({ loop(ArrayK.fix(fa)) })
    }
}

extension ForArrayK: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForArrayK, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForArrayK, B>> {
        let x = foldRight(fa, Eval.always({ G.pure(ArrayK<B>([])) }),
                          { a, eval in G.map2Eval(f(a), eval, { x, y in ArrayK<B>([x]) + y }) }).value()
        return G.map(x, { a in a as ArrayKOf<B> })
    }
}

extension ForArrayK: SemigroupK {
    public static func combineK<A>(_ x: Kind<ForArrayK, A>, _ y: Kind<ForArrayK, A>) -> Kind<ForArrayK, A> {
        return ArrayK.fix(x) + ArrayK.fix(y)
    }
}

extension ForArrayK: MonoidK {
    public static func emptyK<A>() -> Kind<ForArrayK, A> {
        return ArrayK([])
    }
}

extension ForArrayK: FunctorFilter {}

extension ForArrayK: MonadFilter {
    public static func empty<A>() -> Kind<ForArrayK, A> {
        return ArrayK([])
    }
}

extension ForArrayK: MonadCombine {}

extension ArrayK: Semigroup {
    public func combine(_ other: ArrayK<A>) -> ArrayK {
        return self + other
    }
}

extension ArrayK: Monoid {
    public static func empty() -> ArrayK {
        return ArrayK([])
    }
}

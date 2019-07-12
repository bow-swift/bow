import Foundation

/// Witness for the `ArrayK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForArrayK {}

/// Higher Kinded Type alias to improve readability over `Kind<ForArrayK, A>`
public typealias ArrayKOf<A> = Kind<ForArrayK, A>

/// ArrayK is a Higher Kinded Type wrapper over Swift arrays.
public final class ArrayK<A>: ArrayKOf<A> {
    fileprivate let array: [A]

    /// Concatenates two arrays
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the concatenation.
    ///   - rhs: Right hand side of the concatenation.
    /// - Returns: An array that contains the elements of the two arrays in the order they appear in the original ones.
    public static func +(lhs: ArrayK<A>, rhs: ArrayK<A>) -> ArrayK<A> {
        return ArrayK(lhs.array + rhs.array)
    }
    
    /// Prepends an element to an array.
    ///
    /// - Parameters:
    ///   - lhs: Element to prepend.
    ///   - rhs: Array.
    /// - Returns: An array containing the prepended element at the head and the other array as the tail.
    public static func +(lhs: A, rhs: ArrayK<A>) -> ArrayK<A> {
        return ArrayK(lhs) + rhs
    }
    
    /// Appends an element to an array.
    ///
    /// - Parameters:
    ///   - lhs: Array.
    ///   - rhs: Element to append.
    /// - Returns: An array containing all elements of the first array and the appended element as the last element.
    public static func +(lhs: ArrayK<A>, rhs: A) -> ArrayK<A> {
        return lhs + ArrayK(rhs)
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to ArrayK.
    public static func fix(_ fa: ArrayKOf<A>) -> ArrayK<A> {
        return fa as! ArrayK<A>
    }

    /// Initializes an `ArrayK`.
    ///
    /// - Parameter array: A Swift array of values.
    public init(_ array: [A]) {
        self.array = array
    }

    /// Initializes an `ArrayK`.
    ///
    /// - Parameter values: A variable number of values.
    public init(_ values: A...) {
        self.array = values
    }

    /// Obtains the wrapped array.
    public var asArray: [A] {
        return array
    }

    /// Obtains the first element of this array, or `Option.none` if it is empty.
    ///
    /// - Returns: An optional value containing the first element of the array, if present.
    public func firstOrNone() -> Option<A> {
        return asArray.first.toOption()
    }

    /// Obtains the last element of this array, or `Option.none` if it is empty.
    ///
    /// - Returns: An optional value containing the first element of the array, if present.
    public func lastOrNone() -> Option<A> {
        return asArray.last.toOption()
    }
    
    /// Obtains the element in the position passed as an argument, if any.
    ///
    /// - Parameter i: Index of the element to obtain.
    /// - Returns: An optional value containing the element of the array at the specified index, if present.
    public func getOrNone(_ i: Int) -> Option<A> {
        if i >= 0 && i < array.count {
            return Option<A>.some(array[i])
        } else {
            return Option<A>.none()
        }
    }

    /// Obtains the element in the position passed as an argument, if any.
    ///
    /// - Parameter index: Index of the element to obtain.
    public subscript(index: Int) -> Option<A> {
        return getOrNone(index)
    }
    
    /// Drops the first element of this array.
    ///
    /// - Returns: A new array that contains all elements but the first.
    public func dropFirst() -> ArrayK<A> {
        return ArrayK(Array(asArray.dropFirst()))
    }
    
    /// Drops the last element of this array.
    ///
    /// - Returns: A new array that contains all elements but the last.
    public func dropLast() -> ArrayK<A> {
        return ArrayK(Array(asArray.dropLast()))
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to ArrayK.
public postfix func ^<A>(_ fa: ArrayKOf<A>) -> ArrayK<A> {
    return ArrayK.fix(fa)
}

// MARK: Convenience methods to convert to ArrayK
public extension Array {
    /// Creates an `ArrayK` from this array.
    ///
    /// - Returns: An `ArrayK` wrapping this array.
    func k() -> ArrayK<Element> {
        return ArrayK(self)
    }
}

// MARK: Conformance of `ArrayK` to `CustomStringConvertible`.
extension ArrayK: CustomStringConvertible {
    public var description: String {
        let contentsString = self.array.map { x in "\(x)" }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

// MARK: Conformance of `ArrayK` to `CustomDebugStringConvertible`.
extension ArrayK: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        let contentsString = self.array.map { x in x.debugDescription }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

// MARK: Instance of `EquatableK` for `ArrayK`
extension ForArrayK: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForArrayK, A>, _ rhs: Kind<ForArrayK, A>) -> Bool where A : Equatable {
        return ArrayK.fix(lhs).array == ArrayK.fix(rhs).array
    }
}

// MARK: Instance of `Functor` for `ArrayK`
extension ForArrayK: Functor {
    public static func map<A, B>(_ fa: Kind<ForArrayK, A>, _ f: @escaping (A) -> B) -> Kind<ForArrayK, B> {
        return ArrayK(ArrayK.fix(fa).array.map(f))
    }
}

// MARK: Instance of `Applicative` for `ArrayK`
extension ForArrayK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForArrayK, A> {
        return ArrayK([a])
    }
}

// MARK: Instance of `Selective` for `ArrayK`
extension ForArrayK: Selective {}

// MARK: Instance of `Monad` for `ArrayK`
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

// MARK: Instance of `Foldable` for `ArrayK`
extension ForArrayK: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForArrayK, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return ArrayK.fix(fa).array.reduce(b, f)
    }

    public static func foldRight<A, B>(_ fa: Kind<ForArrayK, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ lkw : ArrayK<A>) -> Eval<B> {
            if lkw.array.isEmpty {
                return b
            } else {
                return f(lkw.array[0], Eval.defer({ loop(ArrayK([A](lkw.array.dropFirst())))  }))
            }
        }
        return Eval.defer({ loop(ArrayK.fix(fa)) })
    }
}

// MARK: Instance of `Traverse` for `ArrayK`
extension ForArrayK: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForArrayK, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForArrayK, B>> {
        let x = foldRight(fa, Eval.always({ G.pure(ArrayK<B>([])) }),
                          { a, eval in G.map2Eval(f(a), eval, { x, y in ArrayK<B>([x]) + y }) }).value()
        return G.map(x, { a in a as ArrayKOf<B> })
    }
}

// MARK: Instance of `SemigroupK` for `ArrayK`
extension ForArrayK: SemigroupK {
    public static func combineK<A>(_ x: Kind<ForArrayK, A>, _ y: Kind<ForArrayK, A>) -> Kind<ForArrayK, A> {
        return ArrayK.fix(x) + ArrayK.fix(y)
    }
}

// MARK: Instance of `MonoidK` for `ArrayK`
extension ForArrayK: MonoidK {
    public static func emptyK<A>() -> Kind<ForArrayK, A> {
        return ArrayK([])
    }
}

// MARK: Instance of `FunctorFilter` for `ArrayK`
extension ForArrayK: FunctorFilter {}

// MARK: Instance of `MonadFilter` for `ArrayK`
extension ForArrayK: MonadFilter {
    public static func empty<A>() -> Kind<ForArrayK, A> {
        return ArrayK([])
    }
}

// MARK: Instance of `MonadCombine` for `ArrayK`
extension ForArrayK: MonadCombine {}

// MARK: Instance of `Semigroup` for `ArrayK`
extension ArrayK: Semigroup {
    public func combine(_ other: ArrayK<A>) -> ArrayK {
        return self + other
    }
}

// MARK: Instance of `Monoid` for `ArrayK`
extension ArrayK: Monoid {
    public static func empty() -> ArrayK {
        return ArrayK([])
    }
}

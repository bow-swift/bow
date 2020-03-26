import Foundation

/// Witness for the `ArrayK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForArrayK {}

/// Partial application of the ArrayK type constructor, omitting the last type parameter.
public typealias ArrayKPartial = ForArrayK

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
        ArrayK(lhs.array + rhs.array)
    }
    
    /// Prepends an element to an array.
    ///
    /// - Parameters:
    ///   - lhs: Element to prepend.
    ///   - rhs: Array.
    /// - Returns: An array containing the prepended element at the head and the other array as the tail.
    public static func +(lhs: A, rhs: ArrayK<A>) -> ArrayK<A> {
        ArrayK(lhs) + rhs
    }
    
    /// Appends an element to an array.
    ///
    /// - Parameters:
    ///   - lhs: Array.
    ///   - rhs: Element to append.
    /// - Returns: An array containing all elements of the first array and the appended element as the last element.
    public static func +(lhs: ArrayK<A>, rhs: A) -> ArrayK<A> {
        lhs + ArrayK(rhs)
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to ArrayK.
    public static func fix(_ fa: ArrayKOf<A>) -> ArrayK<A> {
        fa as! ArrayK<A>
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
        array
    }

    /// Obtains the first element of this array, or `Option.none` if it is empty.
    ///
    /// - Returns: An optional value containing the first element of the array, if present.
    public func firstOrNone() -> Option<A> {
        asArray.first.toOption()
    }

    /// Obtains the last element of this array, or `Option.none` if it is empty.
    ///
    /// - Returns: An optional value containing the first element of the array, if present.
    public func lastOrNone() -> Option<A> {
        asArray.last.toOption()
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
        getOrNone(index)
    }
    
    /// Drops the first element of this array.
    ///
    /// - Returns: A new array that contains all elements but the first.
    public func dropFirst() -> ArrayK<A> {
        ArrayK(Array(asArray.dropFirst()))
    }
    
    /// Drops the last element of this array.
    ///
    /// - Returns: A new array that contains all elements but the last.
    public func dropLast() -> ArrayK<A> {
        ArrayK(Array(asArray.dropLast()))
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to ArrayK.
public postfix func ^<A>(_ fa: ArrayKOf<A>) -> ArrayK<A> {
    ArrayK.fix(fa)
}

// MARK: Convenience methods to convert to ArrayK
public extension Array {
    /// Creates an `ArrayK` from this array.
    ///
    /// - Returns: An `ArrayK` wrapping this array.
    func k() -> ArrayK<Element> {
        ArrayK(self)
    }
}

// MARK: Conformance of ArrayK to CustomStringConvertible.
extension ArrayK: CustomStringConvertible {
    public var description: String {
        let contentsString = self.array.map { x in "\(x)" }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

// MARK: Conformance of ArrayK to CustomDebugStringConvertible.
extension ArrayK: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        let contentsString = self.array.map { x in x.debugDescription }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

// MARK: Instance of EquatableK for ArrayK
extension ArrayKPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: ArrayKOf<A>,
        _ rhs: ArrayKOf<A>) -> Bool {
        lhs^.array == rhs^.array
    }
}

// MARK: Instance of Functor for ArrayK
extension ArrayKPartial: Functor {
    public static func map<A, B>(
        _ fa: ArrayKOf<A>,
        _ f: @escaping (A) -> B) -> ArrayKOf<B> {
        ArrayK(fa^.array.map(f))
    }
}

// MARK: Instance of Applicative for ArrayK
extension ArrayKPartial: Applicative {
    public static func pure<A>(_ a: A) -> ArrayKOf<A> {
        ArrayK([a])
    }
}

// MARK: Instance of Selective for ArrayK
extension ArrayKPartial: Selective {}

// MARK: Instance of Monad for ArrayK
extension ArrayKPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: ArrayKOf<A>,
        _ f: @escaping (A) -> ArrayKOf<B>) -> ArrayKOf<B> {
        ArrayK<B>(fa^.array.flatMap { a in f(a)^.array })
    }

    private static func go<A, B>(
        _ buf: [B],
        _ f: @escaping (A) -> ArrayKOf<Either<A, B>>,
        _ v: ArrayK<Either<A, B>>) -> Trampoline<[B]> {
        .defer {
            if !v.isEmpty {
                let head = v.array[0]
                return head.fold(
                    { a in
                        go(buf, f, ArrayK(f(a)^.array + v.array.dropFirst())) },
                    { b in
                        let newBuf = buf + [b]
                        return go(newBuf, f, ArrayK([Either<A, B>](v.array.dropFirst())))
                })
            }
            return .done(buf)
        }
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> ArrayKOf<Either<A, B>>) -> ArrayKOf<B> {
        ArrayK(go([], f, f(a)^).run())
    }
}

// MARK: Instance of `Foldable` for `ArrayK`
extension ArrayKPartial: Foldable {
    public static func foldLeft<A, B>(
        _ fa: ArrayKOf<A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        fa^.array.reduce(b, f)
    }

    public static func foldRight<A, B>(
        _ fa: ArrayKOf<A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ lkw: ArrayK<A>) -> Eval<B> {
            if lkw.array.isEmpty {
                return b
            } else {
                return f(lkw.array[0],
                         Eval.defer { loop(ArrayK([A](lkw.array.dropFirst()))) })
            }
        }
        return Eval.defer({ loop(fa^) })
    }
}

// MARK: Instance of Traverse for ArrayK
extension ArrayKPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: ArrayKOf<A>,
        _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, ArrayKOf<B>> {
        let x = foldRight(fa, Eval.always({ G.pure(ArrayK<B>([])) }),
                          { a, eval in G.map2Eval(f(a), eval, { x, y in ArrayK<B>([x]) + y }) }).value()
        return G.map(x, { a in a as ArrayKOf<B> })
    }
}

// MARK: Instance of SemigroupK for ArrayK
extension ArrayKPartial: SemigroupK {
    public static func combineK<A>(
        _ x: ArrayKOf<A>,
        _ y: ArrayKOf<A>) -> ArrayKOf<A> {
        x^ + y^
    }
}

// MARK: Instance of MonoidK for ArrayK
extension ArrayKPartial: MonoidK {
    public static func emptyK<A>() -> ArrayKOf<A> {
        ArrayK([])
    }
}

// MARK: Instance of FunctorFilter for ArrayK
extension ArrayKPartial: FunctorFilter {}

// MARK: Instance of MonadFilter for ArrayK
extension ArrayKPartial: MonadFilter {
    public static func empty<A>() -> ArrayKOf<A> {
        ArrayK([])
    }
}

// MARK: Instance of MonadCombine for ArrayK
extension ArrayKPartial: MonadCombine {}

// MARK: Instance of Semigroup for ArrayK
extension ArrayK: Semigroup {
    public func combine(_ other: ArrayK<A>) -> ArrayK {
        self + other
    }
}

// MARK: Instance of Monoid for ArrayK
extension ArrayK: Monoid {
    public static func empty() -> ArrayK {
        ArrayK([])
    }
}

import Foundation

/// Witness for the `NonEmptyArray<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForNonEmptyArray {}

/// Higher Kinded Type alias to improve readability over `Kind<ForNonEmptyArray, A>`.
public typealias NonEmptyArrayOf<A> = Kind<ForNonEmptyArray, A>

/// Abbreviation for `NonEmptyArray`.
public typealias NEA<A> = NonEmptyArray<A>

/// A NonEmptyArray is an array of elements that guarantees to have at least one element.
public final class NonEmptyArray<A>: NonEmptyArrayOf<A> {
    /// First element of the array.
    public let head: A
    /// Elements of the array, excluding the firs one.
    public let tail: [A]

    /// Concatenates two non-empty arrays.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the concatenation.
    ///   - rhs: Right hand side of the concatenation.
    /// - Returns: A non-empty array that contains the elements of the two arguments in the same order.
    public static func +(lhs: NonEmptyArray<A>, rhs: NonEmptyArray<A>) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }

    /// Concatenates a non-empty array with a Swift array.
    ///
    /// - Parameters:
    ///   - lhs: A non-empty array.
    ///   - rhs: A Swift array.
    /// - Returns: A non-empty array that contains the elements of the two arguments in the same order.
    public static func +(lhs: NonEmptyArray<A>, rhs: [A]) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + rhs)
    }

    /// Appends an element to a non-empty array.
    ///
    /// - Parameters:
    ///   - lhs: A non-empty array.
    ///   - rhs: An element.
    /// - Returns: A non-empty array that has the new element at the end.
    public static func +(lhs: NonEmptyArray<A>, rhs: A) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + [rhs])
    }

    /// Creates a non-empty array from several values.
    ///
    /// - Parameters:
    ///   - head: First element for the non-empty array.
    ///   - tail: Variable number of values for the rest of the non-empty array.
    /// - Returns: A non-empty array that contains all elements in the specified order.
    public static func of(_ head: A, _ tail: A...) -> NonEmptyArray<A> {
        return NonEmptyArray(head: head, tail: tail)
    }

    /// Creates a non-empty array from a Swift array.
    ///
    /// - Parameter array: A Swift array.
    /// - Returns: An optional non-empty array with the contents of the argument, or `Option.none` if it was empty.
    public static func fromArray(_ array: [A]) -> Option<NonEmptyArray<A>> {
        return array.isEmpty ? Option<NonEmptyArray<A>>.none() : Option<NonEmptyArray<A>>.some(NonEmptyArray(all: array))
    }

    /// Unsafely creates a non-empty array from a Swift array.
    ///
    /// This function may cause a fatal error if the argument is an empty error.
    ///
    /// - Parameter array: A Swift array.
    /// - Returns: A non-empty array with the contents of the argument.
    public static func fromArrayUnsafe(_ array: [A]) -> NonEmptyArray<A> {
        return NonEmptyArray(all: array)
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value cast to NonEmptyArray.
    public static func fix(_ fa: NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
        return fa as! NonEmptyArray<A>
    }

    /// Initializes a non-empty array.
    ///
    /// - Parameters:
    ///   - head: First element for the array.
    ///   - tail: An array with the rest of elements.
    public init(head: A, tail: [A]) {
        self.head = head
        self.tail = tail
    }

    private init(all: [A]) {
        self.head = all[0]
        self.tail = [A](all.dropFirst(1))
    }

    /// Obtains a Swift array with the elements in this value.
    ///
    /// - Returns: A Swift array with the elements in this value.
    public func all() -> [A] {
        return [head] + tail
    }

    /// Obtains an element from its position in this non-empty array.
    ///
    /// - Parameter i: Index of the object to obtain.
    /// - Returns: An optional value with the object at the indicated position, if any.
    public func getOrNone(_ i: Int) -> Option<A> {
        let a = all()
        if i >= 0 && i < a.count {
            return Option<A>.some(a[i])
        } else {
            return Option<A>.none()
        }
    }

    /// Obtains an element from its position in this non-empty array.
    ///
    /// - Parameter index: Index of the object to obtain.
    public subscript(index: Int) -> Option<A> {
        return getOrNone(index)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to NonEmptyArray.
public postfix func ^<A>(_ fa: NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
    return NonEmptyArray.fix(fa)
}

// MARK: Functions for `NonEmptyArray` when the type conforms to `Equatable`
public extension NonEmptyArray where A: Equatable {
    /// Checks if an element appears in this array.
    ///
    /// - Parameter element: Element to look for in the array.
    /// - Returns: Boolean value indicating if the element appears in the array or not.
    func contains(element : A) -> Bool {
        return head == element || tail.contains(where: { $0 == element })
    }

    /// Checks if all the elements of an array appear in this array.
    ///
    /// - Parameter elements: Elements to look for in the array.
    /// - Returns: Boolean value indicating if all elements appear in the array or not.
    func containsAll(elements: [A]) -> Bool {
        return elements.map(contains).reduce(true, and)
    }
}

// Conformance of `NonEmptyArray` to `CustomStringConvertible`
extension NonEmptyArray: CustomStringConvertible {
    public var description: String {
        return "NonEmptyArray(\(self.all()))"
    }
}

// Conformance of `NonEmptyArray` to `CustomDebugStringConvertible`
extension NonEmptyArray: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        let contentsString = self.all().map { x in x.debugDescription }.joined(separator: ", ")
        return "NonEmptyArray(\(contentsString))"
    }
}

// MARK: Instance of `EquatableK` for `NonEmptyArray`
extension ForNonEmptyArray: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForNonEmptyArray, A>, _ rhs: Kind<ForNonEmptyArray, A>) -> Bool where A : Equatable {
        return NEA.fix(lhs).all() == NEA.fix(rhs).all()
    }
}

// MARK: Instance of `Functor` for `NonEmptyArray`
extension ForNonEmptyArray: Functor {
    public static func map<A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ f: @escaping (A) -> B) -> Kind<ForNonEmptyArray, B> {
        return NonEmptyArray.fromArrayUnsafe(NonEmptyArray.fix(fa).all().map(f))
    }
}

// MARK: Instance of `Applicative` for `NonEmptyArray`
extension ForNonEmptyArray: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForNonEmptyArray, A> {
        return NonEmptyArray(head: a, tail: [])
    }
}

// MARK: Instance of `Selective` for `NonEmptyArray`
extension ForNonEmptyArray: Selective {}

// MARK: Instance of `Monad` for `NonEmptyArray`
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

// MARK: Instance of `Comonad` for `NonEmptyArray`
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

// MARK: Instance of `Bimonad` for `NonEmptyArray`
extension ForNonEmptyArray: Bimonad {}

// MARK: Instance of `Foldable` for `NonEmptyArray`
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

// MARK: Instance of `Traverse` for `NonEmptyArray`
extension ForNonEmptyArray: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForNonEmptyArray, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForNonEmptyArray, B>> {
        let nea = NonEmptyArray.fix(fa)
        let arrayTraverse = nea.all().k().traverse(f)
        return G.map(arrayTraverse, { x in NonEmptyArray.fromArrayUnsafe(ArrayK.fix(x).asArray) })
    }
}

// MARK: Instance of `SemigroupK` for `NonEmptyArray`
extension ForNonEmptyArray: SemigroupK {
    public static func combineK<A>(_ x: Kind<ForNonEmptyArray, A>, _ y: Kind<ForNonEmptyArray, A>) -> Kind<ForNonEmptyArray, A> {
        return NonEmptyArray.fix(x) + NonEmptyArray.fix(y)
    }
}

// MARK: Instance of `Semigroup` for `NonEmptyArray`
extension NonEmptyArray: Semigroup {
    public func combine(_ other: NonEmptyArray<A>) -> NonEmptyArray<A> {
        return self + other
    }
}

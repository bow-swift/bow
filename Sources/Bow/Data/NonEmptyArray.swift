import Foundation

/// Witness for the `NonEmptyArray<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForNonEmptyArray {}

/// Partial application of the NonEmptyArray type constructor, omitting the last type parameter.
public typealias NonEmptyArrayPartial = ForNonEmptyArray

/// Higher Kinded Type alias to improve readability over `Kind<ForNonEmptyArray, A>`.
public typealias NonEmptyArrayOf<A> = Kind<ForNonEmptyArray, A>

/// Abbreviation for `NonEmptyArray`.
public typealias NEA<A> = NonEmptyArray<A>

/// Abbrebiation for `NonEmptyArrayPartial`.
public typealias NEAPartial = NonEmptyArrayPartial

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
        NEA(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }

    /// Concatenates a non-empty array with a Swift array.
    ///
    /// - Parameters:
    ///   - lhs: A non-empty array.
    ///   - rhs: A Swift array.
    /// - Returns: A non-empty array that contains the elements of the two arguments in the same order.
    public static func +(lhs: NonEmptyArray<A>, rhs: [A]) -> NonEmptyArray<A> {
        NEA(head: lhs.head, tail: lhs.tail + rhs)
    }

    /// Appends an element to a non-empty array.
    ///
    /// - Parameters:
    ///   - lhs: A non-empty array.
    ///   - rhs: An element.
    /// - Returns: A non-empty array that has the new element at the end.
    public static func +(lhs: NonEmptyArray<A>, rhs: A) -> NonEmptyArray<A> {
        NEA(head: lhs.head, tail: lhs.tail + [rhs])
    }

    /// Creates a non-empty array from several values.
    ///
    /// - Parameters:
    ///   - head: First element for the non-empty array.
    ///   - tail: Variable number of values for the rest of the non-empty array.
    /// - Returns: A non-empty array that contains all elements in the specified order.
    public static func of(_ head: A, _ tail: A...) -> NonEmptyArray<A> {
        NEA(head: head, tail: tail)
    }

    /// Creates a non-empty array from a Swift array.
    ///
    /// - Parameter array: A Swift array.
    /// - Returns: An optional non-empty array with the contents of the argument, or `Option.none` if it was empty.
    public static func fromArray(_ array: [A]) -> Option<NonEmptyArray<A>> {
        array.isEmpty ? Option.none() : Option.some(NEA(all: array))
    }

    /// Unsafely creates a non-empty array from a Swift array.
    ///
    /// This function may cause a fatal error if the argument is an empty error.
    ///
    /// - Parameter array: A Swift array.
    /// - Returns: A non-empty array with the contents of the argument.
    public static func fromArrayUnsafe(_ array: [A]) -> NonEmptyArray<A> {
        NEA(all: array)
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value cast to NonEmptyArray.
    public static func fix(_ fa: NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
        fa as! NEA<A>
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
        [head] + tail
    }

    /// Obtains an element from its position in this non-empty array.
    ///
    /// - Parameter i: Index of the object to obtain.
    /// - Returns: An optional value with the object at the indicated position, if any.
    public func getOrNone(_ i: Int) -> Option<A> {
        let a = all()
        if i >= 0 && i < a.count {
            return .some(a[i])
        } else {
            return .none()
        }
    }

    /// Obtains an element from its position in this non-empty array.
    ///
    /// - Parameter index: Index of the object to obtain.
    public subscript(index: Int) -> Option<A> {
        getOrNone(index)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to NonEmptyArray.
public postfix func ^<A>(_ fa: NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
    NonEmptyArray.fix(fa)
}

public extension NonEmptyArray where A: Equatable {
    /// Checks if an element appears in this array.
    ///
    /// - Parameter element: Element to look for in the array.
    /// - Returns: Boolean value indicating if the element appears in the array or not.
    func contains(element: A) -> Bool {
        head == element || tail.contains(where: { $0 == element })
    }

    /// Checks if all the elements of an array appear in this array.
    ///
    /// - Parameter elements: Elements to look for in the array.
    /// - Returns: Boolean value indicating if all elements appear in the array or not.
    func containsAll(elements: [A]) -> Bool {
        elements.map(contains).reduce(true, and)
    }
}

// MARK: Conformance of NonEmptyArray to CustomStringConvertible
extension NonEmptyArray: CustomStringConvertible {
    public var description: String {
        "NonEmptyArray(\(self.all()))"
    }
}

// MARK: Conformance of NonEmptyArray to CustomDebugStringConvertible
extension NonEmptyArray: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        let contentsString = self.all().map { x in x.debugDescription }.joined(separator: ", ")
        return "NonEmptyArray(\(contentsString))"
    }
}

// MARK: Instance of EquatableK for NonEmptyArray
extension NonEmptyArrayPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: NonEmptyArrayOf<A>,
        _ rhs: NonEmptyArrayOf<A>) -> Bool {
        lhs^.all() == rhs^.all()
    }
}

// MARK: Instance of Functor for NonEmptyArray
extension NonEmptyArrayPartial: Functor {
    public static func map<A, B>(
        _ fa: NonEmptyArrayOf<A>,
        _ f: @escaping (A) -> B) -> NonEmptyArrayOf<B> {
        NEA.fromArrayUnsafe(fa^.all().map(f))
    }
}

// MARK: Instance of Applicative for NonEmptyArray
extension NonEmptyArrayPartial: Applicative {
    public static func pure<A>(_ a: A) -> NonEmptyArrayOf<A> {
        NEA(head: a, tail: [])
    }
}

// MARK: Instance of Selective for NonEmptyArray
extension NonEmptyArrayPartial: Selective {}

// MARK: Instance of Monad for NonEmptyArray
extension NonEmptyArrayPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: NonEmptyArrayOf<A>,
        _ f: @escaping (A) -> NonEmptyArrayOf<B>) -> NonEmptyArrayOf<B> {
        f(fa^.head)^ + fa^.tail.flatMap{ a in f(a)^.all() }
    }

    private static func go<A, B>(
        _ buf: [B],
        _ f: @escaping (A) -> NonEmptyArrayOf<Either<A, B>>,
        _ v: NonEmptyArray<Either<A, B>>) -> Trampoline<[B]> {
        .defer {
            let head = v.head
            return head.fold({ a in go(buf, f, NonEmptyArray.fix(f(a)) + v.tail) },
                             { b in
                                let newBuf = buf + [b]
                                let x = NEA<Either<A, B>>.fromArray(v.tail)
                                return x.fold({ .done(newBuf) },
                                              { value in go(newBuf, f, value) })
            })
        }
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> NonEmptyArrayOf<Either<A, B>>) -> NonEmptyArrayOf<B> {
        NEA.fromArrayUnsafe(go([], f, f(a)^).run())
    }
}

// MARK: Instance of Comonad for NonEmptyArray
extension NonEmptyArrayPartial: Comonad {
    public static func coflatMap<A, B>(_ fa: NonEmptyArrayOf<A>, _ f: @escaping (NonEmptyArrayOf<A>) -> B) -> NonEmptyArrayOf<B> {
        func consume(_ array: [A], _ buf: [B] = []) -> [B] {
            if array.isEmpty {
                return buf
            } else {
                let tail = [A](array.dropFirst())
                let newBuf = buf + [f(NonEmptyArray(head: array[0], tail: tail))]
                return consume(tail, newBuf)
            }
        }
        return NEA(head: f(fa^), tail: consume(fa^.tail))
    }

    public static func extract<A>(_ fa: NonEmptyArrayOf<A>) -> A {
        fa^.head
    }
}

// MARK: Instance of Bimonad for NonEmptyArray
extension NonEmptyArrayPartial: Bimonad {}

// MARK: Instance of Foldable for NonEmptyArray
extension NonEmptyArrayPartial: Foldable {
    public static func foldLeft<A, B>(
        _ fa: NonEmptyArrayOf<A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        fa^.tail.reduce(f(b, fa^.head), f)
    }

    public static func foldRight<A, B>(
        _ fa: NonEmptyArrayOf<A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.all().k().foldRight(b, f)
    }
}

// MARK: Instance of Traverse for NonEmptyArray
extension NonEmptyArrayPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: NonEmptyArrayOf<A>,
        _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, NonEmptyArrayOf<B>> {
        let arrayTraverse = fa^.all().k().traverse(f)
        return G.map(arrayTraverse, { x in NEA.fromArrayUnsafe(x^.asArray) })
    }
}

public extension NEA {
    func traverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, NEA<B>> {
        ForNonEmptyArray.traverse(self, f).map { $0^ }
    }
}

// MARK: Instance of SemigroupK for NonEmptyArray
extension NonEmptyArrayPartial: SemigroupK {
    public static func combineK<A>(
        _ x: NonEmptyArrayOf<A>,
        _ y: NonEmptyArrayOf<A>) -> NonEmptyArrayOf<A> {
        x^ + y^
    }
}

// MARK: Instance of Semigroup for NonEmptyArray
extension NonEmptyArray: Semigroup {
    public func combine(_ other: NonEmptyArray<A>) -> NonEmptyArray<A> {
        self + other
    }
}

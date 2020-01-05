import Foundation

public final class ForZipArray {}

public typealias ZipArrayOf<A> = Kind<ForZipArray, A>

public final class ZipArray<A>: ZipArrayOf<A> {
    internal indirect enum Data: Semigroup {
        case finite([A])
        case infinite(NonEmptyArray<A>)

        var isFinite: Bool {
            if case .finite = self {
                return true
            }
            return false
        }

        func combine(_ other: ZipArray<A>.Data) -> ZipArray<A>.Data {
            switch (self, other) {
            case (.infinite, _):
                return self
            case let (.finite(lhs), .finite(rhs)):
                return .finite(lhs + rhs)
            case let (.finite(lhs), .infinite(rhs)):
                return .infinite(lhs + rhs)
            }
        }

        var asSequence: LazySequence<AnySequence<A>> {
            switch self {
            case let .finite(array):
                return AnySequence(array).lazy
            case let .infinite(array):
                return AnySequence([
                    AnySequence(array.all()),
                    AnySequence(Swift.sequence(first: array.last, next: { _ in array.last}))
                ].joined()).lazy
            }
        }

        var description: String {
            switch self {
            case let .finite(array):
                return array.description
            case let .infinite(array):
                return array.description + ", \(array.last), ..."
            }
        }

        func map<B>(_ f: @escaping (A) -> B) -> ZipArray<B>.Data {
            switch self {
            case let .finite(array):
                return .finite(array.map(f))
            case let .infinite(array):
                return .infinite(array.map(f)^)
            }
        }

        func ap<B>(_ ff: ZipArray<(A) -> B>.Data) -> ZipArray<B>.Data {

            func extend<T>(array: NonEmptyArray<T>, with t: T, untilLength length: Int64) -> NonEmptyArray<T> {
                let nExtraElements = Int(length - array.count)
                guard nExtraElements > 0 else { return array }
                return array + Array(repeating: t, count: nExtraElements)
            }

            switch (self, ff) {
            case let (.finite(arrayA), .finite(arrayF)):
                return .finite(Swift.zip(arrayA, arrayF).map(|>))

            case let (.finite(arrayA), .infinite(arrayF)):
                let result = Swift.zip(
                    arrayA,
                    extend(array: arrayF, with: arrayF.last, untilLength: Int64(arrayA.count)).all()
                ).map(|>)
                return ZipArray<B>.Data.finite(result)

            case let (.infinite(arrayA), .finite(arrayF)):
                return .finite(Swift.zip(
                    extend(array: arrayA, with: arrayA.last, untilLength: Int64(arrayF.count)).all(),
                    arrayF
                ).map(|>))

            case let (.infinite(arrayA), .infinite(arrayF)):
                return .infinite(NonEmptyArray.fromArrayUnsafe(Swift.zip(
                    extend(array: arrayA, with: arrayA.last, untilLength: arrayF.count).all(),
                    extend(array: arrayF, with: arrayF.last, untilLength: arrayA.count).all()
                ).map(|>))^)
            }
        }

        public func foldLeft<B>(_ b: B, _ f: @escaping (B, A) -> B) -> B? {
            switch self {
            case .finite(let array):
                return ArrayK(array).foldLeft(b, f)
            case .infinite:
                return nil
            }
        }

        public func foldRight<B>(_ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B>? {
            switch self {
            case .finite(let array):
                return ArrayK(array).foldRight(b, f)
            default:
                return nil
            }
        }
    }

    internal var data: Data

    internal init(_ data: Data) {
        self.data = data
    }

    /// Concatenates two ZipArrays
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the concatenation.
    ///   - rhs: Right hand side of the concatenation.
    /// - Returns: A ZipArray that contains the elements of the two ZipArrays in the order they appear in the original ones.
    public static func +(lhs: ZipArray<A>, rhs: ZipArray<A>) -> ZipArray<A> {
        return ZipArray(lhs.data.combine(rhs.data))
    }

    /// Prepends an element to a ZipArray.
    ///
    /// - Parameters:
    ///   - lhs: Element to prepend.
    ///   - rhs: Array.
    /// - Returns: A ZipArray containing the prepended element at the head and the other ZipArray as the tail.
    public static func +(lhs: A, rhs: ZipArray<A>) -> ZipArray<A> {
        return ZipArray(lhs) + rhs
    }

    /// Appends an element to a ZipArray.
    ///
    /// - Parameters:
    ///   - lhs: Array.
    ///   - rhs: Element to append.
    /// - Returns: A ZipArrays containing all elements of the first ZipArrays and the appended element as the last element.
    public static func +(lhs: ZipArray<A>, rhs: A) -> ZipArray<A> {
        return lhs + ZipArray(rhs)
    }

    /// Initializes a `ZipArray`.
    ///
    /// - Parameter array: A Swift array of values.
    public convenience init(_ array: [A]) {
        self.init(.finite(array))
    }

    /// Initializes a `ZipArray`.
    ///
    /// - Parameter arrayk: An array of values.
    public convenience init(_ arrayk: ArrayKOf<A>) {
        self.init(arrayk^.asArray)
    }

    /// Initializes a `ZipArray`.
    ///
    /// - Parameter values: A variable number of values.
    public convenience init(_ values: A...) {
        self.init(values)
    }

    /// Obtains the wrapped sequence.
    ///
    /// This sequence needs to be lazy because it can be an infinite sequence.
    public var asSequence: LazySequence<AnySequence<A>> {
        data.asSequence
    }

    /// Obtains the wrapped sequence converted into an Array if the sequence is finite.
    public var asArrayK: ArrayK<A>? {
        switch data {
        case .finite(let array):
            return ArrayK(array)
        case .infinite:
            return nil
        }
    }

    public static func fix(_ fa: ZipArrayOf<A>) -> ZipArray<A> {
        fa as! ZipArray<A>
    }
}

extension ZipArray: CustomStringConvertible {
    public var description: String {
        return data.description
    }
}

public postfix func ^<A>(_ fa: ZipArrayOf<A>) -> ZipArray<A> {
    ZipArray.fix(fa)
}

// MARK: Instance of `EquatableK` for `ZipArray`
extension ForZipArray: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForZipArray, A>, _ rhs: Kind<ForZipArray, A>) -> Bool where A : Equatable {
        switch (lhs^.data, rhs^.data) {
        case let (.finite(l), .finite(r)):
            return l == r
        case (.finite, .infinite), (.infinite, .finite):
            return false
        case let (.infinite(l), .infinite(r)):
            return l == r
        }
    }
}

// MARK: Instance of `MonoidK` for `ZipArray`
extension ForZipArray: MonoidK {
    public static func emptyK<A>() -> Kind<ForZipArray, A> {
        return ZipArray([])
    }

    public static func combineK<A>(_ x: Kind<ForZipArray, A>, _ y: Kind<ForZipArray, A>) -> Kind<ForZipArray, A> {
        return ZipArray(x^.data.combine(y^.data))
    }
}

// MARK: Instance of `Functor` for `ZipArray`
extension ForZipArray: Functor {
    public static func map<A, B>(_ fa: Kind<ForZipArray, A>, _ f: @escaping (A) -> B) -> Kind<ForZipArray, B> {
        return ZipArray(fa^.data.map(f))
    }
}

// MARK: Instance of `Applicative` for `ZipArray`
extension ForZipArray: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForZipArray, A> {
        ZipArray(.infinite(NonEmptyArray(head: a, tail: [])))
    }

    public static func ap<A, B>(_ ff: Kind<ForZipArray, (A) -> B>, _ fa: Kind<ForZipArray, A>) -> Kind<ForZipArray, B> {
        ZipArray(fa^.data.ap(ff^.data))
    }
}


/// Witness for the `Zipper<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForZipper {}

/// Partial application of the Zipper type constructor, omitting the last type parameter.
public typealias ZipperPartial = ForZipper

/// Higher Kinded Type alias to improve readability over `Kind<ForZipper, A>`
public typealias ZipperOf<A> = Kind<ForZipper, A>

/// A Zipper is an array of elements focused on a specific element, which lets us move the focus around the array, and retrieve the elements to the left and right of the focus.
public final class Zipper<A>: ZipperOf<A> {
    public let left: [A]
    public let focus: A
    public let right: [A]
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to Zipper.
    public static func fix(_ value: ZipperOf<A>) -> Zipper<A> {
        value as! Zipper<A>
    }
    
    /// Initializes a Zipper.
    ///
    /// - Parameters:
    ///   - left: Elements to the left of the focus.
    ///   - focus: Focused element.
    ///   - right: Elements to the right of the focus.
    public init(left: [A], focus: A, right: [A]) {
        self.left = left
        self.focus = focus
        self.right = right
    }
    
    /// Initializes a Zipper from a NonEmptyArray, focused on the head of the array.
    ///
    /// - Parameter array: NonEmptyArray to initialize the Zipper.
    public init(fromNEA array: NonEmptyArray<A>) {
        self.left = []
        self.focus = array.head
        self.right = array.tail
    }
    
    /// Initializes a Zipper form an Array, focused on the head of the array. If the array is empty, the result will be nil.
    ///
    /// - Parameter array: Array to initialize the Zipper.
    public convenience init?(fromArray array: [A]) {
        guard !array.isEmpty else {
            return nil
        }
        self.init(left: [],
                  focus: array[0],
                  right: Array(array[1...]))
    }
    
    /// Moves the focus one step to the left. If it is already in the leftmost position, it does nothing.
    ///
    /// - Returns: A Zipper that is focused on one element to the left of the current focus.
    public func moveLeft() -> Zipper<A> {
        guard !left.isEmpty else {
            return self
        }
        
        return Zipper(left: Array(left[0 ..< left.count - 1]),
                      focus: left.last!,
                      right: [focus] + right)
    }
    
    /// Moves the focus one step to the right. If it is already in the rightmost position, it does nothing.
    ///
    /// - Returns: A Zipper that is focused on one element to the right of the current focus.
    public func moveRight() -> Zipper<A> {
        guard !right.isEmpty else {
            return self
        }
        
        return Zipper(left: left + [focus],
                      focus: right[0],
                      right: Array(right[1...]))
    }
    
    /// Moves the focus to the leftmost position.
    ///
    /// - Returns: A Zipper that is focused on the leftmost position.
    public func moveToFirst() -> Zipper<A> {
        if isBeginning() {
            return self
        } else {
            return self.moveLeft().moveToFirst()
        }
    }
    
    /// Moves the focus to the rightmost position.
    ///
    /// - Returns: A Zipper that is focused on the rightmost position.
    public func moveToLast() -> Zipper<A> {
        if isEnding() {
            return self
        } else {
            return self.moveRight().moveToLast()
        }
    }
    
    /// Converts this Zipper to an Array.
    ///
    /// - Returns: An array with the contents of this Zipper.
    public func asArray() -> [A] {
        left + [focus] + right
    }
    
    /// Checks if the focus is at the leftmost position.
    ///
    /// - Returns: True if the focus is at the leftmost position; false, otherwise.
    public func isBeginning() -> Bool {
        left.isEmpty
    }
    
    /// Checks if the focus is at the rightmost position.
    ///
    /// - Returns: True if the focus is at the rightmost position; false, otherwise.
    public func isEnding() -> Bool {
        right.isEmpty
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in the higher-kind form.
/// - Returns: Value cast to Zipper.
public postfix func ^<A>(_ value: ZipperOf<A>) -> Zipper<A> {
    Zipper.fix(value)
}

// MARK: Conformance of Zipper to CustomStringConvertible

extension Zipper: CustomStringConvertible where A: CustomStringConvertible {
    public var description: String {
        "Zipper(left: \(left), focus: \(focus), right: \(right))"
    }
}

// MARK: Instance of EquatableK for Zipper

extension ZipperPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: ZipperOf<A>,
        _ rhs: ZipperOf<A>) -> Bool {
        lhs^.left == rhs^.left &&
            lhs^.focus == rhs^.focus &&
            lhs^.right == rhs^.right
    }
}

// MARK: Instance of Invariant for Zipper

extension ZipperPartial: Invariant {}

// MARK: Instance of Functor for Zipper

extension ZipperPartial: Functor {
    public static func map<A, B>(
        _ fa: ZipperOf<A>,
        _ f: @escaping (A) -> B) -> ZipperOf<B> {
        Zipper(left: fa^.left.map(f),
               focus: f(fa^.focus),
               right: fa^.right.map(f))
    }
}

// MARK: Instance of Comonad for Zipper

extension ZipperPartial: Comonad {
    public static func coflatMap<A, B>(
        _ fa: ZipperOf<A>,
        _ f: @escaping (ZipperOf<A>) -> B) -> ZipperOf<B> {
        let array = fa^.asArray()
        let newLeft: [B] = fa^.left.enumerated().map { item in
            let l = Array(array[0 ..< item.offset])
            let focus = array[item.offset]
            let r = Array(array[(item.offset + 1)...])
            
            return f(Zipper(left: l,
                            focus: focus,
                            right: r))
        }
        let newFocus: B = f(fa)
        let leftCount = fa^.left.count + 1
        let newRight: [B] = fa^.right.enumerated().map { item in
            let l = Array(array[0 ..< item.offset + leftCount])
            let focus = array[item.offset + leftCount]
            let r = Array(array[(item.offset + 1 + leftCount)...])
            
            return f(Zipper(left: l,
                            focus: focus,
                            right: r))
        }
        return Zipper(left: newLeft,
                      focus: newFocus,
                      right: newRight)
    }
    
    public static func extract<A>(_ fa: ZipperOf<A>) -> A {
        fa^.focus
    }
}

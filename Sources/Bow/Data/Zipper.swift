public final class ForZipper {}
public typealias ZipperOf<A> = Kind<ForZipper, A>

public final class Zipper<A>: ZipperOf<A> {
    fileprivate let left: [A]
    fileprivate let focus: A
    fileprivate let right: [A]
    
    public static func fix(_ value: ZipperOf<A>) -> Zipper<A> {
        value as! Zipper<A>
    }
    
    public init(left: [A], focus: A, right: [A]) {
        self.left = left
        self.focus = focus
        self.right = right
    }
    
    public init(fromNEA array: NonEmptyArray<A>) {
        self.left = []
        self.focus = array.head
        self.right = array.tail
    }
    
    public convenience init?(fromArray array: [A]) {
        guard !array.isEmpty else {
            return nil
        }
        self.init(left: [], focus: array[0], right: Array(array[1...]))
    }
    
    public func moveLeft() -> Zipper<A>? {
        guard !left.isEmpty else {
            return nil
        }
        
        return Zipper(left: Array(left[0 ..< left.count - 1]),
                      focus: left.last!,
                      right: [focus] + right)
    }
    
    public func moveRight() -> Zipper<A>? {
        guard !right.isEmpty else {
            return nil
        }
        
        return Zipper(left: left + [focus],
                      focus: right[0],
                      right: Array(right[1...]))
    }
    
    public func asArray() -> [A] {
        left + [focus] + right
    }
    
    public func isBeginning() -> Bool {
        left.isEmpty
    }
    
    public func isEnding() -> Bool {
        right.isEmpty
    }
}

public postfix func ^<A>(_ value: ZipperOf<A>) -> Zipper<A> {
    Zipper.fix(value)
}

extension ForZipper: EquatableK {
    public static func eq<A: Equatable>(_ lhs: ZipperOf<A>, _ rhs: ZipperOf<A>) -> Bool {
        lhs^.left == rhs^.left &&
            lhs^.focus == rhs^.focus &&
            lhs^.right == rhs^.right
    }
}

// MARK: Instance of `Invariant` for `Zipper`

extension ForZipper: Invariant {}

// MARK: Instance of `Functor` for `Zipper`

extension ForZipper: Functor {
    public static func map<A, B>(_ fa: ZipperOf<A>, _ f: @escaping (A) -> B) -> ZipperOf<B> {
        Zipper(left: fa^.left.map(f), focus: f(fa^.focus), right: fa^.right.map(f))
    }
}

// MARK: Instance of `Comonad` for `Zipper`

extension ForZipper: Comonad {
    public static func coflatMap<A, B>(_ fa: ZipperOf<A>, _ f: @escaping (ZipperOf<A>) -> B) -> ZipperOf<B> {
        let array = fa^.asArray()
        let newLeft: [B] = fa^.left.enumerated().map { item in
            let l = Array(array[0 ..< item.offset])
            let focus = array[item.offset]
            let r = Array(array[(item.offset + 1)...])
            return f(Zipper(left: l, focus: focus, right: r))
        }
        let newFocus: B = f(fa)
        let leftCount = fa^.left.count + 1
        let newRight: [B] = fa^.right.enumerated().map { item in
            let l = Array(array[leftCount ..< item.offset + leftCount])
            let focus = array[item.offset + leftCount]
            let r = Array(array[(item.offset + 1 + leftCount)...])
            return f(Zipper(left: l, focus: focus, right: r))
        }
        return Zipper(left: newLeft, focus: newFocus, right: newRight)
    }
    
    public static func extract<A>(_ fa: ZipperOf<A>) -> A {
        fa^.focus
    }
}

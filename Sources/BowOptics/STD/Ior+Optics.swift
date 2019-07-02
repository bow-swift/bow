import Bow

// MARK: Optics extensions
public extension Ior {
    /// Provides a prism focused on the left side of this Ior.
    static var leftPrism: Prism<Ior<A, B>, A> {
        return Prism(
            getOrModify: { ior in ior.fold(
                Either.right,
                { b in Either.left(.right(b)) },
                { a, b in Either.left(.both(a, b)) })
            },
            reverseGet: Ior.left)
    }
    
    /// Provides a prism focused on the right side of this Ior.
    static var rightPrism: Prism<Ior<A, B>, B> {
        return Prism(
            getOrModify: { ior in ior.fold(
                { a in Either.left(.left(a)) },
                Either.right,
                { a, b in Either.left(.both(a, b)) })
            },
            reverseGet: Ior.right)
    }
    
    /// Provides a prism focused on the both side of this Ior.
    static var bothPrism: Prism<Ior<A, B>, (A, B)> {
        return Prism(
            getOrModify: { ior in ior.fold(
                { a in Either.left(.left(a)) },
                { b in Either.left(.right(b)) },
                { a, b in Either.right((a, b)) })
            },
            reverseGet: { x in Ior.both(x.0, x.1) })
    }
}

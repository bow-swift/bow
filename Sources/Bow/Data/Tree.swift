import Foundation

/// Witness for the `Tree<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForTree {}

/// Partial application of the Tree type constructor, omitting the last type parameter.
public typealias TreePartial = ForTree

/// Higher Kinded Type alias to improve readability over `Kind<ForTree, A>`.
public typealias TreeOf<A> = Kind<ForTree, A>

/// `Tree` represents a non-empty tree that allows node to have an arbitrary number of children.
///
/// The `Foldable` instance walks through the tree in depth-first order.
public final class Tree<A>: TreeOf<A> {
    public let root: A
    public let subForest: [Tree<A>]

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value cast to Tree.
    public static func fix(_ fa: TreeOf<A>) -> Tree<A> {
        fa as! Tree<A>
    }

    /// Initializes a tree.
    ///
    /// - Parameters:
    ///   - head: First element for the array.
    ///   - tail: An array with the rest of elements.
    public init(root: A, subForest: [Tree<A>]) {
        self.root = root
        self.subForest = subForest
    }

    /// Adds a tree as a subtree of `self`.
    ///
    /// The root of `tree` will be place directly under the root of `self`.
    ///
    /// - Parameter tree: The tree to add under `self.root`.
    /// - Returns: A tree with the same elements as self with `tree` added as subtree.
    public func appendSubTree(_ tree: Tree<A>) -> Tree<A> {
        appendSubForest([tree])
    }

    /// Adds a collection of trees as subtrees of `self`.
    ///
    /// The root of each subtree will be place directly under the root of `self`.
    ///
    /// - Parameter subForest: A collection of trees to add under `self.root`
    /// - Returns: A tree with the same elements as self with the trees of `subForest` added as subtrees.
    public func appendSubForest(_ subForest: [Tree<A>]) -> Tree<A> {
        Tree(root: root, subForest: self.subForest + subForest)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Tree.
public postfix func ^<A>(_ fa: TreeOf<A>) -> Tree<A> {
    Tree.fix(fa)
}

// MARK: Instance of EquatableK for Tree
extension TreePartial: EquatableK {
    public static func eq<A>(_ lhs: TreeOf<A>, _ rhs: TreeOf<A>) -> Bool where A : Equatable {
        lhs^.root == rhs^.root && lhs^.subForest == rhs^.subForest
    }
}

// MARK: Instance of Functor for Tree
extension TreePartial: Functor {
    public static func map<A, B>(
        _ fa: TreeOf<A>,
        _ f: @escaping (A) -> B) -> TreeOf<B> {
        Tree(root: f(fa^.root),
            subForest: fa^.subForest.map { TreePartial.map($0, f)^ })
    }
}

// MARK: Instance of Applicative for Tree
extension TreePartial: Applicative {
    public static func pure<A>(_ a: A) -> TreeOf<A> {
        Tree(root: a, subForest: [])
    }

    public static func ap<A, B>(_ functionTree: TreeOf<(A) -> B>, _ elementsTree: TreeOf<A>) -> TreeOf<B> {
        let functionTree = functionTree^
        let elementsTree = elementsTree^
        return Tree(root: functionTree.root(elementsTree.root),
                    subForest: elementsTree.subForest.map { TreePartial.map($0, functionTree.root)^ }
                        + functionTree.subForest.map { TreePartial.ap($0, elementsTree)^ })
    }
}

// MARK: Instance of Selective for Tree
extension TreePartial: Selective {}

// MARK: Instance of Monad for Tree
extension TreePartial: Monad {
    public static func flatMap<A, B>(_ fa: TreeOf<A>, _ f: @escaping (A) -> TreeOf<B>) -> TreeOf<B> {
        f(fa^.root)^.appendSubForest(
            fa^.subForest.map { TreePartial.flatMap($0, f)^ }
        )
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> TreeOf<Either<A, B>>) -> TreeOf<B> {
        let f = { f($0)^ }
        return loop(f(a), f).run()
    }

    private static func loop<A, B>(_ a: TreeOf<Either<A, B>>, _ f: @escaping (A) -> TreeOf<Either<A, B>>) -> Trampoline<TreeOf<B>> {
        .defer {
            let fLiftedToEither: (Either<A, B>) -> Trampoline<TreeOf<B>> = { e in
                e.fold({ a in
                    loop(f(a), f)
                }) { b in
                    .done(.pure(b))
                }
            }
            let rootImageTrampoline = fLiftedToEither(a^.root)
            let subForestImageTrampoline = a^.subForest.traverse { loop($0, f) }^

            return .map(rootImageTrampoline, subForestImageTrampoline) { (rootImage, subForestImage) in
                rootImage^.appendSubForest(subForestImage.map { $0^ })
            }^
        }
    }
}

// MARK: Instance of Foldable for Tree
extension TreePartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForTree, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        fa^.subForest.foldLeft(f(b, fa^.root)) { (bPartial, tree) in
            foldLeft(tree, bPartial, f)
        }
    }

    public static func foldRight<A, B>(_ fa: Kind<ForTree, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.subForest.foldRight(f(fa^.root, b)) { (tree, bPartial) -> Eval<B> in
            foldRight(tree, bPartial, f)
        }
    }
}

// MARK: Instance of Traverse for Tree
extension TreePartial: Traverse {
    public static func traverse<G, A, B>(_ fa: TreeOf<A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, TreeOf<B>> where G : Applicative {
        let liftedRoot = f(fa^.root)
        let liftedSubForest = fa^.subForest.traverse { t in t.traverse(f).map { $0^ } }
        return G.map(liftedRoot, liftedSubForest, Tree.init)
    }
}

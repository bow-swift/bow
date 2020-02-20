---
layout: docs
title: Composition
permalink: /docs/optics/composition/
---

# Composition
 
 {:.beginner}
 beginner
 
 Optics can compose to create more powerful optics and access deeply nested data structures in an seamless manner. The result of the composition of the 8 pairs of optics that are included in Bow is shown in the following table. Notice that not all combinations are possible for composition, and that some times the resulting optic is not the same as the optics that were composed.
 
 |               | **Iso**   | **Lens**  | **Prism** | **Optional** | **Getter** | **Setter** | **Fold** | **Traversal** |
 | ------------- | --------- | --------- | --------- | ------------ | ---------- | ---------- | -------- | ------------- |
 | **Iso**       | Iso       | Lens      | Prism     | Optional     | Getter     | Setter     | Fold     | Traversal     |
 | **Lens**      | Lens      | Lens      | Optional  | Optional     | Getter     | Setter     | Fold     | Traversal     |
 | **Prism**     | Prism     | Optional  | Prism     | Optional     | 🚫         | Setter     | Fold     | Traversal     |
 | **Optional**  | Optional  | Optional  | Optional  | Optional     | Fold       | Setter     | Fold     | Traversal     |
 | **Getter**    | Getter    | Getter    | 🚫        | 🚫           | Getter     | 🚫         | Fold     | 🚫            |
 | **Setter**    | Setter    | Setter    | Setter    | Setter       | 🚫         | Setter     | 🚫       | Setter        |
 | **Fold**      | Fold      | Fold      | Fold      | Fold         | Fold       | 🚫         | Fold     | Fold          |
 | **Traversal** | Traversal | Traversal | Traversal | Traversal    | Fold       | Setter     | Fold     | Traversal     |
 
 Each optic can be composed using its instance method `compose`, which is overloaded to accept all possible combinations with other optics. Besides, for the sake of simplicity, operator `+` can also be used to compose any two optics.
 
## Example of composition: N-ary Tree
 
 An N-ary tree is a tree where each node can have any number of branches. We can model it like:

```swift
enum NTree<A> {
    case leaf(A)
    indirect case node(A, branches: NEA<NTree<A>>)
}
```

 That is, we can have a leaf with an associated value, or a node with an associated value and a `NonEmptyArray` of branches (it must have at least one, otherwise it would be a leaf).
 
 Let's imagine that we would like to combine all values of the nodes at level `m`. Stop for a moment and think how you would do it without optics. It does not have a trivial solution, right? Let's see if we can leverage the power of optics to do this.
 
 We can start by trying to access the branches of a node. Since `NTree` is a sum type, the optic that we need to use is a Prism. We can use `AutoPrism` to get the `Prism` for the node side of the `NTree`:

```swift
extension NTree: AutoPrism {}

func nodePrism<A>() -> Prism<NTree<A>, (A, NEA<NTree<A>>)> {
    return NTree.prism(for: NTree.node) { tree in
        guard case let .node(value, branches: branches) = tree else { return nil }
        return (value, branches)
    }
}
```

 `nodePrism` gives us a `Prism` to look into a `NTree` and get a pair of `(A, NEA<NTree<A>>)`, but we are only interested in the branches part. Given we have a tuple, we would need an optic that lets us focus on one of the components of a tuple.
 
 Fortunately, Bow already provides these utilities. In particular, given that tuples are product types, it seems we would need a `Lens` to focus on the second component of the tuple. To do so, we can get the `Lens` from `Tuple2._1`. There are utilities like this from `Tuple2` to `Tuple10`, to focus on every component of the tuples.
 
 Then, we can compose the previous `Prism` with this `Lens` to get an `Optional` (see table above) that focuses only on the branches of a node:

```swift
func branchesOptional<A>() -> Optional<NTree<A>, NEA<NTree<A>>> {
    return nodePrism() + Tuple2._1
}
```

 Now, we would like to be able to traverse each individual branch and modify them in isolation. This would give us a way of visiting the branches under the first level of the tree. If we look into the focus of the `branchesOptional` we can see that it is a `NonEmptyArray`, which already has a `Traversal` to visit each element. Therefore, if we compose them, we can get a `Traversal` with foci in each node of the first level under the provided node:

```swift
func levelTraversal<A>() -> Traversal<NTree<A>, NTree<A>> {
    return branchesOptional() + NEA.traversal
}
```

 Looking at `levelTraversal` we can see that its source and focus types match. That means we can compose with itself in order to go further down in the tree structure, level by level. We can write a function that gets us a `Traversal` focused on the nodes of the `m` level, just by composing the `levelTraversal` with itself `m` times:

```swift
func level<A>(_ m: UInt) -> Traversal<NTree<A>, NTree<A>> {
    guard m > 0 else { return Traversal.identity }
    return (0 ..< m)
        .map { _ in levelTraversal() }
        .reduce(Traversal.identity, +)
}
```

 In the function above, if `m` is 0, we return `Traversal.identity`, which is a `Traversal` that focuses on the source itself, corresponding to visiting level 0 of the tree. Otherwise, we create `m` instances of the `levelTraversal` and combine them all into a single one, to get a `Traversal` that focuses on nodes at level `m`.
 
 We wanted to combine values of the nodes at level `m`. First, we would need to extract the values out of the `NTrees`. Since all cases in `NTree` have a value, we can write a custom `Getter` to do this:

```swift
func valueGetter<A>() -> Getter<NTree<A>, A> {
    return Getter(get: { state in
        switch state {
        case .leaf(let value), .node(let value, branches: _): return value
        }
    })
}
```

 We can convert the `Traversal` to a `Fold` using the `asFold` property. We can get a `Fold` to combine values at level `m` as:

```swift
func levelFold<A>(_ m: UInt) -> Fold<NTree<A>, A> {
    return level(m).asFold + valueGetter()
}
```

 Finally, if we get a tree whose values have an instance of `Monoid`, we can combine all its values at level `m` by:

```swift
func combineValues<A: Monoid>(of tree: NTree<A>, at level: UInt) -> A {
    return levelFold(level).combineAll(tree)
}
```

## Summary
 
 With this example we have seen how we can use auto-generated, custom and library-provided optics, to build more complex ones that help us perfom a complicated task in an easy and seamless manner.

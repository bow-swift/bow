---
layout: docs
title: State-based computations
permalink: /docs/patterns/state-based-computations/
---

# State-based computations
 
 {:.beginner}
 beginner
 
 Oftentimes, our programs need to be stateful; that is, we need to maintain an state, perform operations that depend on such state, and even change it as a result of some operations. It usually results in code similar to this:

```swift
var state: ProgramState
    
func operation(input: Input) -> Output {
    let result = doSomething(input: input, state: state)
    state = newState
    return result
}
```

 However, this code has some problems:
 
 1. It is using a hidden argument; it uses `state` under the hood, which makes the function impure, as the function `operation` may return different outputs for the same input.
 
 2. It mutates state, which is a side effect other than computing the result of the function.
 
 3. It is difficult to test the function, as we may not be able to easily set the initial state or check its value after the function execution.
 
## Explicit parameters and return types
 
 The straightforward solution to this problem is to make everything explicit: the function receives the state as a parameter, and returns it when it is mutated.

```swift
func operation(input: Input, state: ProgramState) -> (ProgramState, Output) {
    let result = doSomething(input: input, state: state)
    return (newState, result)
}
```

 The problems mentioned before just disappear as things become explicit. With this version, no side effects are happening when the function is called, and its output only depend on the input. It is easy to test: we can pass the initial state as an argument to the function, and we can assert over the output.
 
 However, it has a new, different problem. Its ergonomics are not very flexible. If we need to perform multiple state-based operations, we need to wire the state manually:

```swift
func operation(input: Input, state: ProgramState) -> (ProgramState, Intermediate) {
    let result = doSomething(input: input, state: state)
    return (newState, result)
}
    
func operation2(input: Intermediate, state: ProgramState) -> (ProgramState, Output) {
    let result = doSomething(input: input, state: state)
    return (newState, result)
}
    
func program(input: Input, state: ProgramState) -> (ProgramState, Output) {
    let (state2, intermediate) = operation(input: input, state: state)
    return operation2(input: intermediate, state: state2)
}
```

 In the function `program` above, we need to get the state from the first `operation` and wire it to the `operation2`, as the state may have changed. If multiple operations are chained, this option becomes harder to apply.
 
## Towards the State type
 
 The problem mentioned above can be mitigated by using the State type, provided in Bow. The functions above can be curried, separating the inputs they need to perform their job, from the state they are based on.

```swift
func operation(input: Input) -> (ProgramState) -> (ProgramState, Output) {
```

```swift
    return { state -> (ProgramState, Output) in
        let result = doSomething(input: input, state: state)
        return (newState, result)
    }
}
```

 And finally, wrap the returning function `(ProgramState) -> (ProgramState, Output)` into `State<ProgramState, Output>`:

```swift
func operation(input: Input) -> State<ProgramState, Output> {
```

```swift
    return State<ProgramState, Output> { state -> (ProgramState, Output) in
        let result = doSomething(input: input, state: state)
        return (newState, result)
    }
}
```

 With this change we achieved better ergonomics, as the state wiring now happens by using the `flatMap` operation:

```swift
static func operation(input: Input) -> State<ProgramState, Intermediate> {
```

```swift
    return State<ProgramState, Intermediate> { state -> (ProgramState, Intermediate) in
        let result = doSomething(input: input, state: state)
        return (newState, result)
    }
}
    
static func operation2(input: Intermediate) -> State<ProgramState, Output> {
```

```swift
    return State<ProgramState, Output> { state -> (ProgramState, Output) in
        let result = doSomething(input: input, state: state)
        return (newState, result)
    }
}
    
static func program(input: Input) -> State<ProgramState, Output> {
    operation(input: input).flatMap { intermediate in
        operation2(input: intermediate)
    }^
}
```

 Or we can use Monad comprehensions to obtain an imperative-like syntax:

```swift
static func program2(input: Input) -> State<ProgramState, Output> {
    let intermediate = State<ProgramState, Intermediate>.var()
    let output = State<ProgramState, Output>.var()
    
    return binding(
        intermediate <- operation(input: input),
        output <- operation2(input: intermediate.get),
        yield: output.get)^
}
```

 Invoking `program` or `program2` will provide a description of the program, but it is not yet executed, as we need to provide an initial state. We can do it with the following functions:

```swift
let description = program(input: myInput)

// Provides both state and output
let (finalState, finalOutput) = description.run(initialState)

// Provides only the output
let finalOutput2 = description.runA(initialState)
    
// Provides only the state
let finalState2 = description.runS(initialState)
```

## An applied example
 
 Let's apply this to an example, taken from *The Craft of Functional Programming*, by Simon Thompson. The problem asks us to transform a tree of arbitrary values into a tree of integers, where nodes are tagged with the same integer value if they contained the same value in the original tree, starting with 0.
 
 That is, we can visit a node; if its content has been seen before, we tag it with the corresponding value; otherwise, we assign it a new tag and increment the next tag.
 
 We can model a binary tree as:

```swift
enum Tree<A> {
    case leaf(A)
    indirect case node(A, left: Tree<A>, right: Tree<A>)
}
```

 Next step is to model our state. We can have a table of the visited nodes, together with their integer task using a Swift Dictionary, and the value for the next tag. This entails the values saved in the original tree need to conform to `Hashable`:

```swift
struct Table<A: Hashable> {
    let tags: [A: Int]
    let nextTag: Int
}
```

 Each time we visit a node or a leaf, we will need to process its value. We will have to get a tag for the value if it has been previously seen, or get a new one, save it into the state and increment the next tag. Therefore, the processing function will take values of an arbitrary type, return values of type `Int`, and do work based on an state of type `Table<A>`:

```swift
func process<A: Hashable>(value: A) -> State<Table<A>, Int> {
    State { table -> (Table<A>, Int) in
        if let tag = table.tags[value] {
            return (table, tag)
        } else {
            let tag = table.nextTag
            var newTags = table.tags
            newTags[value] = tag
            let newNextTag = table.nextTag + 1
            let newTable = Table(tags: newTags, nextTag: newNextTag)
            return (newTable, tag)
        }
    }
}
```

 Then, our state base function needs to receive a tree, visit each of its nodes and produce a tree of integers, depending on an state of type `Table<A>`:

```swift
func number<A: Hashable>(tree: Tree<A>) -> State<Table<A>, Tree<Int>> {
    switch tree {
    // If it is a leaf, we process its value and put it back into a tree leaf.
    case let .leaf(value):
        return process(value: value).map(Tree.leaf)^
    
    // If it is a node, we need to process the value, and the left
    // and right parts of the tree, and then assemble them back
    // into a tree again:
    case let .node(value, left: leftTree, right: rightTree):
        let tag       = State<Table<A>, Int>.var()
        let leftTags  = State<Table<A>, Tree<Int>>.var()
        let rightTags = State<Table<A>, Tree<Int>>.var()
        
        return binding(
            tag       <- process(value: value),
            leftTags  <- number(tree: leftTree),
            rightTags <- number(tree: rightTree),
            
            yield: Tree.node(tag.get,
                             left: leftTags.get,
                             right: rightTags.get))^
    }
}
```

 We can now create a sample tree to run our program with:

```swift
/*
 The following code represents this tree:
 B
 |- A
 |  |- C
 |  \- B
 |
 \- C
    |- D
    |  |- B
    |  \- A
    |
    \- E
 */
let sampleTree: Tree<String> =
    .node("B",
          left: .node("A",
                      left: .leaf("C"),
                      right: .leaf("B")),
          right: .node("C",
                       left: .node("D",
                                   left: .leaf("B"),
                                   right: .leaf("A")),
                       right: .leaf("E")))
```

 Our initial state starts with an empty dictionary and 0 as the next tag:

```swift
let initialState = Table<String>(tags: [:], nextTag: 0)
```

 Then, we can obtain the numbered tree by passing our sample tree to the function, and then running it with the initial state:

```swift
let (finalState, numberedTree) = number(tree: sampleTree).run(initialState)

/*
The numberedTree is:
0
|- 1
|  |- 2
|  \- 0
|
\- 2
   |- 3
   |  |- 0
   |  \- 1
   |
   \- 4
*/
```

 An alternative, but equivalent, way of building the numbering function would be using the `zip` function, as processing the value and the children trees of a node are independent operations:

```swift
func number_v2<A: Hashable>(tree: Tree<A>) -> State<Table<A>, Tree<Int>> {
    switch tree {
    // If it is a leaf, we process its value and put it back into a tree leaf.
    case let .leaf(value):
        return process(value: value).map(Tree.leaf)^
    
    // If it is a node, we need to process the value, and the left
    // and right parts of the tree, and then assemble them back
    // into a tree again:
    case let .node(value, left: leftTree, right: rightTree):
        return State.zip(
            process(value: value),
            number_v2(tree: leftTree),
            number_v2(tree: rightTree)).map(Tree.node)^
    }
}
```

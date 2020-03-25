---
layout: docs
title: RxSwift
permalink: /docs/integrations/rxswift-streams/
---

# RxSwift
 
 {:.beginner}
 beginner
 
 RxSwift is a popular streaming library with counterparts in many other programming languages. It is used for Reactive Functional Programming and counts with many combinators that are already present in Bow.
 
 It provides three data types to model different semantics in streams: `Single`, `Maybe` and `Observable`. However, these types do not have support for HKTs and therefore do not provide instances for the type classes provided in the core module or the effects module.
 
 Bow Rx is a module that we provide to bridge this gap between the abstractions provided by Bow and the widely used RxSwift library. In order to use it, you need to import:

```swift
import BowRx
```

 Bow Rx provides wrappers over the three main data types to add HKT support and provides instances for the type classes in the `Functor` hierarchy. These three data types included in Bow Rx are `SingleK`, `MaybeK` and `ObservableK`.
 
## SingleK
 
 `SingleK<A>` models a stream of exactly one element of type `A`. It can be built by wrapping a `Single` value or using the `k` function:

```swift
let single = Single<Int>.just(1)
let singleK1 = SingleK(single)
let singleK2 = single.k()
```

 You can access the underlying wrapped value in order to subscribe to it:

```swift
singleK1.value.subscribe { x in
    // Do something
}
```

## MaybeK
 
 `MaybeK<A>` models a stream of zero or one elements of type `A`. It can be built by wrapping a `Maybe` value or using the `k` function:

```swift
let maybe = Maybe<Int>.just(1)
let maybeK1 = MaybeK(maybe)
let maybeK2 = maybe.k()
```

 You can access the underlying wrapped value in order to subscribe to it:

```swift
maybeK1.value.subscribe { x in
    // Do something
}
```

## ObservableK
 
 `ObservableK<A>` models a stream of any number of elements of type `A`. It can be built by wrapping an `Observable` value or using the `k` function:

```swift
let observable = Observable<Int>.from([1, 2, 3, 4, 5])
let observableK1 = ObservableK(observable)
let observableK2 = observable.k()
```

 You can access the underlying wrapped value in order to subscribe to it:

```swift
observableK1.value.subscribe { x in
    // Do something
}
```

## Further documentation
 
 You can use `SingleK`, `MaybeK` and `ObservableK` as any other data type in Bow, getting access to the functionality provided by their instances for the type classes in the `Functor` hierarchy, as well as the type classes provided by the Bow Effects module.
 
 For further documentation regarding operations dealing with the underlying wrapped values in these data types, refer to the documentation of [RxSwift](http://reactivex.io/). 

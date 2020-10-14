---
layout: docs
title: Writing your own optics
permalink: /docs/optics/writing-your-own-optics/
---

# Writing your own optics
 
 {:.beginner}
 beginner
 
 In order to work with optics, you need to create them for your specific data type. Consider the following data types:

```swift
enum PublicationState {
    case draft
    case published(Date)
}

struct Article {
    let title: String
    let subtitle: Option<String>
    let state: PublicationState
    let tags: [String]
}
```

 We can also create some sample values to apply our optics to:

```swift
let state = PublicationState.published(Date())
let article = Article(title: "Working with optics in Swift",
                      subtitle: .some("Learn to use BowOptics"),
                      state: .draft,
                      tags: ["fp", "swift", "bow"])
```

 In the following sections, we will describe how to create each of the optics for those types, where they are applicable.
 
## Iso
 
 `Iso<S, A>` represents an isomorphism between types `S` and `A`. That means we can transform from an `S` to an `A` and back to `S` with a pair of functions, and we will get the original value. Similarly, we can start with an `A`, transform it to an `S` and back to an `A` without losing information. This does not mean `S` and `A` are equal, but it implies their structures are equivalent.
 
 An example of an `Iso` can be found in product types. In our running example, `Article` is a product type composed of a `String`, an optional `String`, a `PublicationState` and an `Array` of `String`. But we could also represent the same information using a tuple of 4 elements, and we would be able to get a tuple from an article, and vice versa. That is, we can build an `Iso<Article, (String, Option<String>, PublicationState, [String])>`.
 
 To do so, we need a pair of functions. To go from tuple to `Article`, we can use `Article.init`, since the types in the tuple are already in the same order the initializer expects them. To go from `Article` to tuple we need to destructure the `Article`:

```swift
func toTuple(_ article: Article) -> (String, Option<String>, PublicationState, [String]) {
    return (article.title, article.subtitle, article.state, article.tags)
}
```

 With this function, creating an `Iso` between these types is as easy as:

```swift
let iso = Iso<Article, (String, Option<String>, PublicationState, [String])>(get: toTuple, reverseGet: Article.init)
```

 The `Iso` initializer expects two functions: `get`, to go from `S` to `A`, and `reverseGet` to go from `A` to `S`, which is exactly what our two functions are doing.
 
#### Using Iso
 
 We can transform an article into a tuple with the `iso` we just created:

```swift
iso.get(article) // returns ("Working with optics", .some("Learn to use BowOptics"), .draft, ["fp", "swift", "bow"])
```

 Or we can make an `Article` out of a tuple:

```swift
iso.reverseGet(("FP in Swift", .none(), .draft, [])) // Creates an Article(title: "FP in Swift", subtitle: .none(), state: .draft, tags: [])
```

## Getter
 
 `Getter<S, A>` allows us to get a value `A` out of a structure `S`. For instance, we can make a `Getter` to extract the `title` of an `Article`. In that case, we need to make a `Getter<Article, String>`:

```swift
let titleGetter = Getter<Article, String>(get: { article in article.title })
```

#### Using Getter
 
 As you can guess, we can use a Getter to get a property of a structure. Using the recently created `titleGetter`, we can apply it to our `article`:

```swift
titleGetter.get(article) // Returns "Working with optics in Swift"
```

## Setter
 
 Similarly, a `Setter<S, A>` allows us to set a new value of type `A` or modify the existing one in a structure `S`. Since we are dealing with immutable data structures, that involves making a copy of the structure that changes the focused value. We can add the following method to `Article` in order to get copies with modified fields seamlessly:

```swift
extension Article {
    func copy(withTitle title: String? = nil,
              withSubtitle subtitle: Option<String>? = nil,
              withState state: PublicationState? = nil,
              withTags tags: [String]? = nil) -> Article {
        return Article(title: title ?? self.title,
                       subtitle: subtitle ?? self.subtitle,
                       state: state ?? self.state,
                       tags: tags ?? self.tags)
    }
}
```

 This copy method provides multiple overloads to make a copy of the receiver object and modify only certain fields. If an argument is passed, the copy will have it; otherwise, the current value of the object is taken.
 
 Using this, let's proceed to write a `Setter` for the title of an `Article`. To create a `Setter`, we can pass two closures that specify how an article is modified with a function `f` that modifies its title, and how to set a new title for an article. We can write a `Setter<Article, String>`:

```swift
let titleSetter = Setter<Article, String>(
    modify: { article, f in article.copy(withTitle: f(article.title)) },
    set: { article, newTitle in article.copy(withTitle: newTitle) })
```

#### Using Setter
 
 Similar to Getter, we can use a Setter to set a property in a structure. Using the `titleSetter` created above, we can set a new title for the article we had:

```swift
titleSetter.set(article, "All about Optics") // Returns Article(title: "All about optics", subtitle: .some("Learn to use BowOptics"), state: .draft, tags: ["fp", "swift", "bow"])
```

 It is important to note that the original article remains the same; the Setter creates a copy where all values are the same except the one focused by the Setter.
 
 We don't have to pass a new value; we can also transform the title of the article:

```swift
titleSetter.modify(article, { str in str.uppercased() }) // Returns Article(title: "WORKING WITH OPTICS IN SWIFT", subtitle: .some("Learn to use BowOptics"), state: .draft, tags: ["fp", "swift", "bow"])
```

## Lens
 
 If we combine the power of `Getter` and `Setter` into a single optic, we have a `Lens`. A `Lens<S, A>` is an optic that lets us get, set or modify a value `A` out of a structure `S`.
 
 We can provide a Lens to get/set the title of an `Article` by providing these two functions:

```swift
let titleLens = Lens<Article, String>(
    get: { article in article.title },
    set: { article, newTitle in article.copy(withTitle: newTitle) })
```

#### Using Lens
 
 Using Lens is like using Getter and Setter, in the same optic. You can retrieve and modify the focus of the Lens. Using the Lens we just created:

```swift
// Gets the title
titleLens.get(article)

// Sets a new title
titleLens.set(article, "All about Optics")

// Modifies the existing title
titleLens.modify(article, { str in str.uppercased() })
```

## AffineTraversal
 
 In the previous optics, title is always present in an `Article`. However, if we focus on its subtitle, we can see it is an `Option<String>`. We can still write a `Lens` whose focus is `Option<String>`, but for the sake of composition, it would be better to remove that optionality.
 
 To do so, we can use the `AffineTraversal<S, A>`, which lets us focus on a value `A` that may be absent in a structure `S`, just like the case of the article subtitle. An `AffineTraversal` needs two functions to be initialized. The setter function just needs to make a copy of the article with the new value. The getter function is a bit trickier. It returns an `Either`; if the focus is present in the structure, it returns an `Either.right` containing it; otherwise, it returns an `Either.left` with the original article.

```swift
let subtitleAffineTraversal = AffineTraversal<Article, String>(
    set: { article, newSubtitle in article.copy(withSubtitle: .some(newSubtitle)) },
    getOrModify: { article in article.subtitle.fold({ Either.left(article) }, Either.right) })
```

#### Using AffineTraversal
 
 Using AffineTraversal is quite similar to using a Lens. We can get an Option of the focus or set it to a new value:

```swift
subtitleAffineTraversal.getOption(article) // Returns .some("Learn to use BowOptics")
subtitleAffineTraversal.set(article, "") // Returns Article(title: "Working with optics in Swift", subtitle: .some(""), state: .draft, tags: ["fp", "swift", "bow"])
```

 If we try to modify an article, it will return a new article with the modified subtitle, or the original article if the subtitle was not present.

```swift
let articleWithoutSubtitle = Article(title: "Not interesing", subtitle: .none(), state: .draft, tags: [])
subtitleAffineTraversal.modify(articleWithoutSubtitle, { str in str.lowercased() }) // Returns the same article as it does not have a subtitle
```

## Prism
 
 All the optics above work for product types. When it comes to sum types, we need to use `Prism`. `Prism<S, A>` is an optic that lets us focus on a value `A` that is present under certain circumstances in the structure `S`.
 
 Sum types in Swift are usually represented by `enum`, so focusing on one of the cases does not guarantee that it is always going to be there.
 
 As an example, consider the `PublicationState` described above. If we want to focus on the published side and get the `Date` of publication, we need to create a `Prism<PublicationState, Date>`. As usual, we need two functions. The getter lets us get `Either` the date (`right`, if we received a `PublicationState` that is in the state we are focusing) or the original state (`left`, if we are in another case of the `PublicationState`). The other function lets us build a state from a given `Date`.

```swift
let publishedPrism = Prism<PublicationState, Date>(
    getOrModify: { state in
        guard case let .published(date) = state else {
            return Either.left(state)
        }
        return Either.right(date)
    }, reverseGet: PublicationState.published)
```

#### Using Prism
 
 We can use the Prism above to get the publication date from a state:

```swift
publishedPrism.getOption(state) // Returns an Option with the date that we set when we created it
```

 However, in the case of a `PublishedState.draft`, this Prism cannot get a Date, so it will return an empty Option:

```swift
publishedPrism.getOption(.draft) // Returns .none()
```

## Fold
 
 The optics presented so far have only one focus. Is it possible to have multiple foci? The `Fold` and `Traversal` optics have 0 to n foci.
 
 `Fold` is a generalization of `Foldable`. `Fold<S, A>` describes an optic that can focus on several `A` values in a structure `S` and can transform and fold them into a summary value.
 
 This is usually the case of fields that contain collections of elements and we want to focus on them individually. In the case of `Article`, if we write a `Lens` for the tags, it lets us focus on all tags as a whole, not on each individual tag.

```swift
let tagsLens = Lens<Article, [String]>(
    get: { article in article.tags },
    set: { article, newTags in article.copy(withTags: newTags) })
```

 We can get a `Fold<Article, String>` that lets us have foci to each individual tag. In this case, we can leverage an existing `Fold<[A], A>`; i.e. for any array, it gives us a `Fold` to focus on each item of the array. It is available in `Array<Element>.fold`. With that, we can compose it with the `tagsLens` to get a `Fold`:

```swift
let tagsFold: Fold<Article, String> = tagsLens + Array<String>.fold
```

#### Using Fold
 
 Once we have a Fold, we can use it for different purposes, like counting the number of tags:

```swift
tagsFold.size(article) // Returns 3
```

 Or find a tag with a specific criteria:

```swift
tagsFold.find(article, { tag in tag.count == 2 }) // Returns .some("fp")
```

## Traversal
 
 Finally, `Traversal` is a generalization of `Traverse`. `Traversal<S, A>` lets us focus on multiple `A` values in a structure `S` to get, set or modify them. Like in the case for `Fold`, it is useful for fields that contain collections of elements. Likeways, there is a `Traversal<[A], A>` available for any array in `Array<Element>.traversal`. With that, we can compose it with the `tagsLens` to get a `Traversal`:

```swift
let tagsTraversal: Traversal<Article, String> = tagsLens + Array<String>.traversal
```

#### Using Traversal
 
 The Traversal for tags that we have created lets us modify all of them with a function:

```swift
tagsTraversal.modify(article, { str in str.uppercased() }) // Uppercases all tags
```

 Or check if there is a tag that matches a predicate:

```swift
tagsTraversal.exists(article, { str in str == "advanced" }) // Returns false as the article does not have any "advanced" tag
```

 There are many more operations that are available for each optic that the ones shown in this page. For a complete reference, check the API documentation for each optic.

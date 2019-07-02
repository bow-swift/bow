// nef:begin:header
/*
 layout: docs
 title: Writing your own optics
 */
// nef:end
/*:
 # Writing your own optics
 
 {:.beginner}
 beginner
 
 In order to work with optics, you need to create them for your specific data type. Consider the following data types:
 */
// nef:begin:hidden
import Bow
import BowOptics
// nef:end
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
/*:
 In the following sections, we will describe how to create each of the optics for those types, where they are applicable.
 
 ## Iso
 
 `Iso<S, A>` represents an isomorphism between types `S` and `A`. That means we can transform from an `S` to an `A` and back to `S` with a pair of functions, and we will get the original value. Similarly, we can start with an `A`, transform it to an `S` and back to an `A` without losing information. This does not mean `S` and `A` are equal, but it implies their structures are equivalent.
 
 An example of an `Iso` can be found in product types. In our running example, `Article` is a product type composed of a `String`, an optional `String`, a `PublicationState` and an `Array` of `String`. But we could also represent the same information using a tuple of 4 elements, and we would be able to get a tuple from an article, and vice versa. That is, we can build an `Iso<Article, (String, Option<String>, PublicationState, [String])>.
 
 To do so, we need a pair of functions. To go from tuple to `Article`, we can use `Article.init`, since the types in the tuple are already in the same order the initializer expects them. To go from `Article` to tuple we need to destructure the `Article`:
 */
func toTuple(_ article: Article) -> (String, Option<String>, PublicationState, [String]) {
    return (article.title, article.subtitle, article.state, article.tags)
}
/*:
 With this function, creating an `Iso` between these types is as easy as:
 */
let iso = Iso<Article, (String, Option<String>, PublicationState, [String])>(get: toTuple, reverseGet: Article.init)
/*:
 The `Iso` initializer expects two functions: `get`, to go from `S` to `A`, and `reverseGet` to go from `A` to `S`, which is exactly what our two functions are doing.
 
 ## Getter
 
 `Getter<S, A>` allows us to get a value `A` out of a structure `S`. For instance, we can make a `Getter` to extract the `title` of an `Article`. In that case, we need to make a `Getter<Article, String>`:
 */
let titleGetter = Getter<Article, String>(get: { article in article.title })
/*:
 ## Setter
 
 Similarly, a `Setter<S, A>` allows us to set a new value of type `A` or modify the existing one in a structure `S`. Since we are dealing with immutable data structures, that involves making a copy of the structure that changes the focused value. We can add the following method to `Article` in order to get copies with modified fields seamlessly:
 */
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
/*:
 This copy method provides multiple overloads to make a copy of the receiver object and modify only certain fields. If an argument is passed, the copy will have it; otherwise, the current value of the object is taken.
 
 Using this, let's proceed to write a `Setter` for the title of an `Article`. To create a `Setter`, we can pass two closures that specify how an article is modified with a function `f` that modifies its title, and how to set a new title for an article. We can write a `Setter<Article, String>`:
 */
let titleSetter = Setter<Article, String>(
    modify: { article, f in article.copy(withTitle: f(article.title)) },
    set: { article, newTitle in article.copy(withTitle: newTitle) })
/*:
 ## Lens
 
 If we combine the power of `Getter` and `Setter` into a single optic, we have a `Lens`. A `Lens<S, A>` is an optic that lets us get, set or modify a value `A` out of a structure `S`.
 
 We can provide a Lens to get/set the title of an `Article` by providing these two functions:
 */
let titleLens = Lens<Article, String>(
    get: { article in article.title },
    set: { article, newTitle in article.copy(withTitle: newTitle) })
/*:
 ## Optional
 
 In the previous optics, title is always present in an `Article`. However, if we focus on its subtitle, we can see it is an `Option<String>`. We can still write a `Lens` whose focus is `Option<String>`, but for the sake of composition, it would be better to remove that optionality.
 
 To do so, we can use the `Optional<S, A>`, which lets us focus on a value `A` that may be absent in a structure `S`, just like the case of the article subtitle. An `Optional` needs two functions to be initialized. The setter function just needs to make a copy of the article with the new value. The getter function is a bit trickier. It returns an `Either`; if the focus is present in the structure, it returns an `Either.right` containing it; otherwise, it returns an `Either.left` with the original article.
 */
let subtitleOptional = Optional<Article, String>(
    set: { article, newSubtitle in article.copy(withSubtitle: .some(newSubtitle)) },
    getOrModify: { article in article.subtitle.fold({ Either.left(article) }, Either.right) })
/*:
 ## Prism
 
 All the optics above work for product types. When it comes to sum types, we need to use `Prism`. `Prism<S, A>` is an optic that lets us focus on a value `A` that is present under certain circumstances in the structure `S`.
 
 Sum types in Swift are usually represented by `enum`, so focusing on one of the cases does not guarantee that it is always going to be there.
 
 As an example, consider the `PublicationState` described above. If we want to focus on the published side and get the `Date` of publication, we need to create a `Prism<PublicationState, Date>`. As usual, we need two functions. The getter lets us get `Either` the date (`right`, if we received a `PublicationState` that is in the state we are focusing) or the original state (`left`, if we are in another case of the `PublicationState`). The other function lets us build a state from a given `Date`.
 */
let publishedPrism = Prism<PublicationState, Date>(
    getOrModify: { state in
        guard case let .published(date) = state else {
            return Either.left(state)
        }
        return Either.right(date)
    }, reverseGet: PublicationState.published)
/*:
 ## Fold
 
 The optics presented so far have only one focus. Is it possible to have multiple foci? The `Fold` and `Traversal` optics have 0 to n foci.
 
 `Fold` is a generalization of `Foldable`. `Fold<S, A>` describes an optic that can focus on several `A` values in a structure `S` and can transform and fold them into a summary value.
 
 This is usually the case of fields that contain collections of elements and we want to focus on them individually. In the case of `Article`, if we write a `Lens` for the tags, it lets us focus on all tags as a whole, not on each individual tag.
 */
let tagsLens = Lens<Article, [String]>(
    get: { article in article.tags },
    set: { article, newTags in article.copy(withTags: newTags) })
/*:
 We can get a `Fold<Article, String>` that lets us have foci to each individual tag. In this case, we can leverage an existing `Fold<[A], A>`; i.e. for any array, it gives us a `Fold` to focus on each item of the array. It is available in `Array<Element>.fold`. With that, we can compose it with the `tagsLens` to get a `Fold`:
 */
let tagsFold: Fold<Article, String> = tagsLens + Array<String>.fold
/*:
 ## Traversal
 
 Finally, `Traversal` is a generalization of `Traverse`. `Traversal<S, A>` lets us focus on multiple `A` values in a structure `S` to get, set or modify them. Like in the case for `Fold`, it is useful for fields that contain collections of elements. Likeways, there is a `Traversal<[A], A>` available for any array in `Array<Element>.traversal`. With that, we can compose it with the `tagsLens` to get a `Traversal`:
 */
let tagsTraversal: Traversal<Article, String> = tagsLens + Array<String>.traversal

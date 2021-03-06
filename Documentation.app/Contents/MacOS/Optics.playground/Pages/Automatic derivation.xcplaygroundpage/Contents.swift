// nef:begin:header
/*
 layout: docs
 title: Automatic derivation
 */
// nef:end
// nef:begin:hidden
import Bow
import BowOptics
// nef:end
/*:
 # Automatic derivation of optics
 
 {:.beginner}
 beginner
 
 Writing optics for each data type may involve a lot of boilerplate. In some cases, Bow can help you generate the optics for your data types. This page will go through each optic that can be automatically generated for your data types. Nonetheless, you should read the section on *Writing your own optics* to get familiar with each optic and how they are implemented.
 
 As a running example, consider the following data types:
 */
enum PublicationState {
    case draft
    case published(Date)
}

struct Article {
    var title: String
    var subtitle: String?
    var state: PublicationState
    var tags: [String]
}
/*:
 **Note**: If you take a close look, you will notice that each field in `Article` is declared as `var` instead of `let`. This is necessary for the automatic generation of optics. If you don't declare your fields as `var`, you will start getting compilation errors when you try to generate your optics and, unfortunately, the error messages will not be descriptive about this being the reason.
 
 ## Getter
 
 In order to get a `Getter`, we need to make our type conform to the `AutoGetter` protocol:
 */
extension Article: AutoGetter {}
/*:
 From there, we can use a key path to a field to obtain its associated `Getter`:
 */
let titleGetter = Article.getter(for: \.title)
/*:
 ## Setter
 
 Similarly, to get a `Setter`, we need to make our type conform to the `AutoSetter` protocol:
 */
extension Article: AutoSetter {}
/*:
 Using a key path to a field, we can get its associated `Setter`:
 */
let titleSetter = Article.setter(for: \.title)
/*:
 ## Lens
 
 If we can get a `Getter` and a `Setter`, we can as well get a `Lens`. We need to make our type conform to the `AutoLens` protocol:
 */
extension Article: AutoLens {}
/*:
 And similarly, using a key path to a field, we can get its associated `Lens`:
 */
let titleLens = Article.lens(for: \.title)
/*:
 ## AffineTraversal
 
 For those fields which may or may not be present, we can create an `AffineTraversal` in an automatic way by conforming to `AutoAffineTraversal`:
 */
extension Article: AutoAffineTraversal {}
/*:
 And using a key path to an optional field, we can obtain its associated `AffineTraversal` optic:
 */
let subtitleAffineTraversal = Article.affineTraversal(for: \.subtitle)
/*:
 ## Fold
 
 For fields that are `Array` or `ArrayK` of values, or any structure that is `Foldable`, we can obtain their associated `Fold` automatically by conforming to the `AutoFold` protocol:
 */
extension Article: AutoFold {}
/*:
 Using a key path to an `Array` or `ArrayK` field, or a field whose type is `Foldable`, we can get its associated `Fold`:
 */
let tagsFold = Article.fold(for: \.tags)
/*:
 ## Traversal
 
 Similar to `Fold`, for those fields that are `Array` or `ArrayK` of values, or any structure that is `Traverse`, we can obtain their associated `Traversal` automatically by conforming to the `AutoTraversal` protocol:
 */
extension Article: AutoTraversal {}
/*:
 Using a key path to an `Array` or `ArrayK` field, or a field whose type is `Traverse`, we can get its associated `Traversal`:
 */
let tagsTraversal = Article.traversal(for: \.tags)
/*:
 ## Prism
 
 The optics above work mainly in product types. For sum types, we can try to derive `Prism` in an automatic manner by conforming to the `AutoPrism` protocol:
 */
extension PublicationState: AutoPrism {}
/*:
 At this point, there are two possible situations: the case of the enum we want to focus with our prism does not have associated values, or does have them.
 
 If the focus of the `Prism` does not have any associated value, like `PublicationState.draft`, we can obtain it seamlessly:
 */
let draftPrism = PublicationState.prism(for: .draft)
/*:
 In case the focus has associated values, it works the same. Bow will auto extract for you the associated values:
 */
let publishedPrism = PublicationState.prism(for: PublicationState.published)
/*:
 ## Summary
 
 Using the `Auto-` protocols let us reduce the boilerplate associated to generating many of the optics, thus making it much easier and more seamless to work with optics.
 */

// nef:begin:header
/*
 layout: docs
 title: Running side effects
 */
// nef:end
// nef:begin:hidden
import Foundation
import Bow
import BowEffects
// nef:end
/*:
 # Running side effects
 
 {:.beginner}
 beginner
 
 `IO` suspends side effects; i.e. it prevents them from running. But at some point they need to be actually evaluated in order to produce the expected outcome of the program. This section shows the different ways you have to execute an `IO` program.
 
 For the rest of this page, consider the following function from a shopping service that fetches articles from the network, from a given category on a specific page and providing a limit to the number of articles that are received:
 */
// nef:begin:hidden
struct Article {}
enum Category {
    case boardgames
    case technology
    case comics
}
enum APIError: Error {}
// nef:end
func fetchArticles(from category: Category, page: UInt, limit: UInt) -> IO<APIError, [Article]>
// nef:begin:hidden
{ return IO.pure([])^ }
// nef:end
/*:
 ## Synchronous run
 
 We can run the function above synchronously using the `unsafeRunSync ` method on `IO`:
 */
let articles: [Article] = try fetchArticles(from: .boardgames, page: 1, limit: 30).unsafeRunSync()
/*:
 This function will return the array of articles that it fetched if everything went well, or will throw an `APIError` if there was any problem (thus, we need to invoke this function using the `try` keyword). If, for some reason, an error of a different type arises, it will cause a fatal error, as our `IO` will not know how to handle it.
 
 If we prefer, there is a safer version of this method, called `unsafeRunSyncEither`:
 */
let result: Either<APIError, [Article]> = fetchArticles(from: .technology, page: 3, limit: 10).unsafeRunSyncEither()
/*:
 This way, the result of the execution will be wrapped in an `Either` value; on the right side, we can find the successful value, and on the left side, the error that may happen.
 
 Both versions will block the execution until the evaluation of the `IO` value finishes.
 
 ## Asynchronous run
 
 If we want to avoid blocking the execution, we can run the `IO` value using `unsafePerformAsync` and passing a callback:
 */
fetchArticles(from: .boardgames, page: 4, limit: 15).unsafeRunAsync { (result: Either<APIError, [Article]>) in
    // Process result
}
/*:
 ## Running on a different `DispatchQueue`
 
 By default, all options to run an `IO` will use `DispatchQueue.main` to run. If you want to specify your own queue, you can provide it as a parameter to the call:
 */
// On the background queue
try fetchArticles(from: .comics, page: 10, limit: 25).unsafeRunSync(on: .global(qos: .background))

// On a custom queue
fetchArticles(from: .boardgames, page: 1, limit: 5).unsafeRunSyncEither(on: DispatchQueue(label: "MyQueue"))

// On the main queue, equivalent to omitting the parameter
fetchArticles(from: .technology, page: 8, limit: 10).unsafeRunAsync(on: .main) { result in
    // ... Process result ...
}

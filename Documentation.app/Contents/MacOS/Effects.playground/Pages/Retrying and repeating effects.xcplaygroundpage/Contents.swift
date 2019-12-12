// nef:begin:header
/*
 layout: docs
 title: Retrying and repeating effects
 */
// nef:end
// nef:begin:hidden
import Foundation
import Bow
import BowEffects

let formatter = DateFormatter()
formatter.dateFormat = "HH:mm:ss"

let io = Task<String>.invoke {
    let date = Date()
    return formatter.string(from: date)
}.env

enum AnyError: Error {
    case unknown
}
// nef:end
/*:
 # Retrying and repeating effects
 
 A common demand when working with effects is to retry or repeat them when certain circumstances happen. Usually, the retrial or repetition does not happen right away; rather, it is done based on a policy. For instance, when fetching content from a network request, we may want to retry it when it fails, using an exponential backoff algorithm, for a maximum of 15 seconds or 5 attempts, whatever happens first.
 
 Fortunately, Bow Effects provides a composable way to achieve this easily. Both `IO` and `EnvIO` provide methods to retry and repeat themselves based on a scheduling policy. The semantics of each one are:
 
 - **retry**: The effect is executed once, and if it fails, it will be reattempted based on the scheduling policy passed as an argument. It will stop if the effect ever succeeds, or the policy determines it should not be reattempted again. It will return the success value of the effect, or the last returned error.
 
 - **repeat**: The effect is executed once, and if it succeeds, it will be executed again based on the scheduling policy passed as an argument. It will stop if the effect ever fails, or the policy determines it should not be executed again. It will return the last internal state of the scheduling policy, or the error that happened running the effect. Returning the last internal state of the scheduling policy will let us use different strategies to return the result of the effect, as we will see below.
 
 ## Basic scheduling policies
 
 As stated above, the scheduling policies provided in Bow Effects are highly composable, leading to very powerful and complex policies, written in a very simple manner.
 
 The library provides a number of simple policies that serve as building blocks to build more complex ones. These units are:
 
 | Scheduling policy           | Description |
 | --------------------------- | ----------- |
 | `forever()`                 | A policy that recurs forever, emitting the number of iterations it has performed. |
 | `never()`                   | A policy that never recurs. |
 | `recurs(n)`                 | A policy that recurs `n` times. Notice that the original effect will be executed once, and then potentially `n` more times according to the policy. |
 | `once()`                    | A policy that recurs once. It is an alias to `recurs(1)`. Notice that the original effect will be executed once, and potentially once more according to the policy. |
 | `duration(time)`            | A policy that recurs for the specified amount of time. |
 | `spaced(time)`              | A policy that recurs forever, waiting the specified amount of time between iterations. |
 | `linear(time)`              | A policy that recurs forever, incrementing linearly the waiting time between iterations, using the specified time as a base increment. For instance, if the base time is one second, the policy will wait one second for the first attempt, two for the second, 3 for the third, and so on. |
 | `exponential(time, factor)` | A policy that recurs forever, incrementing exponentially the waiting time between iterations, using the specified time as a base increment, and the provided factor as the power for the exponential backoff algorithm. The default value for the factor is 2. |
 | `fibonacci(time)`           | A policy that recurs forever, incrementing the waiting time between iterations following the Fibonacci sequence, using the specified time as a base increment. |
 | `doWhile(predicate)`        | A policy that recurs while the result of the effect satisfies the provided predicate. |
 | `doWhileEquals(value)`      | A policy that recurs while the result of the effect is equal to the specified value. |
 | `doUntil(predicate)`        | A policy that recurs until the result of the effect satisfies the provided predicate. |
 | `doUntilEquals(value)`      | A policy that recurs until the result of the effect is equal to the specified value. |
 | `collectAll()`              | A policy that recurs forever and collects all results provided by the effect while recursing. |
 | `collectWhile(predicate)`   | A policy that recurs while the result of the effect satisfies the provided predicate, collecting all the intermediate results. |
 | `collectUntil(predicate)`   | A policy that recurs until the result of the effect satisfies the provided predicate, collecting all the intermediate results. |
 
 ## Combining scheduling policies
 
 These building blocks can be composed in different ways to form more powerful scheduling policies. These are the combinators that Bow Effects provides to compose scheduling policies:
 
 | Combinator        | Description |
 | ----------------- | ----------- |
 | `s1.and(s2)`      | Provides a policy that recurs as long as both policies agree to recurs, using the maximum waiting time between both policies. |
 | `s1.or(s2)`       | Provides a policy that recurs as long as one of the policies agree to recurs, using the minimum waiting time between both policies. |
 | `s1.zipLeft(s2)`  | Provides a policy that behaves as `s1.and(s2)`, but only keeps the results provided by the left scheduling policy. |
 | `s1.zipRight(s2)` | Provides a policy that behaves as `s1.and(s2)` but only keeps the results provided by the right scheduling policy. |
 | `s1.andThen(s2)`  | Provides a policy that first consumes `s1` until it determines not to recurs, and then consumes `s2`. |
 | `s1.forever()`    | Provides a policy that consumes `s1` until it determines no to recurs, and reinitializes it to run it again, forever. |
 | `s1.addDelay(f)`  | Provides a policy that adds a delay between each iteration of `s1`, determined by a provided function that computes the delay from the last output of the policy. |
 
 ## Common use cases
 
 Once we have building blocks and ways to combine them, let's see how we can use them to solve some use cases.
 
 ### Repeating an effect and dealing with its result
 
 When we repeat an effect, we do it as long as it keeps providing successful results and the scheduling policy tells us to keep recursing. But then, there is a question on what to do with the results provided by each iteration of the repetition.
 
 There are at least 3 possible things we would like to do:
 
 - Discard all results; i.e., return `Void`.
 - Discard all intermediate results and just keep the last produced result.
 - Keep all intermediate results.
 
 Assuming we have an effect in `io`, and we want to repeat it 3 times after its first successful execution, we can do:
 */

let repeated3Times = io.repeat(Schedule.recurs(3),
                               onUpdateError: { AnyError.unknown })
/*:
 However, when running this new effect, its output will be the number of iterations it has performed, as stated in the documentation of the function. Notice also that we need to provide an error to return when the schedule fails to update. The type of this error must be the same as the error type our original `IO` knows how to handle.
 
 If we want to discard the values provided by the repetition of the effect, we can combine our policy with `Schedule.void()`, using the `zipLeft` or `zipRight` combinators, which will keep just the output of one of the policies:
 */
let discardedResult1 = io.repeat(Schedule.void().zipLeft(Schedule.recurs(3)),
                                 onUpdateError: { AnyError.unknown })

// Equivalent to:
let discardedResult2 = io.repeat(Schedule.recurs(3).zipRight(Schedule.void()),
                                 onUpdateError: { AnyError.unknown })

/*:
 Following the same strategy, we can zip it with the `Schedule.identity()` policy to keep only the last provided result by the effect.
 */
let lastResult1 = io.repeat(Schedule.identity().zipLeft(Schedule.recurs(3)),
                            onUpdateError: { AnyError.unknown })

// Equivalent to:
let lastResult2 = io.repeat(Schedule.recurs(3).zipRight(Schedule.identity()),
                            onUpdateError: { AnyError.unknown })

/*:
 Finally, if we want to keep all intermediate results, we can zip the policy with `Schedule.collectAll()`:
 */
let allResults1 = io.repeat(Schedule.collectAll().zipLeft(Schedule.recurs(3)),
                            onUpdateError: { AnyError.unknown })

// Equivalent to:
let allResults2 = io.repeat(Schedule.recurs(3).zipRight(Schedule.collectAll()),
                            onUpdateError: { AnyError.unknown })

/*:
 ### Repeating an effect until/while it produces a certain value
 
 We can make use of the policies `doWhile` or `doUntil` to repeat an effect while or until its produced result matches a given predicate.
 */

let repeatWhile = io.repeat(Schedule.doWhile { str in str.isEmpty },
                            onUpdateError: { AnyError.unknown })

let repeatUntil = io.repeat(Schedule.doUntil { str in str.isEmpty },
                            onUpdateError: { AnyError.unknown })

/*:
 However, this may never terminate. In this cases, we can usually add a timeout. We can do this with the `Schedule.duration(t)` policy, that runs an effect for the specified time duration. The examples above can be combined with the `and` combinator to have a timeout, for instance, after 3 seconds:
 */
let repeatWhileTimeout = io.repeat(Schedule.doWhile { str in str.isEmpty }
                                    .and(Schedule.duration(.seconds(3))),
                                   onUpdateError: { AnyError.unknown })

let repeatUntilTimeout = io.repeat(Schedule.doUntil { str in str.isEmpty }
                                    .and(Schedule.duration(.seconds(3))),
                                   onUpdateError: { AnyError.unknown })

/*:
 ### Exponential backoff retries
 
 A common algorithm to retry effectful operations, as network requests, is the [exponential backoff algorithm](https://en.wikipedia.org/wiki/Exponential_backoff). There is a scheduling policy that implements this algorithm and can be used as:
 */
let exponential = io.retry(Schedule.exponential(.milliseconds(250)))

/*:
 As more iterations of this algorithm are performed, the waiting time becomes larger and larger. We may want to use it for the initial retries, and then switch to evenly spaced retries. This can be achieved with the `Schedule.spaced(t)` policy and the `or` combinator. This will keep retrying as long as either of them want to keep retrying, using the minimum of both delays between iterations:
 */
let exponentialOrFixed = io.retry(
    Schedule.exponential(.milliseconds(250)).or(Schedule.spaced(.seconds(3)))
)
/*:
 This will attempt to retry the effect with the exponential backoff algorithm, waiting at most 3 seconds between each attempt. Nevertheless, this will keep running forever. We can limit it in time, using the `Schedule.duration(t)` policy, to set a timeout, or limit the number of iterations with the `Schedule.recurs(n)` policy. For instance, we can limit it to 10 attempts like:
 */
let exponentialOrFixedMax10Times = io.retry(
    Schedule.exponential(.milliseconds(250)).or(Schedule.spaced(.seconds(3)))
        .and(Schedule.recurs(10))
)
/*:
 Finally, if all retries are performed, and still the effect does not succeed, it will fail with an error. There is an overload of `retry` that lets us provide a closure to deal with this error and provide a default value:
 */
let exponentialOrFixedMax10Times_withDefaultResponse = io.retry(
    Schedule.exponential(.milliseconds(250)).or(Schedule.spaced(.seconds(3)))
        .and(Schedule.recurs(10)),
    orElse: { error, state in EnvIO.pure(Either<String, String>.left("Default value"))^ })

---
layout: docs
title: Error handling
permalink: /docs/patterns/error-handling/
---

# Error handling

 {:.beginner}
 beginner
 
 Error handling is a common concern in software development. In this section, we are going to review multiple ways of doing this task by using a running example.
 
 Consider we are developing an application where the user enters some personal information. We would like to validate the inputs before creating a form, and report any errors found. The validation rules provided by our business logic are:
 
 - First and last name must not be empty.
 - Age must be over 18.
 - Document ID must be 8 digits followed by a letter.
 - Phone number must have 9 digits.
 - Email must contain an @ symbol.
 
## Error modeling
 
 Errors in Swift are usually modeled using the `Error` protocol. By conforming to it, we mark our type as an error, and it allows us to throw it from a throwing function or as a failure type in `Result`, as we will see later. Therefore, in our example, we can model our validation errors as:

```swift
enum ValidationError: Error {
    case emptyFirstName(String)
    case emptyLastName(String)
    case userTooYoung(Date)
    case invalidDocumentId(String)
    case invalidPhoneNumber(String)
    case invalidEmail(String)
}
```

 That is, we are grouping all our errors regarding validation under a common type, `ValidationError`, that has a case for each class of error that our business rules distinguish. Also, we are attaching values to the errors to be able to provide more information about what went wrong.
 
## Success modeling
 
 In case everything went well, we would like to create a form with the validated data. To model this, we can use a struct:

```swift
struct Form {
    let firstName: String
    let lastName: String
    let birthday: Date
    let documentId: String
    let phoneNumber: String
    let email: String
}
```

 Once we have models for success and error, let us explore several possibilities to write the validation logic for the example above.
 
## Using Option / Optional
 
 A possible solution to indicate an error happened during the validation of one of the fields is to model it as an absent value. Swift introduces the `Optional<Wrapped>` type, usually sugared as `Wrapped?`, to model two cases: we either have a value of type `Wrapped`, or we don't have a value at all, represented as `nil`.
 
 Using `Optional<Wrapped>`, we could write one of the validation functions as:

```swift
func validateOptional(email: String) -> String? {
    return email.contains("@") ?
        email :
        nil
}
```

 Bow provides the `Option<A>` type, which has the same semantics of `Optional<A>`, but simulates being a Higher-Kinded Type. The same function above could be written using `Option<A>`:

```swift
func validateOption(email: String) -> Option<String> {
    return email.contains("@") ?
        .some(email) :
        .none()
}
```

 `Option` and `Optional` are isomorphic; that is, the can be converted from/to each other without losing any information.
 
 Modeling validation using this approach lets us distinguish between cases where everything went well and where there was an error. However, we are unable to know the reasons why the validation was wrong.
 
## Throwing errors
 
 Another alternative is to use the throwing mechanisms provided in the language. Values conforming to `Error` can be thrown from a function as long as the function is marked with the `throws` keyword:

```swift
func validateThrow(email: String) throws -> String {
    guard email.contains("@") else {
        throw ValidationError.invalidEmail(email)
    }
    return email
}
```

 This approach let us catch the error thrown by this function and know the reason why it failed. However, there is still a problem. If we only look at the signature of the function, we do not have information about which type of errors this function is throwing; we would need to check the documentation or even the implementation of the function in order to know about it, and if it changes, we will not get a compiler error in the calling sites to remind us that we need to deal with a different type of error.
 
 Moreover, throwing errors this way breaks referential transparency. We cannot reason about the output of the function in terms of its inputs, as there are two possible exits from the function: through the successful return or through the failed throw.
 
## Try
 
 In an attempt to overcome the referential transparency problem, Bow provides the `Try<A>` type, which models two possibilities: `Try.success` for successful value of type `A`, and `Try.failure` for a value conforming to `Error`. Thus, the throwing function above could be rewritten as:

```swift
func validateTry(email: String) -> Try<String> {
    guard email.contains("@") else {
        return Try.failure(ValidationError.invalidEmail(email))
    }
    return Try.success(email)
}
```

 `Try` also includes a constructor that is able to wrap a throwing function and convert it to a `Try` value:

```swift
let tryFromThrow = Try.invoke { try validateThrow(email: "wrong_email.com") }
```

 Although `Try` solves the issue about breaking referential transparency, we still don't have proper typing of the error that is happening. `Try` swallows it and represents it as the generic `Error` protocol. To achieve this, we need to use a type that lets us be explicit on the type error that we are using.
 
## Result
 
 Since Swift 5 we have a type that has the semantics we are looking for. Such type is `Result<Success, Failure>` that lets us represent either a successful value of type `Success` or a failure of type `Failure`. The type `Failure` must conform to `Error`.
 
 Result has a constructor that lets us catch errors from a throwing function, similar to what we achieved with `Try`:

```swift
let catched: Result<String, Error> = Result(catching: { try validateThrow(email: "wrong_email.com") })
```

 However, as we can guess, it does not have enough information about the error type that the function is throwing. Thus, we would need to rewrite our validation functions making the failure type explicit:

```swift
class ValidationRules {
    static func validate(email: String) -> Result<String, ValidationError> {
        guard email.contains("@") else {
            return .failure(.invalidEmail(email))
        }
        return .success(email)
    }
}
```

 This way, we still maintain referential transparency (our validation function is pure) and we have a concrete type describing the possible errors that may happen. If our failure type changes, we will get compiler errors everywhere we are calling this function and we will not miss them.
 
 Up to this point, we are able to validate each individual field:

```swift
let firstNameResult = ValidationRules.validate(firstName: "Tomás")
let lastNameResult = ValidationRules.validate(lastName: "Ruiz-López")
let birtdayResult = ValidationRules.validate(birthday: Date(timeIntervalSince1970: 1234), referenceDate: Date())
let documentIdResult = ValidationRules.validate(documentId: "00000000A")
let phoneResult = ValidationRules.validate(phoneNumber: "000000000")
let emailResult = ValidationRules.validate(email: "myuser@email.com")
```

 We need to combine them to make a `Form`, but its constructor does not take `Result` values. How can we proceed then?
 
 When we need to inspect a `Result` value, we can do pattern matching over its two sides or, if we are just interested in transforming either side, we can use its `map` or `mapError` methods. What if we have several `Result` values? We can also pattern match over a tuple, but then we would need to deal with all possible combinations (or at least a number of them). It would be nice to have an API method similar to `map` but working with multiple values; however, the API in `Result` does not have it.
 
 Besides this limitation, we would need to think about how to deal with multiple errors. There are two alternatives:
 
 1. Fail-fast: return the first result that has a failure.
 2. Error-accumulation: return all results that have failures.
 
 Bow provides two types that are similar to `Result`, have a more expressive API and implement these strategies.
 
## Either
 
 `Either<A, B>` represents the sum type of types `A` and `B`. It has two constructors: `Either.left` and `Either.right`. Unlike `Result`, it does not impose any restriction on the types you can use; there is no need to conform to `Error`. You can view `Either.left` as equivalent to `Result.failure` and `Either.right` as equivalent to `Result.success`.
 
 When the left type conforms to `Error`, `Either` can be converted to `Result` and back:

```swift
let result: Result<String, ValidationError> = Either.right("Tomás").toResult()
let either: Either<ValidationError, String> = result.toEither()
```

 Notice that the type arguments in `Either` are reversed respect to the ones in `Result`. This is due to how Higher-Kinded Types are simulated in Bow: types are partially applied from left to right, so the successful part must always be at the right-most position of the type.
 
 We can write the validation functions using `Either`:

```swift
class FailFast {
    static func validate(email: String) -> Either<ValidationError, String> {
        guard email.contains("@") else {
            return .left(.invalidEmail(email))
        }
        return .right(email)
    }
    
    // Implementation of the rest of validation functions
}
```

 `Either` has a method that lets us map over multiple values. We can pass it multiple values and a function, and it will invoke it if every one of them is successful. In case one or more values are unsuccessful, the first failure is returned. In our case, the combination function is the initializer of the `Form` that we need to creat. The implementation of the combination function using a fail-fast strategy is:

```swift
extension FailFast {
    static func validate(firstName: String,
                         lastName: String,
                         birthday: Date,
                         documentId: String,
                         phoneNumber: String,
                         email: String) -> Either<ValidationError, Form> {
        return Either<ValidationError, Form>.map(
            validate(firstName: firstName),
            validate(lastName: lastName),
            validate(birthday: birthday, referenceDate: Date()),
            validate(documentId: documentId),
            validate(phoneNumber: phoneNumber),
            validate(email: email),
            Form.init)^
    }
}
```

 Thus, invoking this with correct parameters will return an `Either.right` containing a `Form`, whereas invoking it with one or more incorrect parameters will return an `Either.left` with the first error that it finds.
 
## Validated
 
 Similarly, `Validated<A, B>` represents the case of having a valid value of type `B`, or an invalid value of type `A`. It has two constructors: `Validated.valid`, similar to `Result.success`, and `Validated.invalid`, similar to `Result.failure`, with the difference that `Validated` does not impose the invalid type to conform to `Error`.
 
 `Validated` can be transformed to `Result` and back, as long as the invalid type conforms to `Error`:

```swift
let resultFromValidated: Result<String, ValidationError> = Validated.valid("Tomás").toResult()
let validatedFromResult: Validated<ValidationError, String> = resultFromValidated.toValidated()
```

 `Validated` has an API similar to `Either` to combine different values through the `map` function. The main difference is that it does error accumulation. To do so, the invalid type needs to be able to accumulate errors; that is, it needs to conform to `Semigroup`.
 
 Since this pattern is very usual in Functional Programming, there is a type to do this kind of accumulation: `NonEmptyArray`. `NonEmptyArray`, or `NEA` for short, represents an array with at least one element. The reason to use this type instead of a regular array is to avoid an inconsistent state where we are in a `Validated.invalid` value, but have an empry array with no errors.
 
 Therefore, we can model our functions to return `Validated<NonEmptyArray<ValidationError>, String>`. As this name is quite long and the pattern is usual, Bow includes a type alias for this, which lets us write `ValidatedNEA<ValidationError, String>`.
 
 Bow also includes functions to transform to `ValidatedNEA`:

```swift
let validatedNEAFromResult: ValidatedNEA<ValidationError, String> = Result.success("Tomás").toValidatedNEA()
let validatedNEAFromValidated: ValidatedNEA<ValidationError, String> = Validated.valid("Tomás").toValidatedNEA()
```

 Thus, we can use `ValidatedNEA` to write our validation functions:

```swift
class ErrorAccumulation {
    static func validate(email: String) -> ValidatedNEA<ValidationError, String> {
        guard email.contains("@") else {
            return .invalid(.of(.invalidEmail(email)))
        }
        return .valid(email)
    }
    
    // Implementation of the rest of validation functions
}
```

 And finally, making use of `Validated.map`, we can write our validation function that combines all successful results into a Form or accumulates all errors found:

```swift
extension ErrorAccumulation {
    static func validate(firstName: String,
                         lastName: String,
                         birthday: Date,
                         documentId: String,
                         phoneNumber: String,
                         email: String) -> ValidatedNEA<ValidationError, Form> {
        return ValidatedNEA<ValidationError, Form>.map(
            validate(firstName: firstName),
            validate(lastName: lastName),
            validate(birthday: birthday, referenceDate: Date()),
            validate(documentId: documentId),
            validate(phoneNumber: phoneNumber),
            validate(email: email),
            Form.init)^
    }
}
```

 {:.intermediate}
 intermediate
 
## Applicative
 
 If we examine carefully both validation functions (fail-fast and error accumulation), we can observe a similar pattern. In fact, the only thing that changes is the type we are using to invoke the function. That suggests that we could write a single validation function that operates on a type parameter, constrained by a protocol (a type class) that abstracts the `map` operation.
 
 Such type class is known as `Applicative` and it is particularly used to perform multiple independent effects and combine their results. That is, in fact, what we are doing here: we are evaluating 6 independent validations and combining their successful results. Both `Either` and `Validated` have instances for `Applicative`; that is, they conform to this protocol. But they are not the only types to do so; in fact, we could also write a validation function to combine validations returning `Option`:

```swift
class OptionValidation {
    static func validate(email: String) -> Option<String> {
        guard email.contains("@") else {
            return .none()
        }
        return .some(email)
    }
    
    // Implementation of the rest of validation functions
}

extension OptionValidation {
    static func validate(firstName: String,
                         lastName: String,
                         birthday: Date,
                         documentId: String,
                         phoneNumber: String,
                         email: String) -> Option<Form> {
        return Option<Form>.map(
            validate(firstName: firstName),
            validate(lastName: lastName),
            validate(birthday: birthday, referenceDate: Date()),
            validate(documentId: documentId),
            validate(phoneNumber: phoneNumber),
            validate(email: email),
            Form.init)^
    }
}
```

 In this case, we would lose the information about the error type, as we discussed above, but we would still be able to have the combination of successful values.
 
 What about `Result`? Would it be possible to do the same? We could definitely write `map` as an extension to `Result` to perform this type of operations. Since it already implements a `flatMap` operation, `Result` must have a fail-fast policy. The reason behind this is that `map` with multiple parameters can be derived from a `flatMap` implementation, but adding error accumulation leads to a lack of consistency of the results we can obtain. In other words, `Applicative` and `Monad` (where `flatMap` is defined`) have some rules that every implementation must adhere to, and implementations based on `flatMap` do not fulfill these rules if we start accumulating errors.
 
 Besides this, `Applicative` is a protocol that operates on Higher-Kinded Types. At the moment, HKT are not supported natively, so only types which are build with the simulation that Bow provides can conform to this type of protocols. We could write a wrapper of `Result` to make it an HKT (named, for instance, `ResultK`), in a similar way our `Option` wraps Swift `Optional` type; however, `Either` generalizes what `ResultK` would do. In fact, it would be as easy as creating a type alias:

```swift
typealias ResultK<B, A> = Either<A, B> where A: Error

extension ResultK where A: Error {
    static func success(_ value: B) -> ResultK<B, A> {
        return .right(value)
    }
    
    static func failure(_ error: A) -> ResultK<B, A> {
        return .left(error)
    }
}
```

 This way, we could have a `Result`-like type that has conformance to `Applicative` and many other type classes.
 
## ApplicativeError
 
 If we look closely, `Applicative.map` is not the only pattern we can observe in our code above. In fact, all validation functions reduce to checking some conditions and then creating a wrapper over the success or error values depending on the type we are returning.
 
 We can generalize that with the `ApplicativeError` type class. `ApplicativeError` augments `Applicative` with error handling capabilities. It provides functions to create those wrappers for the success and error values in a general way. The correspondence with `Either` and `Validated` is:
 
 | ApplicativeError | Either | Validated |
 |:----------------:|:------:|:---------:|
 | pure             | right  | valid     |
 | raiseError       | left   | invalid   |
 
 Then, we can write the validation functions in an abstract manner, without knowing which type they will be evaluated to, and knowing the error type will be `NonEmptyArray<ValidationError>`:

```swift
class GeneralValidationRules<F: ApplicativeError> where F.E == NEA<ValidationError> {
    static func validate(email: String) -> Kind<F, String> {
        guard email.contains("@") else {
            return .raiseError(.of(.invalidEmail(email)))
        }
        return .pure(email)
    }
    
    // Implementation of the rest of validation functions
}

extension GeneralValidationRules {
    static func validate(firstName: String,
                         lastName: String,
                         birthday: Date,
                         documentId: String,
                         phoneNumber: String,
                         email: String) -> Kind<F, Form> {
        return Kind<F, Form>.map(
            validate(firstName: firstName),
            validate(lastName: lastName),
            validate(birthday: birthday, referenceDate: Date()),
            validate(documentId: documentId),
            validate(phoneNumber: phoneNumber),
            validate(email: email),
            Form.init)
    }
}
```

 With this implementation, we just need to pass the type we want to interpret to as a type argument. Using `Either` we get fail-fast behavior:

```swift
let failfast = GeneralValidationRules<EitherPartial<NEA<ValidationError>>>
    .validate(firstName: " ",
              lastName: "  ",
              birthday: Date(),
              documentId: "---",
              phoneNumber: "?",
              email: "no_email")^
```

 And with `Validated`, we get error accumulation:

```swift
let accumulation = GeneralValidationRules<ValidatedPartial<NEA<ValidationError>>>
    .validate(firstName: " ",
              lastName: "  ",
              birthday: Date(),
              documentId: "---",
              phoneNumber: "?",
              email: "no_email")^
```

 Using this approach, we have a single implementation of the validation rules, but multiple strategies to evaluate them.

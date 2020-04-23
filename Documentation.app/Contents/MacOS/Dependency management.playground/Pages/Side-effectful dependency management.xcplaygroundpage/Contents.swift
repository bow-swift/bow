// nef:begin:header
/*
 layout: docs
 title: Side-effectful dependency management
 */
// nef:end
// nef:begin:hidden
import Bow
import BowEffects
// nef:end
/*:
 # Side-effectful dependency management

 Oftentimes, our dependencies will interact with the external world, thus causing side effects. Networking operations or persistence are some examples of these dependencies. We can deal with these cases using the Reader pattern. Nonetheless, Bow Effects provides a specific type with additional ergonomics: the `EnvIO` type.
 
 `EnvIO<D, E, A>` is a type alias over `Kleisli`, that models a suspended, side-effectful operation, which has a dependency on `D`, could cause errors of type `E`, and returns values of type `A`. Therefore, it combines dependency management, error handling, and suspension of side effects.
 
 ## Constructing values of `EnvIO`
 
 We can create an `EnvIO` using the `invoke` method, which lets us pass a throwing function.
 */
// nef:begin:hidden
class Dependency {
    func doSomething() throws -> String {
        ""
    }
}
// nef:end
let envIO: EnvIO<Dependency, Error, String> = EnvIO.invoke { dependency in
    try dependency.doSomething()
}
/*:
 The provided function will not be executed in the moment of creation; rather, it will be suspended until the moment we provide the dependency and then call the `unsafeRun` methods in `IO`.
 
 ## Modeling dependencies as algebras
 
 A common approach to deal with dependencies is to abstract them in a protocol that contains a set of operations, often known as an algebra. Then, instead of using the concrete implementation as a dependency, we use the protocol, which would allow us to replace the dependency in other contexts, like testing.
 
 For instance, assuming our software needs to communicate with a backend and persist information, we can model these two dependencies as:
 */
struct User {
    let name: String
}

enum NetworkError: Error {
    case usersNotFound
}

protocol NetworkService {
    func fetchUsers<D>() -> EnvIO<D, NetworkError, [User]>
}

enum PersistenceError: Error {
    case failedWriting(users: [User])
}

protocol PersistenceService {
    func save<D>(users: [User]) -> EnvIO<D, PersistenceError, Void>
}
/*:
 Notice that both `fetchUsers` and `save(users:)` declare a generic `D` type for their dependencies. This is because they will not have additional dependencies to perform their job, but we still need some type for `EnvIO`. We could use `Any` to indicate an operation has no dependencies; however, using a generic type lets the compiler infer the dependency type we are using in the call site.
 
 ## Combining dependencies
 
 Consider now that we have to implement a workflow where we fetch the users, and then persist and return them. We will need to combine both dependencies into an environment that contains them:
 */
struct Environment {
    let network: NetworkService
    let persistence: PersistenceService
}
/*:
 In order to combine `EnvIO` operations, they need to use the same dependencies and error types. We can create a superset of the error type:
 */
enum EnvironmentError: Error {
    case network(NetworkError)
    case persistence(PersistenceError)
}
/*:
 Then, we can write the workflow:
 */
func workflowAsk() -> EnvIO<Environment, EnvironmentError, [User]> {
    let environment = EnvIO<Environment, EnvironmentError, Environment>.var()
    let users = EnvIO<Environment, EnvironmentError, [User]>.var()
    
    return binding(
        environment <- .ask(),
        users <- environment.get.network.fetchUsers()
            .mapError(EnvironmentError.network),
        |<-environment.get.persistence.save(users: users.get)
            .mapError(EnvironmentError.persistence),
        yield: users.get)^
}
/*:
 We can use the `ask` function to get access to the current environment, and then access its properties to invoke the dependencies. Notice that, after the invocation, we need to map the error into the more global error.
 
 There is an alternative way to do it:
 */
func workflowAccess() -> EnvIO<Environment, EnvironmentError, [User]> {
    func fetchUsers() -> EnvIO<Environment, EnvironmentError, [User]> {
        EnvIO.accessM { environment in
            environment.network.fetchUsers()
        }.mapError(EnvironmentError.network)
    }
    
    func persist(users: [User]) -> EnvIO<Environment, EnvironmentError, Void> {
        EnvIO.accessM { environment in
            environment.persistence.save(users: users)
        }.mapError(EnvironmentError.persistence)
    }
    
    return fetchUsers().flatTap { users in
        persist(users: users)
    }^
}
/*:
 In this version, we use the `accessM` function, which lets us access the current environment and return an `EnvIO` that continues operating in the same context. We have extracted the operations in auxiliary functions that adapt the dependency and error types. Finally, instead of using Monad Comprehensions, we can use `flatMap` / `flatTap` to sequence the operations.
 
 ## Towards a global enviroment
 
 Our workflow function works on `Environment`, but as we move towards other layers of our application, this environment will be more global, containing other dependencies. In order to compose the workflow with other operations, we have mentioned that it must have the same dependency and error type. We have seen we can adapt the error type with `mapError`; what about the dependency type?
 
 Let's assume the enviroment type we have in the next layer of our software is `GlobalEnvironment`:
 */
struct GlobalEnvironment {
    let localEnviroment: Environment
    // + other dependencies
}
/*:
 We can use `contramap` in order to generalize the dependency type of an `EnvIO`. `contramap` is similar to `map`, but the function we apply is reversed. That is, if we have `EnvIO<D1, E, A>` and we need `EnvIO<D2, E, A>`, we need a function `(D2) -> D1` for `contramap`.
 
 In this particular case, we can use:
 */
let globalWorkflow1: EnvIO<GlobalEnvironment, EnvironmentError, [User]> =
    workflowAccess().contramap { globalEnvironment in
        globalEnvironment.localEnviroment
    }
/*:
 Or we can use a `KeyPath` to access the specific dependency we need:
 */
let globalWorkflow2: EnvIO<GlobalEnvironment, EnvironmentError, [User]> =
    workflowAccess().contramap(\.localEnviroment)
/*:
 ## The Cake Pattern
 
 The approach above works nicely but has some drawbacks:
 
 - It imposes a rigid structure for grouping the dependencies, making it hard to replace it, especially when we have workflows that use different subsets of the dependencies contained in the environment.
 - It may expose all dependencies to a given workflow, where we may want to restrict the visibility of some of them.
 
 There is an alternative that is usually known as the Cake Pattern. In this case, we can model capabilities as additional protocols:
 */
protocol HasNetwork {
    var network: NetworkService { get }
}

protocol HasPersistence {
    var persistence: PersistenceService { get }
}
/*:
 Thus, we can rewrite our workflow as:
 */
func workflowCake<D: HasNetwork & HasPersistence>() -> EnvIO<D, EnvironmentError, [User]> {
    
    let environment = EnvIO<D, EnvironmentError, D>.var()
    let users = EnvIO<D, EnvironmentError, [User]>.var()
    
    return binding(
        environment <- .ask(),
        users <- environment.get.network.fetchUsers()
            .mapError(EnvironmentError.network),
        |<-environment.get.persistence.save(users: users.get)
            .mapError(EnvironmentError.persistence),
        yield: users.get)^
}
/*:
 With this change, we can provide an environment with more dependencies, but the workflow has limited visibility of what it can use. In order to avoid long lists of protocols, we can group them using type aliases:
 */
typealias WorkflowDependencies = HasNetwork & HasPersistence
/*:
 
 ## Conclusion
 
 Both approaches have benefits and drawbacks in dealing with dependencies. You can use them in combination with partial application or constructor-based dependency injection in order to address the specific problems you have in your case.
 */

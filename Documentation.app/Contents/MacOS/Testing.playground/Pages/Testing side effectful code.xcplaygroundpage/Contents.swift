// nef:begin:header
/*
 layout: docs
 title: Testing side effectful code
 */
// nef:end
// nef:begin:hidden
import Bow
import BowEffects
// nef:end
/*:
 # Testing side effectful code
 
 {:.intermediate}
 intermediate
 
 Although functional code is testable by definition, testing side effects is always a tricky task, as side effects are difficult to track and check. In order to address this challenge, we can replace the side effectful dependencies of our code by controllable ones where we can track the side effects that have happened.
 
 ## Abstracting over side-effectful dependencies
 
 Consider the following side-effectful operations, described in the APIs of some dependencies:
 */
typealias UserID = String

struct User: Equatable {
    let name: UserID
}

protocol DatabaseService {
    func lookUp<D>(id: UserID) -> EnvIO<D, Error, User>
    func set<D>(profile: User, forId id: UserID) -> EnvIO<D, Error, Void>
}

protocol LoggerService {
    func info<D>(_ message: String) -> EnvIO<D, Error, Void>
}
/*:
 Side-effectful dependencies are abstracted with these protocols, allowing us to replace them by controllable ones during testing. We can use these dependencies to write the following workflow:
 */
protocol HasDatabase {
    var db: DatabaseService { get }
}

protocol HasLogger {
    var logger: LoggerService { get }
}

func workflow<D: HasDatabase & HasLogger>() -> EnvIO<D, Error, User> {
    let env = EnvIO<D, Error, D>.var()
    let user = EnvIO<D, Error, User>.var()
    
    return binding(
        env <- .ask(),
        user <- env.get.db.lookUp(id: "abc"),
        |<-env.get.logger.info("Obtained: \(user.get)"),
        yield: user.get)^
}
/*:
 ## Tracking side effects
 
 Our next step is to create testing implementations for the protocols we have defined above.
 */
// nef:begin:hidden
enum DatabaseError: Error {
    case userNotFound(UserID)
}
// nef:end

struct TestDatabaseService: DatabaseService {
    
/*:
 They need to track all side effects in a way that is safe for multiple concurrent processes using this dependency. We can create a data structure to collect operations invoked in each dependency:
 */
    struct State: Equatable {
        // Contains initial DB for testing and tracks updates
        let map: [UserID: User]
        // Contains operations invoked in this dependency
        let ops: [String]
        
        private func log(_ op: String) -> State {
            State(map: self.map, ops: ops + [op])
        }
        
        func lookUp(id: UserID) -> (State, User?) {
            (log("Look up: \(id)"), map[id])
        }
        
        func set(profile: User, forId id: UserID) -> State {
            var newMap = self.map
            newMap[id] = profile
            return State(map: newMap, ops: self.ops)
                .log("Update: \(id) - \(profile)")
        }
    }
    
/*:
 We can use `IORef`, a type that models an asynchronous, concurrent mutable reference providing safe functional access and modification of its content. This reference will provide safe access to the `State` created above, while keeping track of all side effects:
 */
    let ref: IORef<Error, State>
    
    func lookUp<D>(id: UserID) -> EnvIO<D, Error, User> {
        ref.modify { state in
            state.lookUp(id: id)
        }^.env().flatMap { (user: User?) in
            (user == nil)
                ? EnvIO.raiseError(DatabaseError.userNotFound(id))
                : EnvIO.pure(user!)
        }^
    }
    
    func set<D>(profile: User, forId id: UserID) -> EnvIO<D, Error, Void> {
        ref.update { state in
            state.set(profile: profile, forId: id)
        }^.env()
    }
}

/*:
 We can proceed similarly to implement the test logger:
 */
struct TestLoggerService: LoggerService {
    let ref: IORef<Error, [String]>
    
    func info<D>(_ message: String) -> EnvIO<D, Error, Void> {
        ref.update { logs in
            logs + [message]
        }^.env()
    }
}
/*:
 ## Testing environment
 
 We need to create an environment that we can supply to the workflow. This is straighforward:
 */
struct TestEnvironment: HasDatabase, HasLogger {
    let db: DatabaseService
    let logger: LoggerService
}
/*:
 ## Writing the test scenario
 
 Our next step is to create a test scenario. The purpose of this function is that, given an initial database (represented as a dictionary), it will return an `IO` with the result of the workflow (the `User` that needs to be found), together with all tracked side effects (the `State` of the database, and the logged messages).
 
 In order to do so, we need to perform the following steps:

 - Create the `IORef` that we are providing to the test dependencies.
 - Run the workflow, providing the test environment with the corresponding dependencies.
 - Extract the values stored in the `IORef` to get the tracked side effects.
 
 The implementation of this scenario is:
 */
func testScenario(initialDB: [UserID: User]) -> IO<Error, (User, TestDatabaseService.State, [String])> {
    let dbRef = IO<Error, IORef<Error, TestDatabaseService.State>>.var()
    let logRef = IO<Error, IORef<Error, [String]>>.var()
    let user = IO<Error, User>.var()
    let state = IO<Error, TestDatabaseService.State>.var()
    let logs = IO<Error, [String]>.var()
    
    let initialState = TestDatabaseService.State(map: initialDB, ops: [])
    
    return binding(
        dbRef <- IORef.of(initialState),
        logRef <- IORef.of([]),
        user <- workflow().provide(
            TestEnvironment(
                db: TestDatabaseService(ref: dbRef.get),
                logger: TestLoggerService(ref: logRef.get)
        )),
        state <- dbRef.get.get(),
        logs <- logRef.get.get(),
        yield: (user.get, state.get, logs.get))^
}
/*:
 ## Performing assertions
 
 Finally, we can write tests changing the initial database in order to verify different behaviors of our workflow:
 */
func testUserFound() {
    let db = ["abc": User(name: "Tomás"),
              "def": User(name: "Migue")]
    let (user, state, logs) = try! testScenario(initialDB: db).unsafeRunSync()
    
    // Assert on user, state and logs
}

func testUserNotFound() {
    let error = testScenario(initialDB: [:]).unsafeRunSyncEither()
    
    // Assert on error
}
/*:
 ## Conclusions
 
 Wrapping side-effects into replaceable dependencies lets us write code in a pure funcional way. We can write test-only implementations that track side effects and let us perform assertions, giving us enough flexibility to determine the granularity of effects that we need to track.
 */

---
layout: docs
title: Handling resources
permalink: /docs/effects/handling-resources/
---

# Handling resources
 
 {:.intermediate}
 intermediate
 
 Bow Effects also provides functionality to handle resources. Working with resources usually involve acquiring, using, and releasing them regardless of the outcome of their usage.
 
 Consider, for instance, doing a query to a database, regardless of the underlying technology to implement it. It usually involves opening the database, performing the queries that you need to do, and closing the connection.
 
 We can model this with a protocol `Database` that lets us perform queries that match a predicate and two functions to open and close the database. Note that everything work under Bow Effects `IO` data type where all these effects are suspended and can be safely composed.

```swift
protocol Database {
    func queryUsers(where predicate: (User) -> Bool) -> IO<Error, [User]>
}

func openDatabase() -> IO<Error, Database>
func close(database: Database) -> IO<Error, Void>
```

 We may want to write a function were we query all users that are older than 18 years of age:

```swift
func getUsersOver18(from db: Database) -> IO<Error, [User]> {
    return db.queryUsers(where: { user in user.age >= 18 })
}
```

 Now, we can sequence the open-query-close operations using `flatMap` from `Monad`:

```swift
openDatabase().flatMap { db in
    getUsersOver18(from: db)
        .forEffect(close(database: db))
}

// Or using Monad comprehensions:
let db = IO<Error, Database>.var()
let users = IO<Error, [User]>.var()

binding(
    db    <- openDatabase(),
    users <- getUsersOver18(from: db.get),
          |<-close(database: db.get),
    yield: users.get
)
```

 However, this has a problem. The database needs to be closed **regardless** of the outcome of the operation `getUsersOver18`. However, by chaining operations monadically, the close operation will only happen if the previous operations are successful. If there is an error while performing the query, the `close(database:)` function will not be called.
 
## Bracket
 
 In order to overcome this problem and ensure proper release of the resource, regardless of the outcome of its usage, we can use the `bracket` method from the `Bracket` type class. This type class provides this and other methods to work with resources functionally.
 
 We can acquire our data base and invoke `bracket`, passing two functions: one to release the resource and one to use it:

```swift
openDatabase().bracket(release: { db in close(database: db) }) { db in
    getUsersOver18(from: db)
}
```

 `Bracket` will ensure proper acquisition and release of the resource once we have finished using it.
 
## Resource
 
 The acquire-use-release cycle is so pervasive that there is a data type in Bow Effects that models it and lets us encapsulate the acquisition and release into a single value. This data type is `Resource` and you can create one by calling its `from` method, supplying the acquire and release functions:

```swift
let dbResource = Resource.from(acquire: openDatabase,
                               release: { db, _ in close(database: db) })
```

 This resource can be used by sending a closure and it will handle opening and closing the database.

```swift
let usersOver18: IO<Error, [User]> = dbResource.use { db in
    getUsersOver18(from: db)
}^
```

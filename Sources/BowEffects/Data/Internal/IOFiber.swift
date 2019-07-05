//import Bow
//
//class IOFiber<E: Error & Equatable, A: Equatable>: Fiber<IOPartial<E>, A> {
//    static func create(promise: UnsafePromise<E, A>, conn: IOConnection<E>) -> Fiber<IOPartial<E>, A> {
//        return Fiber.create(join: {
//            IO.async { conn2, callback in
//                conn2.push(IO.invoke { /* remove callback from promise is not possible */ })
//                conn.push(conn2.cancel())
//                
//                promise.get { a in
//                    callback(a)
//                    _ = conn2.pop()
//                    _ = conn.pop()
//                }
//            }
//        },
//                            cancel: { conn.cancel() })
//    }
//}

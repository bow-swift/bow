// A Puller is the dual Monad of a Zipper

public typealias ForPuller = CoPartial<ForZipper>
public typealias PullerOf<A> = CoOf<ForZipper, A>
public typealias Puller<A> = Co<ForZipper, A>

public extension Puller where M == ForId {
    static func moveLeft() -> Puller<Void> {
        Puller { cow in cow^.moveLeft().extract()(()) }
    }
    
    static func moveRight() -> Puller<Void> {
        Puller { cow in cow^.moveRight().extract()(()) }
    }
    
    static func moveToFirst() -> Puller<Void> {
        Puller { cow in cow^.moveToFirst().extract()(()) }
    }
    
    static func moveToLast() -> Puller<Void> {
        Puller { cow in cow^.moveToLast().extract()(()) }
    }
}

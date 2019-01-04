import Foundation

public class Reader<D, A> : ReaderT<ForId, D, A> {
    public static func pure(_ a : A) -> Reader<D, A> {
        return Kleisli.pure(a, Id<A>.applicative()) as! Reader<D, A>
    }
    
    public static func ask() -> Reader<D, D> {
        return Kleisli<ForId, D, A>.ask(Id<A>.applicative()) as! Reader<D, D>
    }
    
    public init(_ run : @escaping (D) -> A) {
        super.init(run >>> Id<A>.pure)
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Reader<D, B> {
        return toReader(self.map(f, Id<A>.functor()))
    }
    
    public func ap<AA, B>(_ fa : Reader<D, AA>) -> Reader<D, B> where A == (AA) -> B {
        return toReader(self.ap(fa, Id<A>.applicative()))
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Reader<D, B>) -> Reader<D, B> {
        return toReader(self.flatMap(f, Id<A>.monad()))
    }
    
    public func zip<B>(_ other : Reader<D, B>) -> Reader<D, (A, B)> {
        return toReader(self.zip(other, Id<A>.monad()))
    }
    
    public func andThen<B>(_ other : Reader<A, B>) -> Reader<D, B> {
        return toReader(self.andThen(other, Id<A>.monad()))
    }
    
    public func andThen<B>(_ f : @escaping (A) -> Id<B>) -> Reader<D, B> {
        return toReader(self.andThen(f, Id<A>.monad()))
    }
    
    public func andThen<B>(_ other : Id<B>) -> Reader<D, B> {
        return toReader(self.andThen(other, Id<A>.monad()))
    }
    
    private func toReader<B>(_ x : Kleisli<ForId, D, B>) -> Reader<D, B> {
        return Reader<D, B>({ (d : D) in x.run(d).fix().value })
    }
}

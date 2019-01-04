import Foundation

public class ForId {}
public typealias IdOf<A> = Kind<ForId, A>

public class Id<A> : IdOf<A> {
    public let value : A
    
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    public static func tailRecM<B>(_ a : (A), _ f : (A) -> IdOf<Either<A, B>>) -> Id<B> {
        return Id<Either<A, B>>.fix(f(a)).value
            .fold({ left in tailRecM(left, f)},
                  Id<B>.pure)
    }
    
    public static func fix(_ fa : IdOf<A>) -> Id<A> {
        return fa.fix()
    }
    
    public init(_ value : A) {
        self.value = value
    }
    
    public func map<B>(_ f : (A) -> B) -> Id<B> {
        return Id<B>(f(value))
    }
    
    public func ap<AA, B>(_ fa : Id<AA>) -> Id<B> where A == (AA) -> B{
        return flatMap(fa.map)
    }
    
    public func flatMap<B>(_ f : (A) -> Id<B>) -> Id<B> {
        return f(value)
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return f(b, value)
    }
    
    public func foldRight<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return f(value, b)
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, IdOf<B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    public func coflatMap<B>(_ f : (Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    public func extract() -> A {
        return value
    }
}

public extension Kind where F == ForId {
    public func fix() -> Id<A> {
        return self as! Id<A>
    }
}

extension Id : CustomStringConvertible {
    public var description : String {
        return "Id(\(value))"
    }
}

extension Id : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "Id(\(value.debugDescription))"
    }
}

extension Id {
    public static func functor() -> IdFunctor {
        return IdFunctor()
    }
    
    public static func applicative() -> IdApplicative {
        return IdApplicative()
    }
    
    public static func monad() -> IdMonad {
        return IdMonad()
    }
    
    public static func comonad() -> IdBimonad {
        return IdBimonad()
    }
    
    public static func bimonad() -> IdBimonad {
        return IdBimonad()
    }
    
    public static func foldable() -> IdFoldable {
        return IdFoldable()
    }
    
    public static func traverse() -> IdTraverse {
        return IdTraverse()
    }

    public static func eq<EqA>(_ eqa : EqA) -> IdEq<A, EqA> {
        return IdEq<A, EqA>(eqa)
    }
}

public class IdFunctor : Functor {
    public typealias F = ForId
    
    public func map<A, B>(_ fa: IdOf<A>, _ f: @escaping (A) -> B) -> IdOf<B> {
        return fa.fix().map(f)
    }
}

public class IdApplicative : IdFunctor, Applicative {
    public func pure<A>(_ a: A) -> IdOf<A> {
        return Id.pure(a)
    }
    
    public func ap<A, B>(_ ff: IdOf<(A) -> B>, _ fa: IdOf<A>) -> IdOf<B> {
        return ff.fix().ap(fa.fix())
    }
}

public class IdMonad : IdApplicative, Monad {
    public func flatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (A) -> IdOf<B>) -> IdOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IdOf<Either<A, B>>) -> IdOf<B> {
        return Id.tailRecM(a, f)
    }
}

public class IdBimonad : IdMonad, Bimonad {
    public func coflatMap<A, B>(_ fa: IdOf<A>, _ f: @escaping (IdOf<A>) -> B) -> IdOf<B> {
        return fa.fix().coflatMap(f as (Id<A>) -> B)
    }
    
    public func extract<A>(_ fa: IdOf<A>) -> A {
        return fa.fix().extract()
    }
}

public class IdFoldable : Foldable {
    public typealias F = ForId
    
    public func foldLeft<A, B>(_ fa: IdOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: IdOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class IdTraverse : IdFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: IdOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, IdOf<B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class IdEq<B, EqB> : Eq where EqB : Eq, EqB.A == B {
    public typealias A = IdOf<B>
    
    private let eqb : EqB
    
    public init(_ eqb : EqB) {
        self.eqb = eqb
    }
    
    public func eqv(_ a: IdOf<B>, _ b: IdOf<B>) -> Bool {
        return eqb.eqv(Id.fix(a).value, Id.fix(b).value)
    }
}

extension Id : Equatable where A : Equatable {
    public static func ==(lhs : Id<A>, rhs : Id<A>) -> Bool {
        return lhs.value == rhs.value
    }
}

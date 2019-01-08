import Foundation

public class ForNonEmptyList {}
public typealias NonEmptyListOf<A> = Kind<ForNonEmptyList, A>
public typealias Nel<A> = NonEmptyList<A>

public class NonEmptyList<A> : NonEmptyListOf<A> {
    public let head : A
    public let tail : [A]
    
    public static func +(lhs : NonEmptyList<A>, rhs : NonEmptyList<A>) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }
    
    public static func +(lhs : NonEmptyList<A>, rhs : [A]) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + rhs)
    }
    
    public static func +(lhs : NonEmptyList<A>, rhs : A) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + [rhs])
    }
    
    public static func of(_ head : A, _ tail : A...) -> NonEmptyList<A> {
        return NonEmptyList(head: head, tail: tail)
    }
    
    public static func fromArray(_ array : [A]) -> Option<NonEmptyList<A>> {
        return array.isEmpty ? Option<NonEmptyList<A>>.none() : Option<NonEmptyList<A>>.some(NonEmptyList(all: array))
    }
    
    public static func fromArrayUnsafe(_ array : [A]) -> NonEmptyList<A> {
        return NonEmptyList(all: array)
    }
    
    public static func pure(_ a : A) -> NonEmptyList<A> {
        return of(a)
    }
    
    private static func go<B>(_  buf : [B], _ f : @escaping (A) -> NonEmptyListOf<Either<A, B>>, _ v : NonEmptyList<Either<A, B>>) -> [B] {
        let head = v.head
        return head.fold({ a in go(buf, f, f(a).fix() + v.tail) },
                  { b in
                    let newBuf = buf + [b]
                    let x = NonEmptyList<Either<A, B>>.fromArray(v.tail)
                    return x.fold({ newBuf },
                                  { value in go(newBuf, f, value) })
                  })
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> NonEmptyListOf<Either<A, B>>) -> NonEmptyList<B> {
        return NonEmptyList<B>.fromArrayUnsafe(go([], f, f(a).fix()))
    }
    
    public static func fix(_ fa : NonEmptyListOf<A>) -> NonEmptyList<A> {
        return fa.fix()
    }
    
    public init(head : A, tail : [A]) {
        self.head = head
        self.tail = tail
    }
    
    private init(all : [A]) {
        self.head = all[0]
        self.tail = [A](all.dropFirst(1))
    }
    
    public var count : Int {
        return 1 + tail.count
    }
    
    public let isEmpty = false
    
    public func all() -> [A] {
        return [head] + tail
    }
    
    public func map<B>(_ f : (A) -> B) -> NonEmptyList<B> {
        return NonEmptyList<B>(head: f(head), tail: tail.map(f))
    }
    
    public func flatMap<B>(_ f : (A) -> NonEmptyList<B>) -> NonEmptyList<B> {
        return f(head) + tail.flatMap{ a in f(a).all() }
    }
    
    public func ap<AA, B>(_ fa : NonEmptyList<AA>) -> NonEmptyList<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return tail.reduce(f(b, head), f)
    }
    
    public func foldRight<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return ListK<A>.foldable().foldRight(self.all().k(), b, f)
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, NonEmptyListOf<B>> where Appl : Applicative, Appl.F == G {
        let listTraverse = ListK<A>.traverse().traverse(self.all().k(), f, applicative)
        return applicative.map(listTraverse, { x in NonEmptyList<B>.fromArrayUnsafe(x.fix().asArray) })
    }
    
    public func coflatMap<B>(_ f : @escaping (NonEmptyList<A>) -> B) -> NonEmptyList<B> {
        func consume(_ list : [A], _ buf : [B] = []) -> [B] {
            if list.isEmpty {
                return buf
            } else {
                let tail = [A](list.dropFirst())
                let newBuf = buf + [f(NonEmptyList(head: list[0], tail: tail))]
                return consume(tail, newBuf)
            }
        }
        return NonEmptyList<B>(head: f(self), tail: consume(self.tail))
    }
    
    public func extract() -> A {
        return head
    }
    
    public func combineK(_ y : NonEmptyList<A>) -> NonEmptyList<A> {
        return self + y
    }
    
    public func getOrNone(_ i : Int) -> Option<A> {
        if i >= 0 && i < count {
            return Option<A>.some(all()[i])
        } else {
            return Option<A>.none()
        }
    }
}

public extension NonEmptyList where A : Equatable {
    public func contains(element : A) -> Bool {
        return head == element || tail.contains(where: { $0 == element })
    }
    
    public func containsAll(elements: [A]) -> Bool {
        return elements.map(contains).reduce(true, and)
    }
}

extension NonEmptyList : CustomStringConvertible {
    public var description : String {
        return "NonEmptyList(\(self.all())"
    }
}

extension NonEmptyList : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        let contentsString = self.all().map { x in x.debugDescription }.joined(separator: ", ")
        return "NonEmptyList(\(contentsString))"
    }
}

public extension Kind where F == ForNonEmptyList {
    public func fix() -> NonEmptyList<A> {
        return self as! NonEmptyList<A>
    }
}

public extension NonEmptyList {
    public static func functor() -> NonEmptyListFunctor {
        return NonEmptyListFunctor()
    }
    
    public static func applicative() -> NonEmptyListApplicative {
        return NonEmptyListApplicative()
    }
    
    public static func monad() -> NonEmptyListMonad {
        return NonEmptyListMonad()
    }
    
    public static func comonad() -> NonEmptyListBimonad {
        return NonEmptyListBimonad()
    }
    
    public static func bimonad() -> NonEmptyListBimonad {
        return NonEmptyListBimonad()
    }
    
    public static func foldable() -> NonEmptyListFoldable {
        return NonEmptyListFoldable()
    }
    
    public static func traverse() -> NonEmptyListTraverse {
        return NonEmptyListTraverse()
    }
    
    public static func semigroup() -> NonEmptyListSemigroup<A> {
        return NonEmptyListSemigroup<A>()
    }
    
    public static func semigroupK() -> NonEmptyListSemigroupK {
        return NonEmptyListSemigroupK()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> NonEmptyListEq<A, EqA> {
        return NonEmptyListEq<A, EqA>(eqa)
    }
}

public class NonEmptyListFunctor : Functor {
    public typealias F = ForNonEmptyList
    
    public func map<A, B>(_ fa: NonEmptyListOf<A>, _ f: @escaping (A) -> B) -> NonEmptyListOf<B> {
        return fa.fix().map(f)
    }
}

public class NonEmptyListApplicative : NonEmptyListFunctor, Applicative {
    
    public func pure<A>(_ a: A) -> NonEmptyListOf<A> {
        return NonEmptyList.pure(a)
    }
    
    public func ap<A, B>(_ ff: NonEmptyListOf<(A) -> B>, _ fa: NonEmptyListOf<A>) -> NonEmptyListOf<B> {
        return ff.fix().ap(fa.fix())
    }
}

public class NonEmptyListMonad : NonEmptyListApplicative, Monad {
    
    public func flatMap<A, B>(_ fa: NonEmptyListOf<A>, _ f: @escaping (A) -> NonEmptyListOf<B>) -> NonEmptyListOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> NonEmptyListOf<Either<A, B>>) -> NonEmptyListOf<B> {
        return NonEmptyList.tailRecM(a, f)
    }
}

public class NonEmptyListBimonad : NonEmptyListMonad, Bimonad {
    public func coflatMap<A, B>(_ fa: NonEmptyListOf<A>, _ f: @escaping (NonEmptyListOf<A>) -> B) -> NonEmptyListOf<B> {
        return fa.fix().coflatMap(f)
    }
    
    public func extract<A>(_ fa: NonEmptyListOf<A>) -> A {
        return fa.fix().extract()
    }
}

public class NonEmptyListFoldable : Foldable {
    public typealias F = ForNonEmptyList
    
    public func foldLeft<A, B>(_ fa: NonEmptyListOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: NonEmptyListOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class NonEmptyListTraverse : NonEmptyListFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: NonEmptyListOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, NonEmptyListOf<B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class NonEmptyListSemigroupK : SemigroupK {
    public typealias F = ForNonEmptyList
    
    public func combineK<A>(_ x: NonEmptyListOf<A>, _ y: NonEmptyListOf<A>) -> NonEmptyListOf<A> {
        return x.fix().combineK(y.fix())
    }
}

public class NonEmptyListSemigroup<R> : Semigroup {
    public typealias A = NonEmptyListOf<R>
    
    public func combine(_ a: NonEmptyListOf<R>, _ b: NonEmptyListOf<R>) -> NonEmptyListOf<R> {
        return NonEmptyList.fix(a) + NonEmptyList.fix(b)
    }
}

public class NonEmptyListEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = NonEmptyListOf<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: NonEmptyListOf<R>, _ b: NonEmptyListOf<R>) -> Bool {
        let a = NonEmptyList.fix(a)
        let b = NonEmptyList.fix(b)
        if a.count != b.count {
            return false
        } else {
            return zip(a.all(), b.all()).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
        }
    }
}

extension NonEmptyList : Equatable where A : Equatable {
    public static func ==(lhs : Nel<A>, rhs : Nel<A>) -> Bool {
        return lhs.all() == rhs.all()
    }
}

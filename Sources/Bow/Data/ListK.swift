import Foundation

public class ForListK {}
public typealias ListKOf<A> = Kind<ForListK, A>

public class ListK<A> : ListKOf<A> {
    fileprivate let list : [A]
    
    public static func +(lhs : ListK<A>, rhs : ListK<A>) -> ListK<A> {
        return ListK(lhs.list + rhs.list)
    }
    
    public static func pure(_ a : A) -> ListK<A> {
        return ListK([a])
    }
    
    public static func empty() -> ListK<A> {
        return ListK([])
    }
    
    private static func go<B>(_ buf : [B], _ f : (A) -> ListKOf<Either<A, B>>, _ v : ListK<Either<A, B>>) -> [B] {
        if !v.isEmpty {
            let head = v.list[0]
            return head.fold({ a in go(buf, f, ListK<Either<A, B>>(f(a).fix().list + v.list.dropFirst())) },
                      { b in
                            let newBuf = buf + [b]
                            return go(newBuf, f, ListK<Either<A, B>>([Either<A, B>](v.list.dropFirst())))
                      })
        }
        return buf
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> ListKOf<Either<A, B>>) -> ListK<B> {
        return ListK<B>(go([], f, f(a).fix()))
    }
    
    public static func fix(_ fa : ListKOf<A>) -> ListK<A> {
        return fa.fix()
    }
    
    public init(_ list : [A]) {
        self.list = list
    }
    
    public var asArray : [A] {
        return list
    }
    
    public var isEmpty : Bool {
        return list.isEmpty
    }
    
    public func map<B>(_ f : (A) -> B) -> ListK<B> {
        return ListK<B>(self.list.map(f))
    }
    
    public func ap<AA, B>(_ fa : ListK<AA>) -> ListK<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func flatMap<B>(_ f : (A) -> ListK<B>) -> ListK<B> {
        return ListK<B>(list.flatMap({ a in f(a).list }))
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return list.reduce(b, f)
    }
    
    public func foldRight<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ lkw : ListK<A>) -> Eval<B> {
            if lkw.list.isEmpty {
                return b
            } else {
                return f(lkw.list[0], Eval.deferEvaluation({ loop(ListK([A](lkw.list.dropFirst())))  }))
            }
        }
        return Eval.deferEvaluation({ loop(self) })
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, ListKOf<B>> where Appl : Applicative, Appl.F == G {
        let x = foldRight(Eval.always({ applicative.pure(ListK<B>([])) }),
                     { a, eval in applicative.map2Eval(f(a), eval, { x, y in ListK<B>([x]) + y }) }).value()
        return applicative.map(x, { a in a as ListKOf<B> })
    }
    
    public func map2<B, Z>(_ fb : ListK<B>, _ f : ((A, B)) -> Z) -> ListK<Z> {
        return self.flatMap { a in
            fb.map{ b in
                f((a, b))
            }
        }
    }
    
    public func mapFilter<B>(_ f : (A) -> OptionOf<B>) -> ListK<B> {
        return flatMap { a in f(a).fix().fold(ListK<B>.empty, ListK<B>.pure) }
    }
    
    public func combineK(_ y : ListK<A>) -> ListK<A> {
        return self + y
    }
    
    public func firstOrNone() -> Option<A> {
        if let first = asArray.first { return Option.some(first) }
        return Option.none()
    }
    
    public func getOrNone(_ i : Int) -> Option<A> {
        if i >= 0 && i < list.count {
            return Option<A>.some(list[i])
        } else {
            return Option<A>.none()
        }
    }
}

public extension Kind where F == ForListK {
    public func fix() -> ListK<A> {
        return self as! ListK<A>
    }
}

public extension Array {
    public func k() -> ListK<Element> {
        return ListK(self)
    }
}

extension ListK : CustomStringConvertible {
    public var description : String {
        let contentsString = self.list.map { x in "\(x)" }.joined(separator: ", ")
        return "ListK(\(contentsString))"
    }
}

extension ListK : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        let contentsString = self.list.map { x in x.debugDescription }.joined(separator: ", ")
        return "ListK(\(contentsString))"
    }
}

public extension ListK {
    public static func functor() -> ListKFunctor {
        return ListKFunctor()
    }
    
    public static func applicative() -> ListKApplicative {
        return ListKApplicative()
    }
    
    public static func monad() -> ListKMonad {
        return ListKMonad()
    }
    
    public static func foldable() -> ListKFoldable {
        return ListKFoldable()
    }
    
    public static func traverse() -> ListKTraverse {
        return ListKTraverse()
    }
    
    public static func semigroup() -> ListKSemigroup<A> {
        return ListKSemigroup<A>()
    }
    
    public static func semigroupK() -> ListKSemigroupK {
        return ListKSemigroupK()
    }
    
    public static func monoid() -> ListKMonoid<A> {
        return ListKMonoid<A>()
    }
    
    public static func monoidK() -> ListKMonoidK {
        return ListKMonoidK()
    }
    
    public static func functorFilter() -> ListKFunctorFilter {
        return ListKFunctorFilter()
    }
    
    public static func monadFilter() -> ListKMonadFilter {
        return ListKMonadFilter()
    }
    
    public static func monadCombine() -> ListKMonadCombine {
        return ListKMonadCombine()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> ListKEq<A, EqA> {
        return ListKEq<A, EqA>(eqa)
    }
}

public class ListKFunctor : Functor {
    public typealias F = ForListK
    
    public func map<A, B>(_ fa: ListKOf<A>, _ f: @escaping (A) -> B) -> ListKOf<B> {
        return fa.fix().map(f)
    }
}

public class ListKApplicative : ListKFunctor, Applicative {
    public func pure<A>(_ a: A) -> ListKOf<A> {
        return ListK.pure(a)
    }
    
    public func ap<A, B>(_ ff: ListKOf<(A) -> B>, _ fa: ListKOf<A>) -> ListKOf<B> {
        return ff.fix().ap(fa.fix())
    }
}

public class ListKMonad : ListKApplicative, Monad {
    public func flatMap<A, B>(_ fa: ListKOf<A>, _ f: @escaping (A) -> ListKOf<B>) -> ListKOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ListKOf<Either<A, B>>) -> ListKOf<B> {
        return ListK.tailRecM(a, f)
    }
}

public class ListKFoldable : Foldable {
    public typealias F = ForListK
    
    public func foldLeft<A, B>(_ fa: ListKOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: ListKOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class ListKTraverse : ListKFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: ListKOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ListKOf<B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class ListKSemigroupK : SemigroupK {
    public typealias F = ForListK
    
    public func combineK<A>(_ x: ListKOf<A>, _ y: ListKOf<A>) -> ListKOf<A> {
        return x.fix().combineK(y.fix())
    }
}

public class ListKMonoidK : ListKSemigroupK, MonoidK {
    public func emptyK<A>() -> ListKOf<A> {
        return ListK<A>.empty()
    }
}

public class ListKFunctorFilter : ListKFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: ListKOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> ListKOf<B> {
        return fa.fix().mapFilter(f)
    }
}

public class ListKMonadFilter : ListKMonad, MonadFilter {
    public func empty<A>() -> ListKOf<A> {
        return ListK<A>.empty()
    }
    
    public func mapFilter<A, B>(_ fa: ListKOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> ListKOf<B> {
        return fa.fix().mapFilter(f)
    }
}

public class ListKMonadCombine : ListKMonadFilter, MonadCombine {
    public func emptyK<A>() -> ListKOf<A> {
        return ListK<A>.empty()
    }
    
    public func combineK<A>(_ x: ListKOf<A>, _ y: ListKOf<A>) -> ListKOf<A> {
        return x.fix().combineK(y.fix())
    }
}

public class ListKSemigroup<R> : Semigroup {
    public typealias A = ListKOf<R>
    
    public func combine(_ a: ListKOf<R>, _ b: ListKOf<R>) -> ListKOf<R> {
        return ListK.fix(a) + ListK.fix(b)
    }
}

public class ListKMonoid<R> : ListKSemigroup<R>, Monoid {
    public var empty: ListKOf<R> {
        return ListK<R>.empty()
    }
}

public class ListKEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = ListKOf<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: ListKOf<R>, _ b: ListKOf<R>) -> Bool {
        let a = ListK.fix(a)
        let b = ListK.fix(b)
        if a.list.count != b.list.count {
            return false
        } else {
            return zip(a.list, b.list).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
        }
    }
}

public extension Array {
    public static func eq<EqR>(_ eqr : EqR) -> ArrayEq<Element, EqR> where EqR : Eq, EqR.A == Element {
        return ArrayEq(eqr)
    }
}

public class ArrayEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = Array<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: Array<R>, _ b: Array<R>) -> Bool {
        if a.count != b.count {
            return false
        } else {
            return zip(a, b).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
        }
    }
}

extension ListK : Equatable where A : Equatable {
    public static func ==(lhs : ListK<A>, rhs : ListK<A>) -> Bool {
        return lhs.list == rhs.list
    }
}

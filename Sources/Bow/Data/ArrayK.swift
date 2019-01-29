import Foundation

public class ForArrayK {}
public typealias ArrayKOf<A> = Kind<ForArrayK, A>

public class ArrayK<A> : ArrayKOf<A> {
    fileprivate let array : [A]
    
    public static func +(lhs : ArrayK<A>, rhs : ArrayK<A>) -> ArrayK<A> {
        return ArrayK(lhs.array + rhs.array)
    }
    
    public static func pure(_ a : A) -> ArrayK<A> {
        return ArrayK([a])
    }
    
    public static func empty() -> ArrayK<A> {
        return ArrayK([])
    }
    
    private static func go<B>(_ buf : [B], _ f : (A) -> ArrayKOf<Either<A, B>>, _ v : ArrayK<Either<A, B>>) -> [B] {
        if !v.isEmpty {
            let head = v.array[0]
            return head.fold({ a in go(buf, f, ArrayK<Either<A, B>>(f(a).fix().array + v.array.dropFirst())) },
                      { b in
                            let newBuf = buf + [b]
                            return go(newBuf, f, ArrayK<Either<A, B>>([Either<A, B>](v.array.dropFirst())))
                      })
        }
        return buf
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> ArrayKOf<Either<A, B>>) -> ArrayK<B> {
        return ArrayK<B>(go([], f, f(a).fix()))
    }
    
    public static func fix(_ fa : ArrayKOf<A>) -> ArrayK<A> {
        return fa.fix()
    }
    
    public init(_ array : [A]) {
        self.array = array
    }
    
    public var asArray : [A] {
        return array
    }
    
    public var isEmpty : Bool {
        return array.isEmpty
    }
    
    public func map<B>(_ f : (A) -> B) -> ArrayK<B> {
        return ArrayK<B>(self.array.map(f))
    }
    
    public func ap<AA, B>(_ fa : ArrayK<AA>) -> ArrayK<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func flatMap<B>(_ f : (A) -> ArrayK<B>) -> ArrayK<B> {
        return ArrayK<B>(array.flatMap({ a in f(a).array }))
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return array.reduce(b, f)
    }
    
    public func foldRight<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ ak : ArrayK<A>) -> Eval<B> {
            if ak.array.isEmpty {
                return b
            } else {
                return f(ak.array[0], Eval.deferEvaluation({ loop(ArrayK([A](ak.array.dropFirst())))  }))
            }
        }
        return Eval.deferEvaluation({ loop(self) })
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, ArrayKOf<B>> where Appl : Applicative, Appl.F == G {
        let x = foldRight(Eval.always({ applicative.pure(ArrayK<B>([])) }),
                     { a, eval in applicative.map2Eval(f(a), eval, { x, y in ArrayK<B>([x]) + y }) }).value()
        return applicative.map(x, { a in a as ArrayKOf<B> })
    }
    
    public func map2<B, Z>(_ fb : ArrayK<B>, _ f : ((A, B)) -> Z) -> ArrayK<Z> {
        return self.flatMap { a in
            fb.map{ b in
                f((a, b))
            }
        }
    }
    
    public func mapFilter<B>(_ f : (A) -> OptionOf<B>) -> ArrayK<B> {
        return flatMap { a in f(a).fix().fold(ArrayK<B>.empty, ArrayK<B>.pure) }
    }
    
    public func combineK(_ y : ArrayK<A>) -> ArrayK<A> {
        return self + y
    }
    
    public func firstOrNone() -> Option<A> {
        if let first = asArray.first { return Option.some(first) }
        return Option.none()
    }
    
    public func getOrNone(_ i : Int) -> Option<A> {
        if i >= 0 && i < array.count {
            return Option<A>.some(array[i])
        } else {
            return Option<A>.none()
        }
    }
}

public extension Kind where F == ForArrayK {
    public func fix() -> ArrayK<A> {
        return self as! ArrayK<A>
    }
}

public extension Array {
    public func k() -> ArrayK<Element> {
        return ArrayK(self)
    }
}

extension ArrayK : CustomStringConvertible {
    public var description : String {
        let contentsString = self.array.map { x in "\(x)" }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

extension ArrayK : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        let contentsString = self.array.map { x in x.debugDescription }.joined(separator: ", ")
        return "ArrayK(\(contentsString))"
    }
}

public extension ArrayK {
    public static func functor() -> ArrayKFunctor {
        return ArrayKFunctor()
    }
    
    public static func applicative() -> ArrayKApplicative {
        return ArrayKApplicative()
    }
    
    public static func monad() -> ArrayKMonad {
        return ArrayKMonad()
    }
    
    public static func foldable() -> ArrayKFoldable {
        return ArrayKFoldable()
    }
    
    public static func traverse() -> ArrayKTraverse {
        return ArrayKTraverse()
    }
    
    public static func semigroup() -> ArrayKSemigroup<A> {
        return ArrayKSemigroup<A>()
    }
    
    public static func semigroupK() -> ArrayKSemigroupK {
        return ArrayKSemigroupK()
    }
    
    public static func monoid() -> ArrayKMonoid<A> {
        return ArrayKMonoid<A>()
    }
    
    public static func monoidK() -> ArrayKMonoidK {
        return ArrayKMonoidK()
    }
    
    public static func functorFilter() -> ArrayKFunctorFilter {
        return ArrayKFunctorFilter()
    }
    
    public static func monadFilter() -> ArrayKMonadFilter {
        return ArrayKMonadFilter()
    }
    
    public static func monadCombine() -> ArrayKMonadCombine {
        return ArrayKMonadCombine()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> ArrayKEq<A, EqA> {
        return ArrayKEq<A, EqA>(eqa)
    }
}

public class ArrayKFunctor : Functor {
    public typealias F = ForArrayK
    
    public func map<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> B) -> ArrayKOf<B> {
        return fa.fix().map(f)
    }
}

public class ArrayKApplicative : ArrayKFunctor, Applicative {
    public func pure<A>(_ a: A) -> ArrayKOf<A> {
        return ArrayK.pure(a)
    }
    
    public func ap<A, B>(_ ff: ArrayKOf<(A) -> B>, _ fa: ArrayKOf<A>) -> ArrayKOf<B> {
        return ff.fix().ap(fa.fix())
    }
}

public class ArrayKMonad : ArrayKApplicative, Monad {
    public func flatMap<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> ArrayKOf<B>) -> ArrayKOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ArrayKOf<Either<A, B>>) -> ArrayKOf<B> {
        return ArrayK.tailRecM(a, f)
    }
}

public class ArrayKFoldable : Foldable {
    public typealias F = ForArrayK
    
    public func foldLeft<A, B>(_ fa: ArrayKOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: ArrayKOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class ArrayKTraverse : ArrayKFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ArrayKOf<B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class ArrayKSemigroupK : SemigroupK {
    public typealias F = ForArrayK
    
    public func combineK<A>(_ x: ArrayKOf<A>, _ y: ArrayKOf<A>) -> ArrayKOf<A> {
        return x.fix().combineK(y.fix())
    }
}

public class ArrayKMonoidK : ArrayKSemigroupK, MonoidK {
    public func emptyK<A>() -> ArrayKOf<A> {
        return ArrayK<A>.empty()
    }
}

public class ArrayKFunctorFilter : ArrayKFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> ArrayKOf<B> {
        return fa.fix().mapFilter(f)
    }
}

public class ArrayKMonadFilter : ArrayKMonad, MonadFilter {
    public func empty<A>() -> ArrayKOf<A> {
        return ArrayK<A>.empty()
    }
    
    public func mapFilter<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> ArrayKOf<B> {
        return fa.fix().mapFilter(f)
    }
}

public class ArrayKMonadCombine : ArrayKMonadFilter, MonadCombine {
    public func emptyK<A>() -> ArrayKOf<A> {
        return ArrayK<A>.empty()
    }
    
    public func combineK<A>(_ x: ArrayKOf<A>, _ y: ArrayKOf<A>) -> ArrayKOf<A> {
        return x.fix().combineK(y.fix())
    }
}

public class ArrayKSemigroup<R> : Semigroup {
    public typealias A = ArrayKOf<R>
    
    public func combine(_ a: ArrayKOf<R>, _ b: ArrayKOf<R>) -> ArrayKOf<R> {
        return ArrayK.fix(a) + ArrayK.fix(b)
    }
}

public class ArrayKMonoid<R> : ArrayKSemigroup<R>, Monoid {
    public var empty: ArrayKOf<R> {
        return ArrayK<R>.empty()
    }
}

public class ArrayKEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = ArrayKOf<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: ArrayKOf<R>, _ b: ArrayKOf<R>) -> Bool {
        let a = ArrayK.fix(a)
        let b = ArrayK.fix(b)
        if a.array.count != b.array.count {
            return false
        } else {
            return zip(a.array, b.array).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
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

extension ArrayK : Equatable where A : Equatable {
    public static func ==(lhs : ArrayK<A>, rhs : ArrayK<A>) -> Bool {
        return lhs.array == rhs.array
    }
}

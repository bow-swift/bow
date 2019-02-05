import Foundation

public final class ForArrayK {}
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
        func loop(_ lkw : ArrayK<A>) -> Eval<B> {
            if lkw.array.isEmpty {
                return b
            } else {
                return f(lkw.array[0], Eval.deferEvaluation({ loop(ArrayK([A](lkw.array.dropFirst())))  }))
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

extension ArrayK : Equatable where A : Equatable {
    public static func ==(lhs : ArrayK<A>, rhs : ArrayK<A>) -> Bool {
        return lhs.array == rhs.array
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
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    public static func foldable() -> FoldableInstance {
        return FoldableInstance()
    }
    
    public static func traverse() -> TraverseInstance {
        return TraverseInstance()
    }
    
    public static func semigroup() -> SemigroupInstance<A> {
        return SemigroupInstance<A>()
    }
    
    public static func semigroupK() -> SemigroupKInstance {
        return SemigroupKInstance()
    }
    
    public static func monoid() -> MonoidInstance<A> {
        return MonoidInstance<A>()
    }
    
    public static func monoidK() -> MonoidKInstance {
        return MonoidKInstance()
    }
    
    public static func functorFilter() -> FunctorFilterInstance {
        return FunctorFilterInstance()
    }
    
    public static func monadFilter() -> MonadFilterInstance {
        return MonadFilterInstance()
    }
    
    public static func monadCombine() -> MonadCombineInstance {
        return MonadCombineInstance()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, EqA> {
        return EqInstance<A, EqA>(eqa)
    }

    public class FunctorInstance : Functor {
        public typealias F = ForArrayK
        
        public func map<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> B) -> ArrayKOf<B> {
            return fa.fix().map(f)
        }
    }

    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> ArrayKOf<A> {
            return ArrayK<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: ArrayKOf<(A) -> B>, _ fa: ArrayKOf<A>) -> ArrayKOf<B> {
            return ff.fix().ap(fa.fix())
        }
    }

    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> ArrayKOf<B>) -> ArrayKOf<B> {
            return fa.fix().flatMap({ a in f(a).fix() })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ArrayKOf<Either<A, B>>) -> ArrayKOf<B> {
            return ArrayK<A>.tailRecM(a, f)
        }
    }

    public class FoldableInstance : Foldable {
        public typealias F = ForArrayK
        
        public func foldLeft<A, B>(_ fa: ArrayKOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return fa.fix().foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: ArrayKOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return fa.fix().foldRight(b, f)
        }
    }

    public class TraverseInstance : FoldableInstance, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ArrayKOf<B>> where G == Appl.F, Appl : Applicative {
            return fa.fix().traverse(f, applicative)
        }
    }

    public class SemigroupKInstance : SemigroupK {
        public typealias F = ForArrayK
        
        public func combineK<A>(_ x: ArrayKOf<A>, _ y: ArrayKOf<A>) -> ArrayKOf<A> {
            return x.fix().combineK(y.fix())
        }
    }

    public class MonoidKInstance : SemigroupKInstance, MonoidK {
        public func emptyK<A>() -> ArrayKOf<A> {
            return ArrayK<A>.empty()
        }
    }

    public class FunctorFilterInstance : FunctorInstance, FunctorFilter {
        public func mapFilter<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> ArrayKOf<B> {
            return fa.fix().mapFilter(f)
        }
    }

    public class MonadFilterInstance : MonadInstance, MonadFilter {
        public func empty<A>() -> ArrayKOf<A> {
            return ArrayK<A>.empty()
        }
        
        public func mapFilter<A, B>(_ fa: ArrayKOf<A>, _ f: @escaping (A) -> OptionOf<B>) -> ArrayKOf<B> {
            return fa.fix().mapFilter(f)
        }
    }

    public class MonadCombineInstance : MonadFilterInstance, MonadCombine {
        public func emptyK<A>() -> ArrayKOf<A> {
            return ArrayK<A>.empty()
        }
        
        public func combineK<A>(_ x: ArrayKOf<A>, _ y: ArrayKOf<A>) -> ArrayKOf<A> {
            return x.fix().combineK(y.fix())
        }
    }

    public class SemigroupInstance<R> : Semigroup {
        public typealias A = ArrayKOf<R>
        
        public func combine(_ a: ArrayKOf<R>, _ b: ArrayKOf<R>) -> ArrayKOf<R> {
            return ArrayK<R>.fix(a) + ArrayK<R>.fix(b)
        }
    }

    public class MonoidInstance<R> : SemigroupInstance<R>, Monoid {
        public var empty: ArrayKOf<R> {
            return ArrayK<R>.empty()
        }
    }

    public class EqInstance<R, EqR> : Eq where EqR : Eq, EqR.A == R {
        public typealias A = ArrayKOf<R>
        
        private let eqr : EqR
        
        init(_ eqr : EqR) {
            self.eqr = eqr
        }
        
        public func eqv(_ a: ArrayKOf<R>, _ b: ArrayKOf<R>) -> Bool {
            let a = ArrayK<R>.fix(a)
            let b = ArrayK<R>.fix(b)
            if a.array.count != b.array.count {
                return false
            } else {
                return zip(a.array, b.array).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
            }
        }
    }
}

public extension Array {
    public static func eq<EqR>(_ eqr : EqR) -> EqInstance<Element, EqR> where EqR : Eq, EqR.A == Element {
        return EqInstance(eqr)
    }

    public class EqInstance<R, EqR> : Eq where EqR : Eq, EqR.A == R {
        public typealias A = Array<R>
        
        private let eqr : EqR
        
        init(_ eqr : EqR) {
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
}

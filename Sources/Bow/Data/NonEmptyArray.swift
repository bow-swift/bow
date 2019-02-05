import Foundation

public final class ForNonEmptyArray {}
public typealias NonEmptyArrayOf<A> = Kind<ForNonEmptyArray, A>
public typealias NEA<A> = NonEmptyArray<A>

public class NonEmptyArray<A> : NonEmptyArrayOf<A> {
    public let head : A
    public let tail : [A]
    
    public static func +(lhs : NonEmptyArray<A>, rhs : NonEmptyArray<A>) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }
    
    public static func +(lhs : NonEmptyArray<A>, rhs : [A]) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + rhs)
    }
    
    public static func +(lhs : NonEmptyArray<A>, rhs : A) -> NonEmptyArray<A> {
        return NonEmptyArray(head: lhs.head, tail: lhs.tail + [rhs])
    }
    
    public static func of(_ head : A, _ tail : A...) -> NonEmptyArray<A> {
        return NonEmptyArray(head: head, tail: tail)
    }
    
    public static func fromArray(_ array : [A]) -> Option<NonEmptyArray<A>> {
        return array.isEmpty ? Option<NonEmptyArray<A>>.none() : Option<NonEmptyArray<A>>.some(NonEmptyArray(all: array))
    }
    
    public static func fromArrayUnsafe(_ array : [A]) -> NonEmptyArray<A> {
        return NonEmptyArray(all: array)
    }
    
    public static func pure(_ a : A) -> NonEmptyArray<A> {
        return of(a)
    }
    
    private static func go<B>(_  buf : [B], _ f : @escaping (A) -> NonEmptyArrayOf<Either<A, B>>, _ v : NonEmptyArray<Either<A, B>>) -> [B] {
        let head = v.head
        return head.fold({ a in go(buf, f, f(a).fix() + v.tail) },
                  { b in
                    let newBuf = buf + [b]
                    let x = NonEmptyArray<Either<A, B>>.fromArray(v.tail)
                    return x.fold({ newBuf },
                                  { value in go(newBuf, f, value) })
                  })
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> NonEmptyArrayOf<Either<A, B>>) -> NonEmptyArray<B> {
        return NonEmptyArray<B>.fromArrayUnsafe(go([], f, f(a).fix()))
    }
    
    public static func fix(_ fa : NonEmptyArrayOf<A>) -> NonEmptyArray<A> {
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
    
    public func map<B>(_ f : (A) -> B) -> NonEmptyArray<B> {
        return NonEmptyArray<B>(head: f(head), tail: tail.map(f))
    }
    
    public func flatMap<B>(_ f : (A) -> NonEmptyArray<B>) -> NonEmptyArray<B> {
        return f(head) + tail.flatMap{ a in f(a).all() }
    }
    
    public func ap<AA, B>(_ fa : NonEmptyArray<AA>) -> NonEmptyArray<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return tail.reduce(f(b, head), f)
    }
    
    public func foldRight<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return ArrayK<A>.foldable().foldRight(self.all().k(), b, f)
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, NonEmptyArrayOf<B>> where Appl : Applicative, Appl.F == G {
        let arrayTraverse = ArrayK<A>.traverse().traverse(self.all().k(), f, applicative)
        return applicative.map(arrayTraverse, { x in NonEmptyArray<B>.fromArrayUnsafe(x.fix().asArray) })
    }
    
    public func coflatMap<B>(_ f : @escaping (NonEmptyArray<A>) -> B) -> NonEmptyArray<B> {
        func consume(_ array : [A], _ buf : [B] = []) -> [B] {
            if array.isEmpty {
                return buf
            } else {
                let tail = [A](array.dropFirst())
                let newBuf = buf + [f(NonEmptyArray(head: array[0], tail: tail))]
                return consume(tail, newBuf)
            }
        }
        return NonEmptyArray<B>(head: f(self), tail: consume(self.tail))
    }
    
    public func extract() -> A {
        return head
    }
    
    public func combineK(_ y : NonEmptyArray<A>) -> NonEmptyArray<A> {
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

public extension NonEmptyArray where A : Equatable {
    public func contains(element : A) -> Bool {
        return head == element || tail.contains(where: { $0 == element })
    }
    
    public func containsAll(elements: [A]) -> Bool {
        return elements.map(contains).reduce(true, and)
    }
}

extension NonEmptyArray : CustomStringConvertible {
    public var description : String {
        return "NonEmptyArray(\(self.all())"
    }
}

extension NonEmptyArray : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        let contentsString = self.all().map { x in x.debugDescription }.joined(separator: ", ")
        return "NonEmptyArray(\(contentsString))"
    }
}

extension NonEmptyArray : Equatable where A : Equatable {
    public static func ==(lhs : NEA<A>, rhs : NEA<A>) -> Bool {
        return lhs.all() == rhs.all()
    }
}

public extension Kind where F == ForNonEmptyArray {
    public func fix() -> NonEmptyArray<A> {
        return self as! NonEmptyArray<A>
    }
}

public extension NonEmptyArray {
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    public static func comonad() -> BimonadInstance {
        return BimonadInstance()
    }
    
    public static func bimonad() -> BimonadInstance {
        return BimonadInstance()
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
    
    public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, EqA> {
        return EqInstance<A, EqA>(eqa)
    }

    public class FunctorInstance : Functor {
        public typealias F = ForNonEmptyArray
        
        public func map<A, B>(_ fa: NonEmptyArrayOf<A>, _ f: @escaping (A) -> B) -> NonEmptyArrayOf<B> {
            return fa.fix().map(f)
        }
    }

    public class ApplicativeInstance : FunctorInstance, Applicative {
        
        public func pure<A>(_ a: A) -> NonEmptyArrayOf<A> {
            return NonEmptyArray<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: NonEmptyArrayOf<(A) -> B>, _ fa: NonEmptyArrayOf<A>) -> NonEmptyArrayOf<B> {
            return ff.fix().ap(fa.fix())
        }
    }

    public class MonadInstance : ApplicativeInstance, Monad {
        
        public func flatMap<A, B>(_ fa: NonEmptyArrayOf<A>, _ f: @escaping (A) -> NonEmptyArrayOf<B>) -> NonEmptyArrayOf<B> {
            return fa.fix().flatMap({ a in f(a).fix() })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> NonEmptyArrayOf<Either<A, B>>) -> NonEmptyArrayOf<B> {
            return NonEmptyArray<A>.tailRecM(a, f)
        }
    }

    public class BimonadInstance : MonadInstance, Bimonad {
        public func coflatMap<A, B>(_ fa: NonEmptyArrayOf<A>, _ f: @escaping (NonEmptyArrayOf<A>) -> B) -> NonEmptyArrayOf<B> {
            return fa.fix().coflatMap(f)
        }
        
        public func extract<A>(_ fa: NonEmptyArrayOf<A>) -> A {
            return fa.fix().extract()
        }
    }

    public class FoldableInstance : Foldable {
        public typealias F = ForNonEmptyArray
        
        public func foldLeft<A, B>(_ fa: NonEmptyArrayOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return fa.fix().foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: NonEmptyArrayOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return fa.fix().foldRight(b, f)
        }
    }

    public class TraverseInstance : FoldableInstance, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: NonEmptyArrayOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, NonEmptyArrayOf<B>> where G == Appl.F, Appl : Applicative {
            return fa.fix().traverse(f, applicative)
        }
    }

    public class SemigroupKInstance : SemigroupK {
        public typealias F = ForNonEmptyArray
        
        public func combineK<A>(_ x: NonEmptyArrayOf<A>, _ y: NonEmptyArrayOf<A>) -> NonEmptyArrayOf<A> {
            return x.fix().combineK(y.fix())
        }
    }

    public class SemigroupInstance<R> : Semigroup {
        public typealias A = NonEmptyArrayOf<R>
        
        public func combine(_ a: NonEmptyArrayOf<R>, _ b: NonEmptyArrayOf<R>) -> NonEmptyArrayOf<R> {
            return NonEmptyArray<R>.fix(a) + NonEmptyArray<R>.fix(b)
        }
    }

    public class EqInstance<R, EqR> : Eq where EqR : Eq, EqR.A == R {
        public typealias A = NonEmptyArrayOf<R>
        
        private let eqr : EqR
        
        init(_ eqr : EqR) {
            self.eqr = eqr
        }
        
        public func eqv(_ a: NonEmptyArrayOf<R>, _ b: NonEmptyArrayOf<R>) -> Bool {
            let a = NonEmptyArray<R>.fix(a)
            let b = NonEmptyArray<R>.fix(b)
            if a.count != b.count {
                return false
            } else {
                return zip(a.all(), b.all()).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
            }
        }
    }
}

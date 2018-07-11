import Foundation

public class ForPSetter {}
public typealias PSetterOf<S, T, A, B> = Kind4<ForPSetter, S, T, A, B>

public typealias ForSetter = ForPSetter
public typealias Setter<S, A> = PSetter<S, S, A, A>
public typealias SetterPartial<S> = Kind<ForSetter, S>

public class PSetter<S, T, A, B> : PSetterOf<S, T, A, B> {
    private let modifyFunc : (S, @escaping (A) -> B) -> T
    private let setFunc : (S, B) -> T
    
    public static func +<C, D>(lhs : PSetter<S, T, A, B>, rhs : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PSetter<S, T, A, B>, rhs : POptional<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PSetter<S, T, A, B>, rhs : PPrism<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PSetter<S, T, A, B>, rhs : PLens<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PSetter<S, T, A, B>, rhs : PIso<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PSetter<S, T, A, B>, rhs : PTraversal<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func identity() -> Setter<S, S> {
        return Iso<S, S>.identity().asSetter()
    }
    
    public static func codiagonal() -> Setter<Either<S, S>, S> {
        return Setter<Either<S, S>, S>(modify: { f in { ss in ss.bimap(f, f) } })
    }
    
    public static func fromFunctor<Func, F>(_ functor : Func) -> PSetter<Kind<F, A>, Kind<F, B>, A, B> where Func : Functor, Func.F == F {
        return PSetter<Kind<F, A>, Kind<F, B>, A, B>(modify: { f in
            { fs in functor.map(fs, f) }
        })
    }
    
    public init(modify : @escaping (S, @escaping (A) -> B) -> T, set : @escaping (S, B) -> T) {
        self.modifyFunc = modify
        self.setFunc = set
    }
    
    public init(modify : @escaping (@escaping (A) -> B) -> (S) -> T) {
        self.modifyFunc = { s, f in modify(f)(s) }
        self.setFunc = { s, b in modify(constant(b))(s) }
    }
    
    public func modify(_ s : S, _ f : @escaping (A) -> B) -> T {
        return self.modifyFunc(s, f)
    }
    
    public func set(_ s : S, _ b : B) -> T {
        return self.setFunc(s, b)
    }
    
    public func choice<S1, T1>(_ other : PSetter<S1, T1, A, B>) -> PSetter<Either<S, S1>, Either<T, T1>, A, B> {
        return PSetter<Either<S, S1>, Either<T, T1>, A, B>(modify: { f in
            { either in
                either.bimap({ s in self.modify(s, f) }, { s in other.modify(s, f) })
            }
        })
    }
    
    public func lift(_ f : @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    public func compose<C, D>(_ other : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return PSetter<S, T, C, D>(modify: { f in
            { s in
                self.modify(s) { a in other.modify(a, f) }
            }
        })
    }
    
    public func compose<C, D>(_ other : POptional<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter())
    }
    
    public func compose<C, D>(_ other : PPrism<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter())
    }
    
    public func compose<C, D>(_ other : PLens<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter())
    }
    
    public func compose<C, D>(_ other : PIso<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter())
    }
    
    public func compose<C, D>(_ other : PTraversal<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.compose(other.asSetter())
    }
}

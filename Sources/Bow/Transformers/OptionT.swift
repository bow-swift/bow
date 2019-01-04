import Foundation

public class ForOptionT {}
public typealias OptionTOf<F, A> = Kind2<ForOptionT, F, A>
public typealias OptionTPartial<F> = Kind<ForOptionT, F>

public class OptionT<F, A> : OptionTOf<F, A> {
    fileprivate let value : Kind<F, Option<A>>
    
    public static func pure<Appl>(_ a : A, _ applicative : Appl) -> OptionT<F, A> where Appl : Applicative, Appl.F == F {
        return OptionT(applicative.pure(Option.pure(a)))
    }
    
    public static func none<Appl>(_ applicative : Appl) -> OptionT<F, A> where Appl : Applicative, Appl.F == F {
        return OptionT(applicative.pure(Option.none()))
    }
    
    public static func fromOption<Appl>(_ option : Option<A>, _ applicative : Appl) -> OptionT<F, A> where Appl : Applicative, Appl.F == F {
        return OptionT(applicative.pure(option))
    }
    
    public static func tailRecM<B, MonF>(_ a : A, _ f : @escaping (A) -> OptionTOf<F, Either<A, B>>, _ monad : MonF) -> OptionTOf<F, B> where MonF : Monad, MonF.F == F {
        
        return OptionT<F, B>(monad.tailRecM(a, { aa in
            monad.map(OptionT<F, Either<A, B>>.fix(f(aa)).value, { option in
                option.fold({ Either<A, Option<B>>.right(Option<B>.none())},
                            { either in either.map(Option<B>.some) })
            })
        }))
    }
    
    public static func fix(_ fa : OptionTOf<F, A>) -> OptionT<F, A> {
        return fa as! OptionT<F, A>
    }
    
    public init(_ value : Kind<F, Option<A>>) {
        self.value = value
    }
    
    public func fold<B, Func>(_ ifEmpty : @escaping () -> B, _ f : @escaping (A) -> B, _ functor : Func) -> Kind<F, B> where Func : Functor, Func.F == F {
        return functor.map(value, { option in option.fold(ifEmpty, f) })
    }
    
    public func cata<B, Func>(_ ifEmpty : @escaping () -> B, _ f : @escaping (A) -> B, _ functor : Func) -> Kind<F, B> where Func : Functor, Func.F == F {
        return fold(ifEmpty, f, functor)
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> OptionT<F, B> where Func : Functor, Func.F == F {
        return OptionT<F, B>(functor.map(value, { option in option.map(f) } ))
    }
    
    public func ap<AA, B, Mon>(_ fa : OptionT<F, AA>, _ monad : Mon) -> OptionT<F, B> where Mon : Monad, Mon.F == F, A == (AA) -> B {
        return flatMap({ f in fa.map(f, monad) }, monad)
    }
    
    public func flatMap<B, Mon>(_ f : @escaping (A) -> OptionT<F, B>, _ monad : Mon) -> OptionT<F, B> where Mon : Monad, Mon.F == F {
        return flatMapF({ a in f(a).value }, monad)
    }
    
    public func flatMapF<B, Mon>(_ f : @escaping (A) -> Kind<F, Option<B>>, _ monad : Mon) -> OptionT<F, B> where Mon : Monad, Mon.F == F {
        return OptionT<F, B>(monad.flatMap(value, { option in option.fold({ monad.pure(Option<B>.none()) }, f)}))
    }
    
    public func liftF<B, Func>(_ fb : Kind<F, B>, _ functor : Func) -> OptionT<F, B> where Func : Functor, Func.F == F {
        return OptionT<F, B>(functor.map(fb, { b in Option<B>.some(b) }))
    }
    
    public func semiflatMap<B, Mon>(_ f : @escaping (A) -> Kind<F, B>, _ monad : Mon) -> OptionT<F, B> where Mon : Monad, Mon.F == F {
        return flatMap({ option in self.liftF(f(option), monad)}, monad)
    }
    
    public func getOrElse<Func>(_ defaultValue : A, _ functor : Func) -> Kind<F, A> where Func : Functor, Func.F == F {
        return functor.map(value, { option in option.getOrElse(defaultValue) })
    }
    
    public func getOrElseF<Mon>(_ defaultValue : Kind<F, A>, _ monad : Mon) -> Kind<F, A> where Mon : Monad, Mon.F == F {
        return monad.flatMap(value, { option in option.fold(constant(defaultValue), monad.pure)})
    }
    
    public func filter<Func>(_ predicate : @escaping (A) -> Bool, _ functor : Func) -> OptionT<F, A> where Func : Functor, Func.F == F {
        return OptionT(functor.map(value, { option in option.filter(predicate) }))
    }
    
    public func forall<Func>(_ predicate : @escaping (A) -> Bool, _ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { option in option.forall(predicate) })
    }
    
    public func isDefined<Func>(_ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { option in option.isDefined })
    }
    
    public func isEmpty<Func>(_ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { option in option.isEmpty })
    }
    
    public func orElse<Mon>(_ defaultValue : OptionT<F, A>, _ monad : Mon) -> OptionT<F, A> where Mon : Monad, Mon.F == F {
        return orElseF(defaultValue.value, monad)
    }
    
    public func orElseF<Mon>(_ defaultValue : Kind<F, Option<A>>, _ monad : Mon) -> OptionT<F, A> where Mon : Monad, Mon.F == F {
        return OptionT<F, A>(monad.flatMap(value, { option in
            option.fold(constant(defaultValue),
                        { _ in monad.pure(option) }) }))
    }
    
    public func transform<B, Func>(_ f : @escaping (Option<A>) -> Option<B>, _ functor : Func) -> OptionT<F, B> where Func : Functor, Func.F == F {
        return OptionT<F, B>(functor.map(value, f))
    }
    
    public func subflatMap<B, Func>(_ f : @escaping (A) -> Option<B>, _ functor : Func) -> OptionT<F, B> where Func : Functor, Func.F == F {
        return transform({ option in option.flatMap(f) }, functor)
    }
    
    public func mapFilter<B, Func>(_ f : @escaping (A) -> OptionOf<B>, _ functor : Func) -> OptionT<F, B> where Func : Functor, Func.F == F {
        return OptionT<F, B>(functor.map(value, { option in option.flatMap({ x in f(x).fix() }) }))
    }
}

public extension OptionT {
    public static func functor<FuncF>(_ functor : FuncF) -> OptionTFunctor<F, FuncF> {
        return OptionTFunctor<F, FuncF>(functor)
    }
    
    public static func functorFilter<FuncF>(_ functor : FuncF) -> OptionTFunctorFilter<F, FuncF> {
        return OptionTFunctorFilter<F, FuncF>(functor)
    }
    
    public static func applicative<MonF>(_ monad : MonF) -> OptionTApplicative<F, MonF> {
        return OptionTApplicative<F, MonF>(monad)
    }
    
    public static func monad<MonF>(_ monad : MonF) -> OptionTMonad<F, MonF> {
        return OptionTMonad<F, MonF>(monad)
    }
    
    public static func semigroupK<MonF>(_ monad : MonF) -> OptionTSemigroupK<F, MonF> {
        return OptionTSemigroupK<F, MonF>(monad)
    }
    
    public static func monoidK<MonF>(_ monad : MonF) -> OptionTMonoidK<F, MonF> {
        return OptionTMonoidK<F, MonF>(monad)
    }
    
    public static func eq<EqA, Func>(_ eq : EqA, _ functor : Func) -> OptionTEq<F, A, EqA, Func> {
        return OptionTEq<F, A, EqA, Func>(eq, functor)
    }
}

public class OptionTFunctor<G, FuncG> : Functor where FuncG : Functor, FuncG.F == G {
    public typealias F = OptionTPartial<G>
    
    fileprivate let functor : FuncG
    
    public init(_ functor : FuncG) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: OptionTOf<G, A>, _ f: @escaping (A) -> B) -> OptionTOf<G, B> {
        return OptionT.fix(fa).map(f, functor)
    }
}

public class OptionTFunctorFilter<G, FuncG> : OptionTFunctor<G, FuncG>, FunctorFilter where FuncG : Functor, FuncG.F == G {
    
    public func mapFilter<A, B>(_ fa: OptionTOf<G, A>, _ f: @escaping (A) -> OptionOf<B>) -> OptionTOf<G, B> {
        return OptionT.fix(fa).mapFilter(f, functor)
    }
}

public class OptionTApplicative<G, MonG> : OptionTFunctor<G, MonG>, Applicative where MonG : Monad, MonG.F == G {
    
    fileprivate let monad : MonG
    
    override public init(_ monad : MonG) {
        self.monad = monad
        super.init(monad)
    }
    
    public func pure<A>(_ a: A) -> OptionTOf<G, A> {
        return OptionT.pure(a, monad)
    }
    
    public func ap<A, B>(_ ff: OptionTOf<G, (A) -> B>, _ fa: OptionTOf<G, A>) -> OptionTOf<G, B> {
        return OptionT.fix(ff).ap(OptionT.fix(fa), monad)
    }
}

public class OptionTMonad<G, MonG> : OptionTApplicative<G, MonG>, Monad where MonG : Monad, MonG.F == G {
    
    public func flatMap<A, B>(_ fa: OptionTOf<G, A>, _ f: @escaping (A) -> OptionTOf<G, B>) -> OptionTOf<G, B> {
        return OptionT.fix(fa).flatMap({ a in OptionT.fix(f(a)) }, monad)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> OptionTOf<G, Either<A, B>>) -> OptionTOf<G, B> {
        return OptionT.tailRecM(a, f, monad)
    }
}

public class OptionTSemigroupK<G, MonG> : SemigroupK where MonG : Monad, MonG.F == G {
    public typealias F = OptionTPartial<G>
    
    fileprivate let monad : MonG
    
    public init(_ monad : MonG) {
        self.monad = monad
    }
    
    public func combineK<A>(_ x: OptionTOf<G, A>, _ y: OptionTOf<G, A>) -> OptionTOf<G, A> {
        return OptionT.fix(x).orElse(OptionT.fix(y), monad)
    }
}

public class OptionTMonoidK<G, MonG> : OptionTSemigroupK<G, MonG>, MonoidK where MonG : Monad, MonG.F == G {
    public func emptyK<A>() -> OptionTOf<G, A> {
        return OptionT(monad.pure(Option.none()))
    }
}

public class OptionTEq<F, B, EqF, Func> : Eq where EqF : Eq, EqF.A == Kind<F, OptionOf<B>>, Func : Functor, Func.F == F {
    public typealias A = OptionTOf<F, B>
    
    private let eq : EqF
    private let functor : Func
    
    public init(_ eq : EqF, _ functor : Func) {
        self.eq = eq
        self.functor = functor
    }
    
    public func eqv(_ a: OptionTOf<F, B>, _ b: OptionTOf<F, B>) -> Bool {
        let a = OptionT.fix(a)
        let b = OptionT.fix(b)
        return eq.eqv(functor.map(a.value, { aa in aa as OptionOf<B> }),
                      functor.map(b.value, { bb in bb as OptionOf<B> }))
    }
}

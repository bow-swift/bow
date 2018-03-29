//
//  Coproduct.swift
//  Bow
//
//  Created by Tomás Ruiz López on 10/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class CoproductF {}
public typealias CoproductPartial<F, G> = HK2<CoproductF, F, G>

public class Coproduct<F, G, A> : HK3<CoproductF, F, G, A> {
    fileprivate let run : Either<HK<F, A>, HK<G, A>>
    
    public static func ev(_ fa : HK3<CoproductF, F, G, A>) -> Coproduct<F, G, A> {
        return fa as! Coproduct<F, G, A>
    }
    
    public init(_ run : Either<HK<F, A>, HK<G, A>>) {
        self.run = run
    }
    
    public func map<FuncF, FuncG, B>(_ functorF : FuncF, _ functorG : FuncG, _ f : @escaping (A) -> B) -> Coproduct<F, G, B> where FuncF : Functor, FuncF.F == F, FuncG : Functor, FuncG.F == G {
        return Coproduct<F, G, B>(run.bimap(functorF.lift(f), functorG.lift(f)))
    }
    
    public func coflatMap<ComonF, ComonG, B>(_ comonadF : ComonF, _ comonadG : ComonG, _ f : @escaping (Coproduct<F, G, A>) -> B) -> Coproduct<F, G, B> where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        return Coproduct<F, G, B>(run.bimap({ left in
            comonadF.coflatMap(left, { a in f(Coproduct(Either.left(a))) })},
                                            { right in
            comonadG.coflatMap(right, { b in f(Coproduct(Either.right(b))) })
        }))
    }
    
    public func extract<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> A where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        return run.fold(comonadF.extract, comonadG.extract)
    }
    
    public func fold<H, FuncKF, FuncKG>(_ f : FuncKF, _ g : FuncKG) -> HK<H, A> where FuncKF : FunctionK, FuncKF.F == F, FuncKF.G == H, FuncKG : FunctionK, FuncKG.F == G, FuncKG.G == H {
        return run.fold({ fa in f.invoke(fa) }, { ga in g.invoke(ga) })
    }
    
    public func foldL<B, FoldF, FoldG>(_ b : B, _ f : @escaping (B, A) -> B, _ foldableF : FoldF, _ foldableG : FoldG) -> B where FoldF : Foldable, FoldF.F == F, FoldG : Foldable, FoldG.F == G {
        return run.fold({ fa in foldableF.foldL(fa, b, f) },
                        { ga in foldableG.foldL(ga, b, f) })
    }
    
    public func foldR<B, FoldF, FoldG>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>, _ foldableF : FoldF, _ foldableG : FoldG) -> Eval<B> where FoldF : Foldable, FoldF.F == F, FoldG : Foldable, FoldG.F == G {
        return run.fold({ fa in foldableF.foldR(fa, b, f) },
                        { ga in foldableG.foldR(ga, b, f) })
    }
    
    public func traverse<B, H, Appl, TravF, TravG>(_ f : @escaping (A) -> HK<H, B>, _ applicative : Appl, _ traverseF : TravF, _ traverseG : TravG) -> HK<H, HK3<CoproductF, F, G, B>> where Appl : Applicative, Appl.F == H, TravF : Traverse, TravF.F == F, TravG : Traverse, TravG.F == G {
        return run.fold({ fa in applicative.map(traverseF.traverse(fa, f, applicative), { fb in
            Coproduct<F, G, B>(Either.left(fb)) } ) },
                        { ga in applicative.map(traverseG.traverse(ga, f, applicative), { gb in Coproduct<F, G, B>(Either.right(gb)) } ) })
    }
}

public extension Coproduct {
    public static func functor<FuncF, FuncG>(_ functorF : FuncF, _ functorG : FuncG) -> CoproductFunctor<F, G, FuncF, FuncG> {
        return CoproductFunctor<F, G, FuncF, FuncG>(functorF, functorG)
    }
    
    public static func comonad<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> CoproductComonad<F, G, ComonF, ComonG> {
        return CoproductComonad<F, G, ComonF, ComonG>(comonadF, comonadG)
    }
    
    public static func foldable<FoldF, FoldG>(_ foldableF : FoldF, _ foldableG : FoldG) -> CoproductFoldable<F, G, FoldF, FoldG> {
        return CoproductFoldable<F, G, FoldF, FoldG>(foldableF, foldableG)
    }
    
    public static func traverse<TravF, TravG>(_ traverseF : TravF, _ traverseG : TravG) -> CoproductTraverse<F, G, TravF, TravG>{
        return CoproductTraverse<F, G, TravF, TravG>(traverseF, traverseG)
    }
    
    public static func eq<EqA>(_ eq : EqA) -> CoproductEq<F, G, A, EqA> {
        return CoproductEq<F, G, A, EqA>(eq)
    }
}

public class CoproductFunctor<G, H, FuncG, FuncH> : Functor where FuncG : Functor, FuncG.F == G, FuncH : Functor, FuncH.F == H {
    public typealias F = CoproductPartial<G, H>
    
    private let functorG : FuncG
    private let functorH : FuncH
    
    public init(_ functorG : FuncG, _ functorH : FuncH) {
        self.functorG = functorG
        self.functorH = functorH
    }
    
    public func map<A, B>(_ fa: HK<HK<HK<CoproductF, G>, H>, A>, _ f: @escaping (A) -> B) -> HK<HK<HK<CoproductF, G>, H>, B> {
        return Coproduct.ev(fa).map(functorG, functorH, f)
    }
}

public class CoproductComonad<G, H, ComonG, ComonH> : CoproductFunctor<G, H, ComonG, ComonH>, Comonad where ComonG : Comonad, ComonG.F == G, ComonH : Comonad, ComonH.F == H {
    
    private let comonadG : ComonG
    private let comonadH : ComonH
    
    override public init(_ comonadG : ComonG, _ comonadH : ComonH) {
        self.comonadG = comonadG
        self.comonadH = comonadH
        super.init(comonadG, comonadH)
    }
    
    public func coflatMap<A, B>(_ fa: HK<HK<HK<CoproductF, G>, H>, A>, _ f: @escaping (HK<HK<HK<CoproductF, G>, H>, A>) -> B) -> HK<HK<HK<CoproductF, G>, H>, B> {
        return Coproduct.ev(fa).coflatMap(comonadG, comonadH, f)
    }
    
    public func extract<A>(_ fa: HK<HK<HK<CoproductF, G>, H>, A>) -> A {
        return Coproduct.ev(fa).extract(comonadG, comonadH)
    }
}

public class CoproductFoldable<G, H, FoldG, FoldH> : Foldable where FoldG : Foldable, FoldG.F == G, FoldH : Foldable, FoldH.F == H {
    public typealias F = CoproductPartial<G, H>
    
    private let foldableG : FoldG
    private let foldableH : FoldH
    
    public init(_ foldableG : FoldG, _ foldableH : FoldH) {
        self.foldableG = foldableG
        self.foldableH = foldableH
    }
    
    public func foldL<A, B>(_ fa: HK<HK<HK<CoproductF, G>, H>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Coproduct.ev(fa).foldL(b, f, foldableG, foldableH)
    }
    
    public func foldR<A, B>(_ fa: HK<HK<HK<CoproductF, G>, H>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Coproduct.ev(fa).foldR(b, f, foldableG, foldableH)
    }
}

public class CoproductTraverse<G, H, TravG, TravH> : CoproductFoldable<G, H, TravG, TravH>, Traverse where TravG : Traverse, TravG.F == G, TravH : Traverse, TravH.F == H {
    
    private let traverseG : TravG
    private let traverseH : TravH
    
    override public init(_ traverseG : TravG, _ traverseH : TravH) {
        self.traverseG = traverseG
        self.traverseH = traverseH
        super.init(traverseG, traverseH)
    }
    
    public func traverse<I, A, B, Appl>(_ fa: HK<HK<HK<CoproductF, G>, H>, A>, _ f: @escaping (A) -> HK<I, B>, _ applicative: Appl) -> HK<I, HK<HK<HK<CoproductF, G>, H>, B>> where I == Appl.F, Appl : Applicative {
        return Coproduct.ev(fa).traverse(f, applicative, traverseG, traverseH)
    }
}

public class CoproductEq<F, G, B, EqB> : Eq where EqB : Eq, EqB.A == HK2<EitherF, HK<F, B>, HK<G, B>>{
    public typealias A = HK3<CoproductF, F, G, B>
    
    private let eq : EqB
    
    public init(_ eq : EqB) {
        self.eq = eq
    }
    
    public func eqv(_ a: HK<HK<HK<CoproductF, F>, G>, B>, _ b: HK<HK<HK<CoproductF, F>, G>, B>) -> Bool {
        let a = Coproduct.ev(a)
        let b = Coproduct.ev(b)
        return eq.eqv(a.run, b.run)
    }
}

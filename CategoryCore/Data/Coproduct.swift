//
//  Coproduct.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 10/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class CoproductF {}

public class Coproduct<F, G, A> : HK3<CoproductF, F, G, A> {
    private let run : Either<HK<F, A>, HK<G, A>>
    
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
    
    public func traverse<B, H, Appl, TravF, TravG>(_ f : (A) -> HK<H, B>, _ applicative : Appl, _ traverseF : TravF, _ traverseG : TravG) -> HK<H, Coproduct<F, G, B>> where Appl : Applicative, Appl.F == H, TravF : Traverse, TravF.F == F, TravG : Traverse, TravG.F == G {
        return run.fold({ fa in applicative.map(traverseF.traverse(fa, f, applicative), { fb in
            Coproduct<F, G, B>(Either.left(fb)) } ) },
                        { ga in applicative.map(traverseG.traverse(ga, f, applicative), { gb in Coproduct<F, G, B>(Either.right(gb)) } ) })
    }
}

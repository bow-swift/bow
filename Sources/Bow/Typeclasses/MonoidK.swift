//
//  MonoidK.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol MonoidK : SemigroupK {
    func emptyK<A>() -> Kind<F, A>
}

public extension MonoidK {
    func algebra<B>() -> MonoidAlgebra<F, B> {
        return MonoidAlgebra(combineK: self.combineK, emptyK: self.emptyK)
    }
}

public class MonoidAlgebra<F, B> : SemigroupAlgebra<F, B>, Monoid {
    private let emptyK : () -> Kind<F, B>
    
    init(combineK: @escaping (Kind<F, B>, Kind<F, B>) -> Kind<F, B>, emptyK : @escaping () -> Kind<F, B>) {
        self.emptyK = emptyK
        super.init(combineK: combineK)
    }
    
    public var empty: Kind<F, B> {
        return emptyK()
    }
}

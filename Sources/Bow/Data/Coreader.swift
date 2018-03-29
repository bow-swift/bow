//
//  Coreader.swift
//  Bow
//
//  Created by Tomás Ruiz López on 5/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class Coreader<A, B> : CoreaderT<IdF, A, B> {
    public init(_ run : @escaping (A) -> B) {
        super.init({ idA in run((idA as! Id<A>).extract()) })
    }
    
    public func runId(_ a : A) -> B {
        return self.run(Id<A>.pure(a))
    }
}

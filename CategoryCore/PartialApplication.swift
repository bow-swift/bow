//
//  PartialApplication.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

infix operator |> : AdditionPrecedence

public func |><A, B>(_ a : A, _ f : (A) -> B) -> B {
    return f(a)
}


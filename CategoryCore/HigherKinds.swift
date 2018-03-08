//
//  HigherKinds.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

open class HK<F, A> {}
public typealias HK2<F, A, B> = HK<HK<F, A>, B>
public typealias HK3<F, A, B, C> = HK<HK2<F, A, B>, C>
public typealias HK4<F, A, B, C, D> = HK<HK3<F, A, B, C>, D>
public typealias HK5<F, A, B, C, D, E> = HK<HK4<F, A, B, C, D>, E>

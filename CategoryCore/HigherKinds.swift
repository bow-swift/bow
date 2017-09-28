//
//  HigherKinds.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

protocol HK {
    associatedtype Witness
    associatedtype DataType
}

protocol HK2 {
    associatedtype Witness
    associatedtype DataType1
    associatedtype DataType2
}

protocol HK3 {
    associatedtype Witness
    associatedtype DataType1
    associatedtype DataType2
    associatedtype DataType3
}

protocol HK4 {
    associatedtype Witness
    associatedtype DataType1
    associatedtype DataType2
    associatedtype DataType3
    associatedtype DataType4
}

protocol HK5 {
    associatedtype Witness
    associatedtype DataType1
    associatedtype DataType2
    associatedtype DataType3
    associatedtype DataType4
    associatedtype DataType5
}

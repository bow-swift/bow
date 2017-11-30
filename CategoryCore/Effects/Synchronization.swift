//
//  Synchronization.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

func synced(_ lock: Any, closure: () throws -> ()) throws {
    objc_sync_enter(lock)
    try closure()
    objc_sync_exit(lock)
}

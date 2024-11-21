//
//  RealmExtension.swift
//  YippiCore
//
//  Created by Francis Yeap on 14/10/2020.
//  Copyright © 2020 Chew. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

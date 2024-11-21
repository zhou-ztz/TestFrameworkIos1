//
//  UserInfoModelWallet.swift
//  Yippi
//
//  Created by Francis on 23/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import RealmSwift

class UserInfoModelWallet: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var userIdentity: Int = 0
    @objc dynamic var balance: Int = 0
    @objc dynamic var deleteDate: String? = ""
    @objc dynamic var updateDate: String? = ""
    @objc dynamic var createDate: String? = ""
    
    override static func indexedProperties() -> [String] {
        return ["id", "userIdentity"]
    }
    
}

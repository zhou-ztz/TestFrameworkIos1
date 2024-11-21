// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityUserVerified: Object {
    @objc dynamic var type: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var desc: String = ""

    @objc dynamic var userIdentity: Int = 0
    
    override class func primaryKey() -> String? { return "userIdentity" }
    
    convenience init?(model: TSUserVerifiedModel?, userIdentity: Int = 0) {
        guard let model = model else { return nil }

        self.init()
        
        self.userIdentity = userIdentity
        // String
        self.type = model.type
        // String
        self.icon = model.icon
        // String
        self.desc = model.description

    }

}

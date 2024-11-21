// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityTag: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var categoryId: Int = 0
    @objc dynamic var isSelected: Bool = false


    convenience init?(model: TSTagModel?) {
        guard let model = model else { return nil }

        self.init()

        // Int
        self.id = model.id
        // String
        self.name = model.name
        // Int
        self.categoryId = model.categoryId
        // Bool
        self.isSelected = model.isSelected

    }

}

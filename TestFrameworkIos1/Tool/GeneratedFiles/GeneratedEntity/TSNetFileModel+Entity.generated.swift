// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityNetFile: Object {
    @objc dynamic var vendor: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var mime: String = ""
    @objc dynamic var size: Int = 0
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0


    convenience init?(model: TSNetFileModel?) {
        guard let model = model else { return nil }

        self.init()

        // String
        self.vendor = model.vendor
        // String
        self.url = model.url
        // String
        self.mime = model.mime
        // Int
        self.size = model.size
        // Int
        self.width = model.width
        // Int
        self.height = model.height

    }

}

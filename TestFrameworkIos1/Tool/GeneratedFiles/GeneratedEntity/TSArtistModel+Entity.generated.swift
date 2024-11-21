// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityArtist: Object {
    @objc dynamic var artist_id: Int = 0
    @objc dynamic var artist_name: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var banner: String = ""
    @objc dynamic var uid: Int = 0
    @objc dynamic var created_at: String = ""
    @objc dynamic var updated_at: String = ""
    @objc dynamic var hide_view_moment: Bool = false


    convenience init?(model: TSArtistModel?) {
        guard let model = model else { return nil }

        self.init()

        // Int
        self.artist_id = model.artist_id
        // String
        self.artist_name = model.artist_name
        // String
        self.desc = model.description
        // String
        self.icon = model.icon
        // String
        self.banner = model.banner
        // Int
        self.uid = model.uid
        // String
        self.created_at = model.created_at
        // String
        self.updated_at = model.updated_at
        // Bool
        self.hide_view_moment = model.hide_view_moment

    }

}

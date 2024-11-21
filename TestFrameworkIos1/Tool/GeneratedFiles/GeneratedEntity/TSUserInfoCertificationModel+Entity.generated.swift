// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityUserInfoCertification: Object {
    @objc dynamic var autoUpgradeDialog: Bool = false


    convenience init?(model: TSUserInfoCertificationModel?) {
        guard let model = model else { return nil }

        self.init()

        // Bool
        self.autoUpgradeDialog = model.autoUpgradeDialog

    }

}

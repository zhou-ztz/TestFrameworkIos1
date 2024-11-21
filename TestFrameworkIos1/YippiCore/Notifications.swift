import Foundation

// Shared between Swift and Obj-C Project
@objcMembers
public class NotificationKeys: NSObject {
    public static let forceLoggedOut = "yippi.session.forceLoggedOut"
}

extension Notification.Name {
    public struct App {
        public static let forceUpdateRequired = Notification.Name(rawValue: "yippi.app.forceUpdateRequired")
        
        public static let showAnnouncement = Notification.Name("yippi.app.showAnnouncement")
        
    }
    
    public struct Session {
        public static let forceLoggedOut = Notification.Name(rawValue: NotificationKeys.forceLoggedOut)
    }
}

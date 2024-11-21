//
//  SessionPeekNavigationViewController.swift
//  Yippi
//
//  Created by Khoo on 11/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
//import NIMPrivate

class SessionPeekViewController: BaseViewController {
//    var config : NIMSessionConfig
    
//    override init(session: NIMSession?) {
//        self.config = SessionPeekSessionConfig()
//        super.init(session:session)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class SessionPeekNavigationViewController: UINavigationController {
    var session : NIMSession?
    var recent : NIMRecentSession?

   class func instance(_ session: NIMSession?) -> SessionPeekNavigationViewController {
//        let vc = SessionPeekViewController(session: session)
//        let nav = SessionPeekNavigationViewController(rootViewController: vc)
       return SessionPeekNavigationViewController(rootViewController: UIViewController())
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        recent = findRecentSession()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let action1 = UIPreviewAction(title: "mark_as_read".localized, style: .default, handler: { action, previewViewController in
            guard let session = self.recent?.session else { return }
            NIMSDK.shared().conversationManager.markAllMessagesRead(in: session)
        })

        let action2 = UIPreviewAction(title: "delete_conversation".localized, style: .destructive, handler: { action, previewViewController in
            guard let recent = self.recent else { return }
            NIMSDK.shared().conversationManager.delete(recent)
        })

        return [action1, action2]
    }
    
    func findRecentSession() -> NIMRecentSession? {
//        let vc = topViewController as? NIMSessionViewController
//        let session = vc?.session
//        if let recents = NIMSDK.shared().conversationManager.allRecentSessions() {
//            for recent in recents {
//                guard let session = recent.session else {
//                    continue
//                }
//                if (session.sessionId == session.sessionId) && session.sessionType == session.sessionType {
//                    return recent
//                }
//            }
//        }
        
        return nil
    }

}

class SessionPeekSessionConfig: NSObject {
   func disableAutoMarkMessageRead() -> Bool {
       return true
   }
}

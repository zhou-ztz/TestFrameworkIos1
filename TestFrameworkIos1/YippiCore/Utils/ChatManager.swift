//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit
import SwiftyUserDefaults

@objcMembers
public final class ChatDraftInfo: NSObject, Codable, DefaultsSerializable {
    public let sessionId: String
    public let draftText: Data
    public let replyMessageId: String?
    public let mentionUsernames: [String]?

    public init(sessionId: String, draftText: Data, replyMessageId: String? = nil, mentionUsernames: [String]? = nil) {
        self.sessionId = sessionId
        self.draftText = draftText
        self.replyMessageId = replyMessageId
        self.mentionUsernames = mentionUsernames
    }
}

@objcMembers
public final class secretMessageDuration: NSObject, Codable, DefaultsSerializable {
    public let sessionId: String
    public let duration: Int

    public init(sessionId: String, duration: Int) {
        self.sessionId = sessionId
        self.duration = duration
    }
}

@objcMembers
public class ChatManager: NSObject {
    public static func saveDraft(sessionId: String, draftInfo: ChatDraftInfo) {
        let chatDraftKey = DefaultsKey<ChatDraftInfo?>("\(Constants.ChatDraftKey)-\(sessionId)")
        if let attrString = NSKeyedUnarchiver.unarchiveObject(with: draftInfo.draftText) as? NSMutableAttributedString, attrString.string == "" {
            if Defaults.hasKey(chatDraftKey) {
                Defaults.remove(chatDraftKey)
            }
        } else {
            UserDefaults.standard[chatDraftKey] = draftInfo
        }

    }

    public static func loadDraft(sessionId: String) -> ChatDraftInfo? {
        let chatDraftKey = DefaultsKey<ChatDraftInfo?>("\(Constants.ChatDraftKey)-\(sessionId)")
        if Defaults.hasKey(chatDraftKey) {
            return UserDefaults.standard[chatDraftKey]
        }
        return nil
    }

    public static func setDurationForSecretMessage(sessionId: String, duration: secretMessageDuration) {
        let secretMessageTimerKey = DefaultsKey<secretMessageDuration?>("\(Constants.secretMessageTimerKey)-\(sessionId)")
        if duration.duration == 0 {
            if Defaults.hasKey(secretMessageTimerKey) {
                Defaults.remove(secretMessageTimerKey)
            }
        } else {
            UserDefaults.standard[secretMessageTimerKey] = duration
        }

    }

    public static func loadDurationForSecretMessage(sessionId: String) -> secretMessageDuration? {
        let secretMessageTimerKey = DefaultsKey<secretMessageDuration?>("\(Constants.secretMessageTimerKey)-\(sessionId)")
        if Defaults.hasKey(secretMessageTimerKey) {
            return UserDefaults.standard[secretMessageTimerKey]
        }
        return nil
    }

}

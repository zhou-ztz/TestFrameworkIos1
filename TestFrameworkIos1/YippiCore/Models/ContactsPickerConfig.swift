//
//  ContactsPickerConfig.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

@objcMembers
public class ContactsPickerConfig: NSObject {
    
    // Navigation title
    public let title: String
    
    // Right button title
    public let rightButtonTitle: String
    
    // Allow multi select. Default is false.
    public let allowMultiSelect: Bool
    
    // Enable to show and share to joined team. Default is false.
    public let enableTeam: Bool
    
    // Enable to show and share to recent conversations. Default is false.
    public let enableRecent: Bool
    
    // Enable to show and share to Hungry Bear (Robot). Default is false.
    public let enableRobot: Bool
    
    // Maximum select count
    public let maximumSelectCount: Int
    
    // Excluded users' ids which default selected in the list and cant be deselect
    public let excludeIds: [String]?
    
    // List of members' id. Used for remove member from team.
    public let members: [String]?
    
    // Enabled to show scanner & find people buttons. Enabled in select friends to chat view. Default is false.
    public let enableButtons: Bool
    
    // Allow search for other member
    public let allowSearchForOtherPeople: Bool
    
    @objc public init(title: String,
                      rightButtonTitle: String,
                      allowMultiSelect: Bool = false,
                      enableTeam: Bool = false,
                      enableRecent: Bool = false,
                      enableRobot: Bool = false,
                      maximumSelectCount: Int = 999999,
                      excludeIds: [String]? = nil,
                      members: [String]? = nil,
                      enableButtons: Bool = false,
                      allowSearchForOtherPeople: Bool = true) {
        
        self.title = title
        self.rightButtonTitle = rightButtonTitle
        self.allowMultiSelect = allowMultiSelect
        self.enableTeam = enableTeam
        self.enableRecent = enableRecent
        self.enableRobot = enableRobot
        self.maximumSelectCount = allowMultiSelect ? maximumSelectCount : 1
        self.excludeIds = excludeIds
        self.members = members
        self.enableButtons = enableButtons
        self.allowSearchForOtherPeople = allowSearchForOtherPeople
    }
    
    public class func shareToChatConfig() -> ContactsPickerConfig {
        let config = ContactsPickerConfig(title: NSLocalizedString("title_select_contacts", comment: ""),
                                          rightButtonTitle: NSLocalizedString("text_send", comment: ""),
                                          allowMultiSelect: true,
                                          enableTeam: true,
                                          enableRecent: true)
        return config
    }
    
    public class func selectFriendToChatConfig() -> ContactsPickerConfig {
        let config = ContactsPickerConfig(title: NSLocalizedString("title_select_friends", comment: ""),
                                          rightButtonTitle: NSLocalizedString("select_friends_right_title_default", comment: ""),
                                          allowMultiSelect: true,
                                          maximumSelectCount: Constants.maximumTeamMemberAuthCompulsory,
                                          enableButtons: false)
        return config
    }
    
    public class func selectFriendBasicConfig(_ excludeIds: [String]?) -> ContactsPickerConfig {
        let config = ContactsPickerConfig(title: NSLocalizedString("title_select_friends", comment: ""),
                                          rightButtonTitle: NSLocalizedString("select_friends_right_title_default", comment: ""),
                                          allowMultiSelect: true,
                                          maximumSelectCount: Constants.maximumTeamMemberAuthFromCardView,
                                          excludeIds: excludeIds)
        return config
    }
    
    public class func mentionConfig(_ members: [String]?) -> ContactsPickerConfig {
        let config = ContactsPickerConfig(title: NSLocalizedString("select_friend_select_contact", comment: ""),
                                          rightButtonTitle: NSLocalizedString("confirm", comment: ""),
                                          allowMultiSelect: true,
                                          members:  members)
        return config
    }
}

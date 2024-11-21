// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

public typealias ContactSelectCancelClosure = () -> Void
public typealias ContactSelectFinishClosure = ([ContactData]?) -> Void
public typealias TransactionFinishClosure = (_ id: Int, _ userId: [String]?, _ msg: String) -> Void
public typealias createGroupFinishBlock = (NSString) -> Void
public typealias TransactionDismissClosure = () -> Void

@objcMembers
public class ContactData: NSObject {
    public let userId : Int
    public let userName : String
    public var imageUrl : String
    public let isTeam : Bool
    public let displayname: String
    public let remarkName: String
    public let isBannedUser: Bool
    public var verifiedType: String
    public var verifiedIcon: String
    public var isTop : Bool = false
    
    public init(userId: Int, userName: String, imageUrl: String, isTeam: Bool, displayname: String, remarkName: String = "", isBannedUser: Bool, verifiedType: String, verifiedIcon: String) {
        
        self.userId = userId
        self.userName = userName
        self.imageUrl = imageUrl
        self.isTeam = isTeam
        self.displayname = displayname
        self.remarkName = remarkName
        self.isBannedUser = isBannedUser
        self.verifiedType = verifiedType
        self.verifiedIcon = verifiedIcon
    }
}

@available(*, deprecated, message: "Use ContactsPickerConfig instead.")
@objcMembers
public class ContactSelectorConfig: NSObject {
    
    @objc public enum FUControllerMode:NSInteger {
        case IM
        case App
        case Social
    }
    
    @objc public enum contentType: NSInteger {
        case defaultContent
        case sticker
        case image
        case video
        case post
    }
    
    public let title : String
    public let isMultiSelect : Bool
    public let filterIds : NSArray?
    public let maxSelectCount : Int
    public let enableTeam : Bool
    public let enableRobot : Bool
    public let enableRecent : Bool
    public let teamId : String?
    public let doneBtnTitle : String?
    public let doneBtnImage : UIImage?
    public let typeOfContent: contentType
    public let content : Any?
    public let mode : FUControllerMode
    public let shareToSocial: Bool
    public let toastMessage : Int
    
    public convenience init(title: String, isMultiSelect: Bool, filterIds: NSArray?, maxSelectCount: Int, enableTeam: Bool, enableRobot: Bool, enableRecent : Bool, teamId: String?, doneBtnTitle: String?, doneBtnImage: UIImage?, toastMessage: Int) {
        self.init(title: title, isMultiSelect: isMultiSelect, filterIds: filterIds, maxSelectCount: maxSelectCount, enableTeam: enableTeam, enableRobot: enableRobot, enableRecent: enableRecent, teamId: teamId, doneBtnTitle: doneBtnTitle, doneBtnImage: doneBtnImage, typeOfContent:  contentType.defaultContent, content: nil, mode: FUControllerMode.IM, shareToSocial: false, toastMessage: toastMessage)
    }

    @objc public init(title: String, isMultiSelect: Bool, filterIds: NSArray?, maxSelectCount: Int, enableTeam: Bool, enableRobot: Bool, enableRecent : Bool, teamId: String?, doneBtnTitle: String?, doneBtnImage: UIImage?, typeOfContent: contentType, content: Any?, mode: FUControllerMode, shareToSocial: Bool, toastMessage: Int) {
        
        self.title = title
        self.isMultiSelect = isMultiSelect
        self.filterIds = filterIds
        self.maxSelectCount = maxSelectCount
        self.enableTeam = enableTeam
        self.enableRobot = enableRobot
        self.enableRecent = enableRecent
        self.teamId = teamId
        self.doneBtnTitle = doneBtnTitle
        self.doneBtnImage = doneBtnImage
        self.typeOfContent = typeOfContent
        self.content = content
        self.mode = mode
        self.shareToSocial = shareToSocial
        self.toastMessage = toastMessage
    }
}

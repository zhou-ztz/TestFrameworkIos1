//
//  ContactModel.swift
//  Yippi
//
//  Created by ChuenWai on 23/04/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import Contacts
import UIKit

struct ContactModel {

    /// 姓名
    var name: String
    /// 电话
    var phone: String
    /// 头像
    var avatar: UIImage?
    /// 是否已经邀请过
    var isInvite = false

    init?(contact: CNContact) {
        let nameInfo = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName) ?? "wu_ming_shi".localized
        let phoneInfo = contact.phoneNumbers
        guard let phoneNumber = TSContactModel.filter(phone: phoneInfo), nameInfo != "" else {
            return nil
        }
        name = nameInfo
        phone = phoneNumber
        let imageData = contact.thumbnailImageData ?? NSData.init() as Data
        avatar = UIImage(data: imageData)
    }

    /// 过滤手机号的格式
    static func filter(phone: [CNLabeledValue<CNPhoneNumber>]?) -> String? {
        guard var phone = phone else {
            return nil
        }
        var phoneNum = ""
        var phoneNumArr: [String] = []
        for phoneInfo in phone {
            phoneNumArr.append(phoneInfo.value.stringValue)
        }
        if phoneNumArr.contains(CurrentUserSessionInfo?.phone ?? "") {
            return nil
        }
        // 获取整个数组中符合要求的第一个手机号码
        for phoneInfo in phone {
            var phoneNums = phoneInfo.value.stringValue
            phoneNums = phoneNums.replacingOccurrences(of: "-", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: "+86", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: " ", with: "")
            phoneNums = phoneNums.replacingOccurrences(of: "+", with: "")
            if phoneNums.count >= 10 {
                if TSAccountRegex.isPhoneNumberFormat(phoneNums) {
                    phoneNum = phoneNums
                    break
                }
            }
        }

        //walk around, special handling for MY phone number only to adapt to server's required format
        if let phoneCode = Country.default.phoneCode, phoneCode == "+60", phoneNum.prefix(1) == "0" {
            let phone = phoneNum.dropFirst()
            let code = phoneCode.replacingOccurrences(of: "+", with: "")
            phoneNum = "\(code)\(phone)"
        }

        return phoneNum == "" ? nil : phoneNum
    }
}

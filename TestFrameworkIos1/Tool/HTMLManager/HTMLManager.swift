//
//  HTMLManager.swift
//  Yippi
//
//  Created by Kit Foong on 15/01/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import SwiftSoup

let TextViewBindingAttributeName = "TextViewBingDingFlagName"

class HTMLManager: NSObject {
    static let shared = HTMLManager()
    
    // MARK: Post
    func addUserIdToTagContent(userId: Int? = nil, userName: String) -> NSAttributedString {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        var insertStr = spStr! + "@" + userName + spStr! + " "
        var userIdString = ""
        if let userId = userId {
            userIdString = userId.stringValue
        }

        let temp = NSAttributedString(string: insertStr, attributes: [NSAttributedString.Key.foregroundColor: AppTheme.blue,
                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue),
                                                                      NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userIdString])
        return temp
    }
    
    func formHtmlString(_ attributedString: NSAttributedString) -> String {
        var formattedString = attributedString.string
        var oriList : [String] = []
        var updatedList : [String] = []
        var usernameList : [FeedHTMLModel] = []
        attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                            in:NSMakeRange(0, attributedString.length),
                                            options:.longestEffectiveRangeNotRequired) {
            value, range, stop in
            if let userId = value as? String {
                let username = attributedString.string.subString(with: range)
                usernameList.append(FeedHTMLModel(userId: userId, userName: username))
            }
        }
        
        attributedString.enumerateAttribute(.font,
                                            in:NSMakeRange(0, attributedString.length),
                                            options:.longestEffectiveRangeNotRequired) {
            value, range, stop in
            let temp = attributedString.string.subString(with: range)
            oriList.append(temp)
        }
        
        for item in oriList {
            var username : String = item
            if username != "\u{00ad}" {
                if let model = usernameList.first(where: { $0.userName == item }) {
                    username = self.formHtmlTag(userId: model.userId, userName: model.userName)
                }
                
                updatedList.append(username)
            }
        }
        
        formattedString = ""
        for item in updatedList {
            formattedString += item
        }
        return formattedString
    }
    
    func formHtmlTag(userId: String,  userName: String) -> String {
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)
        let htmlString = "\(spStr!)<a href=\"\(TSAppConfig.share.environment.serverAddress)users/\(userId)\">\(userName.replacingOccurrences(of: "\u{00ad}", with: ""))</a>\(spStr!) "
        return htmlString
    }
    
    func formatTextViewAttributeText(_ textView: UITextView, completion: (() -> Void)? = nil) {
        let range = textView.selectedRange
        var userIdList : [String] = []
        
        if let attributedString = textView.attributedText {
            attributedString.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                                in:NSMakeRange(0, attributedString.length),
                                                options:.longestEffectiveRangeNotRequired) {
                value, range, stop in
                if let userId = value as? String {
                    userIdList.append(userId)
                }
            }
        }
        
        let attString = NSMutableAttributedString(string: textView.text)
        attString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: NSRange(location: 0, length: attString.length))
        attString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)], range:  NSRange(location: 0, length: attString.length))
        
        let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
        
        for (index, item) in matchs.enumerated() {
            attString.addAttributes([NSAttributedString.Key.foregroundColor: AppTheme.blue], range: NSRange(location: item.range.location, length: item.range.length - 1))
            if let userId = userIdList[safe: index] {
                attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId], range: NSRange(location: item.range.location, length: item.range.length - 1))
            }
        }
        
//        textView.text = attString.string
        textView.attributedText = attString
        textView.selectedRange = range
        
        completion?()
    }
    
    // MARK: Display
    func removeHtmlTag(htmlString: String, completion: @escaping (String, [String]) -> ()) {
        var temp : String = htmlString
        var userIdList: [String] = []
        
        do {
            let doc: Document = try SwiftSoup.parse(temp)
            let links: Elements = try doc.select("a")
            
            for link in links {
                let linkOuterH: String = try link.outerHtml()
                let linkHref: String = try link.attr("href")
                let linkText: String = try link.text()
                
                if let id = linkHref.urlValue?.lastPathComponent {
                    userIdList.append(id)
                }
                
                temp = temp.replacingOccurrences(of: linkOuterH, with: linkText)
            }
        } catch {
            printIfDebug("Unable to parse html string")
        }
        
        completion(temp, userIdList)
    }
    
    func formAttributeText(_ attributedString: NSMutableAttributedString, _ userIdList: [String]) -> NSMutableAttributedString {
        let attString = attributedString
        let matchs = TSUtil.findAllTSAt(inputStr: attString.string)
        
        if userIdList.isEmpty == false {
            for (index, item) in matchs.enumerated() {
                if let userId = userIdList[safe: index] {
                    attString.addAttributes([NSAttributedString.Key(rawValue: TextViewBindingAttributeName): userId],
                                            range: NSRange(location: item.range.location, length: item.range.length - 1))
                }
            }
        }
        
        return attString
    }
    
    func getAttributeModel(attributedText: NSMutableAttributedString) -> [FeedAttributedModel] {
        var model: [FeedAttributedModel] = []
        
        attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: TextViewBindingAttributeName),
                                          in:NSMakeRange(0, attributedText.length),
                                          options:.longestEffectiveRangeNotRequired) {
            value, range, stop in
            if let userId = value as? String {
                model.append(FeedAttributedModel(userId: userId, range: NSRange(location: range.location + 1, length: range.length)))
            }
        }
        
        return model
    }
    
    // MARK: Mention on Tap
    func handleMentionTap(name: String, attributedText: NSMutableAttributedString?) {
        var uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)]).replacingFirstOccurrence(of: "@", with: "").replacingOccurrences(of: "\u{00ad}", with: "")
        
        if let attributedText = attributedText {
            var models = getAttributeModel(attributedText: attributedText)
            
            if models.isEmpty {
                TSUtil.pushUserHomeName(name: uname)
            } else {
                for item in models {
                    var username = attributedText.string.subString(with: NSRange(location: item.range.location, length: item.range.length))
                    username = String(username[..<username.index(username.startIndex, offsetBy: username.count - 1)]).replacingFirstOccurrence(of: "@", with: "").replacingOccurrences(of: "\u{00ad}", with: "")
                    if uname == username {
                        TSUtil.pushUserHomeId(uid: item.userId)
                        break
                    }
                }
            }
        } else {
            TSUtil.pushUserHomeName(name: uname)
        }
    }
}

class FeedAttributedModel: NSObject {
    var userId: String
    var range: NSRange
    
    init(userId: String, range: NSRange) {
        self.userId = userId
        self.range = range
    }
}

class FeedHTMLModel: NSObject {
    var userId: String
    var userName: String
    
    init(userId: String, userName: String) {
        self.userId = userId
        self.userName = userName
    }
}

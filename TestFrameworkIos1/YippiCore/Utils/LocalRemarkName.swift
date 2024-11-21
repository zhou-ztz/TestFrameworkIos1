//
//  RemarkName.swift
//  YippiCore
//
//  Created by Khoo on 04/09/2019.
//  Copyright © 2019 Chew. All rights reserved.
//


import Foundation
import UIKit

@objcMembers
public class LocalRemarkName: NSObject {
    
    @discardableResult
    public static func getRemarkName (userId:String?, username:String?, originalName:String? ,label: UILabel?) -> String {
        // MARK: REMARK NAME
        if let userRemarkName =  UserDefaults.standard.array(forKey: "UserRemarkName") {
            
            let remarkNameArray = userRemarkName as! [[String:String]]
            var remarkName: [String:String]?
            
            if userId == nil {
                remarkName = remarkNameArray.filter { $0["username"] == "\(username ?? "")"}.first
            } else {
                remarkName = remarkNameArray.filter { $0["userID"] == "\(userId ?? "")"}.first
            }
            
            if let remarkNameString = remarkName {
                if label == nil {
                    return remarkNameString["remarkName"]!
                }

                label!.text = remarkNameString["remarkName"]
            } else {
                if let username = originalName {
                    if label == nil {
                        return username
                    }
                    label!.text = username
                } else {
                    if label == nil {
                        if originalName == nil {
                            return ""
                        }
                        return originalName!
                    }
                    label!.text = ""
                }
            }
            
        } else {
            if let username = originalName {
                if label == nil {
                    return username
                }
                label!.text = username
            } else {
                if label == nil {
                    if originalName == nil {
                        return ""
                    }
                    return originalName!
                }
                label!.text = ""
            }
        }
        
        return ""
    }
}

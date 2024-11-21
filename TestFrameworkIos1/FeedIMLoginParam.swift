//
//  FeedIMLoginParam.swift
//  feedIMSDKDemo
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/10/28.
//

import UIKit
import RealmSwift

public class FeedIMLoginParam: NSObject {
    //
    public var themeColor: Int = 0xED1A3B

    public var apiBaseURL: String = ""
    //文件上传url
    public var uploadFileURL: String = ""
    // LokaliseProjectID
    public var lokaliseProjectID: String = ""
    // LokaliseSDKToken
    public var lokaliseSDKToken: String = ""
    
    public var realm: Realm!
}

//
//  ServerResponseDataTransforms.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  服务器响应数据转换

import Foundation
import ObjectMapper

class NumberArrayTransform: TransformType {

    func transformFromJSON(_ value: Any?) -> [Int]? {
        if let stringArray = value as? [String] {
            var intArray: [Int] = []
            for string in stringArray {
                guard let intItem = Int(string) else {
                    continue
                }
                intArray.append(intItem)
            }
            return intArray
        }
        if let intArray = value as? [Int] {
            return intArray
        }
        return []
    }

    func transformToJSON(_ value: [Int]?) -> [Int]? {
        return value
    }
}

// 处理单个字符串和Int的相互转换
class SingleStringTransform: TransformType {
    public typealias Object = Int
    public typealias JSON = String

    public init() {}
    func transformFromJSON(_ value: Any?) -> Int? {
        if let value = value as? String {
            return Int(value)
        } else if let value = value as? Int {
            return value
        }
        return nil
    }

    func transformToJSON(_ value: Int?) -> String? {
        if let value = value {
            return "\(value)"
        }
        return nil
    }
}

/// 评论的来源类型
///
/// - feed: 动态
/// - group: 圈子
/// - news: 资讯
/// - musicAlbum: 音乐专辑
/// - song: 歌曲
/// - question: 问题
/// - answers: 答案
enum ReceiveInfoSourceType: String {
    case feed = "feeds"
    case musicAlbum = "music_specials"
    case song = "musics"
    case reject = "reject"
    case like = "Like" //点赞
    case follow = "Follow" //关注
    case KYC = "KYC" //KYC
    case tagged = "tagged"
    case followback = "followback" //回关
}

class ReceiveInfoSourceTypeTransform: TransformType {
    public typealias Object = ReceiveInfoSourceType
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> ReceiveInfoSourceType? {
        if let type = value as? String {
            return ReceiveInfoSourceType(rawValue: type)
        }
        return nil
    }

    open func transformToJSON(_ value: ReceiveInfoSourceType?) -> String? {
        if let type = value {
            return type.rawValue
        }
        return nil
    }
}

/// CGSize 转换
///
/// - Note: "100x100" 和 CGSize(100, 100) 的相互转换
/// - Warning: 只能处理正整数
class CGSizeTransform: TransformType {
    public typealias Object = CGSize
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> CGSize? {
        if let sizeString = value as? String {
            let sizeArray = sizeString.components(separatedBy: "x").map { Int($0) ?? NSNotFound }
            guard sizeArray.count == 2 else {
                assert(sizeArray.count == 2, "出现了无法解析的数据")
                return CGSize.zero
            }
            for i in sizeArray {
                assert(i != NSNotFound, "出现了无法解析的数据")
                guard i > 0 else {
                    return CGSize.zero
                }
            }
            return CGSize(width: sizeArray[0], height: sizeArray[1])
        }

        return nil
    }

    open func transformToJSON(_ value: Object?) -> String? {
        if let cgSize = value {
            let width = Int(cgSize.width)
            let height = Int(cgSize.height)
            return String(format: "%dx%d", width, height)
        }
        return nil
    }
}

func intArray(from string: String?) -> [Int]? {
    guard let value = string else { return nil }
    
    return value.components(separatedBy: ",").compactMap { $0.toInt() }
}

func stringValue(from intArray: [Int]?) -> String? {
    guard let value = intArray else { return nil }
    
    return value.compactMap{ $0.stringValue }.joined(separator: ",")
}

let StringIntArrayTransformer = TransformOf<[Int], String>(fromJSON: { (value: String?) -> [Int]? in
    return intArray(from: value)
}) { (value: [Int]?) -> String? in
    return stringValue(from: value)
}

let IntArrayTransformer = TransformOf<String, [Int]>(fromJSON: { (value: [Int]?) -> String? in
    return stringValue(from: value)
}) { (value: String?) -> [Int]? in
    return intArray(from: value)
}

let StringArrayTransformer = TransformOf<String, [String]>(fromJSON: { (value: [String]?) -> String? in
    return value?.joined(separator: ",")
}) { (value: String?) -> [String]? in
    if let unwrapped = value {
        return unwrapped.components(separatedBy: ",")
    }
    return nil
}

/// 时间的相互转化处理, "2017-08-02 09:08:51" 和 Date
let DateTransformer = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
    if let dateString = value {
        return dateString.dateConvertTo()
    }
    return nil
}) { (date: Date?) -> String? in
    if let date = date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    return nil
}

//let NSDateTransformer = TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
//    if let dateString = value {
//        return dateString.convertToDate()
//    }
//    return nil
//}) { (date: NSDate?) -> String? in
//    return date?.string(withFormat: "yyyy-MM-dd HH:mm:ss")
//}

extension String {
    fileprivate func dateConvertTo(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone(identifier: "GMT")) -> Date? {
        let dateFormatter = DateFormatter()
        var date: Date?
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //兼容新的时间格式
        // 2018-08-28T07:21:56Z  yyyy-MM-dd'T'HH:mm:ss.ssssssZ
        if self.hasSuffix("Z") == true {
            var tempStr = self
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.ssssssZ"
            date = dateFormatter.date(from: tempStr)
            
            // By Kit Foong (Added checking here, it date nil will try yyyy-MM-dd'T'HH:mm:ssZ format)
            // Live Ranking using yyyy-MM-dd'T'HH:mm:ssZ format
            if date == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                date = dateFormatter.date(from: tempStr)
            }
        } else {
            date = dateFormatter.date(from: self)
            if date == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                date = dateFormatter.date(from: self)
            }
        }
        return date
    }

    fileprivate func convertedArray() -> Array<Int>? {
        let stringArray = self.components(separatedBy: ",")
        var uids: Array<Int> = []
        if stringArray.isEmpty {
            return nil
        }
        for string in stringArray {
            if string == "" {
                continue
            }
            if let num = Int(string) {
                uids.append(num)
            }
        }
        return uids
    }

    fileprivate  func convertedStringArray() -> Array<String>? {
        let stringArray = self.components(separatedBy: ",")
        var strings: Array<String> = []
        if stringArray.isEmpty {
            return nil
        }
        for string in strings {
            if string == "" {
                continue
            }
            strings.append(string)
        }
        return strings
    }
}

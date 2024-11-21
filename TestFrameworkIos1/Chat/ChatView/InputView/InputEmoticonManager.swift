//
//  InputEmoticonManager.swift
//  Yippi
//
//  Created by Khoo on 06/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class InputEmoticon: NSObject {
    var emoticonID: String?
    var tag: String?
    var filename: String?
    var unicode: String?
}

class InputEmoticonLayout: NSObject {
    var rows = 0
    var columes = 0 /*行数 */
    var itemCountInPage = 0 /*列数 */
    var cellWidth: CGFloat = 0.0 /*每页显示几项 */
    var cellHeight: CGFloat = 0.0 /*单个单元格宽 */
    var imageWidth: CGFloat = 0.0 /*单个单元格高 */
    var imageHeight: CGFloat = 0.0 /*显示图片的宽 */
    var emoji = false /*显示图片的高 */
    
    init(emojiLayoutWidth: CGFloat) {
        rows = Constants.NIM.NIMKit_EmojRows
        columes = ((Int(emojiLayoutWidth) - Constants.NIM.NIMKit_EmojiLeftMargin - Constants.NIM.NIMKit_EmojiRightMargin) / Int(Constants.NIM.NIMKit_EmojImageWidth))
        itemCountInPage = rows * columes - 1
        cellWidth = CGFloat((Int(emojiLayoutWidth) - Constants.NIM.NIMKit_EmojiLeftMargin - Constants.NIM.NIMKit_EmojiRightMargin) / columes)
        cellWidth = Constants.NIM.NIMKit_EmojCellHeight
        imageWidth = Constants.NIM.NIMKit_EmojImageWidth
        imageHeight = Constants.NIM.NIMKit_EmojImageHeight
        emoji = true
    }
    
    init(charletLayoutWidth: CGFloat) {
        rows = Constants.NIM.NIMKit_PicRows
        columes = ((Int(charletLayoutWidth) - Constants.NIM.NIMKit_EmojiLeftMargin - Constants.NIM.NIMKit_EmojiRightMargin) / Int(Constants.NIM.NIMKit_PicImageWidth))
        itemCountInPage = rows * columes
        cellWidth = CGFloat((Int(charletLayoutWidth) - Constants.NIM.NIMKit_EmojiLeftMargin - Constants.NIM.NIMKit_EmojiRightMargin) / columes)
        cellWidth = Constants.NIM.NIMKit_PicCellHeight
        imageWidth = Constants.NIM.NIMKit_PicImageWidth
        imageHeight = Constants.NIM.NIMKit_PicImageHeight
        emoji = false
    }
}

class InputEmoticonCatalog: NSObject {
    var layout: InputEmoticonLayout?
    var catalogID: String?
    var title: String?
    var id2Emoticons: [AnyHashable : Any]?
    var tag2Emoticons: [AnyHashable : Any]?
    var emoticons: [InputEmoticon]?
    var icon: String?
    /*图标 */    var iconPressed: String?
    /*小图标按下效果 */    var pagesCount = 0
    //分页数
}


class InputEmoticonManager: NSObject {
    
    var catalogs: [Any]?
    var bundleEmoticonInfos: [String: Any]?
    
    static var shared = InputEmoticonManager()
    
    override init() {
        super.init()
        self.parsePlist()
    }

    func parsePlist() {
        var catalogs: [String] = []

        let filepath = Bundle.main.path(forResource: "emoji", ofType: "json")

        if filepath != nil {

            let data = NSData(contentsOfFile: filepath ?? "") as Data?
            var array: [AnyHashable]? = nil
            do {
                if let data = data {
                    array = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable]
                }
            } catch {
            }

            for dict in array ?? [] {
                guard let dict = dict as? [AnyHashable : Any] else {
                    continue
                }
                let emojiArray = Array(dict.keys)
                let emoji = emojiArray[0] as? String
                catalogs.append(emoji.orEmpty)
            }
        }
        self.catalogs = catalogs
    }

    
    func emoticonCatalog(_ catalogID: String?) -> InputEmoticonCatalog? {
        guard let catalogs = catalogs else { return nil }
        for catalog in catalogs {
            if let catalog = catalog as? InputEmoticonCatalog, catalog.catalogID == catalogID {
                return catalog
            }
        }
        
        return nil
    }
    
    func emoticon(byTag tag: String?) -> InputEmoticon? {
        return nil
    }
    
    func emoticon(byID emoticonID: String?) -> InputEmoticon? {
        guard let catalogs = catalogs else { return nil }
        var emoticon:Any? = nil
        if emoticonID?.count ?? 0 > 0 {
            for catalog in catalogs {
                if let catalog = catalog as? InputEmoticonCatalog {
                    guard let id2Emoticons = catalog.id2Emoticons else { return nil }
                    emoticon = id2Emoticons[emoticonID]
                    if emoticon == nil {
                        break
                    }
                }
            }
        }
        
        if let emoticon = emoticon as? InputEmoticon {
            return emoticon
        }
        
        return nil
    }
    
    func emoticon(byCatalogID catalogID: String?, emoticonID: String?) -> InputEmoticon? {
        var emoticon: InputEmoticon? = nil
        if emoticonID?.count ?? 0 > 0 && catalogID?.count ?? 0 > 0 {
            guard let catalogs = catalogs else { return nil }
            for catalog in catalogs {
                if let catalog = catalog as? InputEmoticonCatalog {
                    guard let id2Emoticons = catalog.id2Emoticons else { return nil }
                    emoticon = id2Emoticons[emoticonID] as! InputEmoticon
                    break
                }
            }
        }
        
        return emoticon
    }
    
    func catalog(byInfo info: [String : Any]?, emoticons emoticonsArray:[Any]?) -> InputEmoticonCatalog? {
        let catalog = InputEmoticonCatalog()
        catalog.catalogID = info?["id"] as? String ?? ""
        catalog.title = info?["title"] as? String ?? ""
        let iconNamePrefix = Constants.NIM.NIMKit_EmojiPath
        let icon = info?["normal"] as? String ?? ""
        catalog.icon = URL(fileURLWithPath: iconNamePrefix).appendingPathComponent(icon ).absoluteString
        let iconPressed = info?["pressed"] as? String ?? ""
        catalog.iconPressed = URL(fileURLWithPath: iconNamePrefix).appendingPathComponent(iconPressed).absoluteString
        
        var tag2Emoticons: [AnyHashable : Any] = [:]
        var id2Emoticons: [AnyHashable : Any] = [:]
        var emoticons: [AnyHashable] = []

        guard let emoticonsArray = emoticonsArray as? [[String:Any]] else { return nil }
        for emoticonDict in emoticonsArray {
            let emoticon = InputEmoticon()
            emoticon.emoticonID = emoticonDict["id"] as? String ?? ""
            emoticon.tag = emoticonDict["tag"] as? String ?? ""
            emoticon.unicode = emoticonDict["unicode"] as? String ?? ""
            let fileName = emoticonDict["file"] as? String
            let imageNamePrefix = Constants.NIM.NIMKit_EmojiPath
            emoticon.filename = URL(fileURLWithPath: imageNamePrefix).appendingPathComponent(fileName ?? "").absoluteString

            if (emoticon.emoticonID != nil) {
                emoticons.append(emoticon)
                id2Emoticons[emoticon.emoticonID] = emoticon
            }
            if (emoticon.tag != nil) {
                tag2Emoticons[emoticon.tag] = emoticon
            }
        }

        catalog.emoticons = emoticons as? [InputEmoticon]
        catalog.id2Emoticons = id2Emoticons
        catalog.tag2Emoticons = tag2Emoticons
        return catalog
    }

    // HOT FIX for iOS 12 load bundle resource much slower than earlier versions
    func preloadEmoticonResource() {
        guard let catalogs = catalogs else { return }
        DispatchQueue.global(qos: .default).async(execute: {
            var emoticonInfos: [String : Any] = [:]
            if let catalogs = catalogs as? [InputEmoticonCatalog] {
                for catalog in catalogs {
                    if let emoticons = catalog.emoticons {
                        for data in emoticons {
                            let image = UIImage()
//                            if let image = image, let filename = data.filename {
//                                emoticonInfos[filename] = image
//                            }
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.bundleEmoticonInfos = emoticonInfos
                })
            }
        })
    }
    
    func emojiList() -> [InputEmoticonCatalog]? {
        if let catalogs = catalogs {
            return catalogs as? [InputEmoticonCatalog]
        }
        return nil
    }
}

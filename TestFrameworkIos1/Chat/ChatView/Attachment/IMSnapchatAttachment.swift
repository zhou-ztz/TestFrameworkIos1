//
//  IMSnapchatAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import CommonCrypto
import NIMSDK

class  IMSnapchatAttachment: NSObject, NIMCustomAttachment, IMMessageContentInfo {

    var md5: String = ""
    var url: String = ""
    var filePath: String = ""
    var isFired: Bool = false

    var coverImage: UIImage?
    var isFromMe = false
    
    func encode() -> String {
        let dictContent: [String : Any] = [CMMD5: self.md5,
                                           CMFIRE: self.isFired,
                                           CMURL: self.url]
        let dict: [String : Any] = [CMType: CustomMessageType.Snapchat.rawValue,
                                    CMData: dictContent]
        var stringToReturn = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
    
    func cellContent(_ message: MessageData) -> BaseContentView {
        return SnapMessageContentView(messageModel: message)
    }
    
    func canBeRevoked() -> Bool {
        return true
    }
    
    func canBeForwarded() -> Bool {
        return false
    }
    
    func canBeTranslated() -> Bool {
        return false
    }
    
    func canBeReplied() -> Bool {
        return true
    }
    
    func snapMessage(_ path: String) {
        if FileManager.default.fileExists(atPath: path), let pathUrl = URL(string: path), let filePathUrl = URL(string: filepath()) {
            
            do {
                let data = try Data(contentsOf: pathUrl)
                self.md5 = data.MD5String()
                try data.write(to: filePathUrl)
            } catch {
                
            }
        }
    }
    
    func snapMessage(_ image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.7)
        let md5 = data?.MD5String()
        self.md5 = md5 ?? ""
        let filePathUrl = URL(fileURLWithPath: filepath())
        guard let imageData = data  else { return }
        do {
            try imageData.write(to: filePathUrl)
        } catch {
            print("write string error:\(error)")
        }
    }
    
    private func filepath() -> String {
        let filename = md5 + ".jpg"
        return IMFileLocationHelper().filepath(forImage: filename) ?? ""
    }
    
    
    //MARK: - 实现文件上传需要接口
    func attachmentNeedsUpload() -> Bool {
        return self.url.count == 0
    }

    func attachmentPathForUploading() -> String {
        return self.filepath()
    }
    
    func updateURL(_ urlString: String) {
        self.filePath = self.filepath()
        self.url = urlString
    }

    //MARK: - Private
    func updateCover() {
        self.coverImage = UIImage.set_image(named: "hold_to_check_image") 
    }
}

extension Data {
    
    func MD5String() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            self.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(self.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

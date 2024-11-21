//
//  CollectionMsgDataManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

typealias deleteCollectionMsgCall = ((FavoriteMsgModel?) -> Void)?

class CollectionMsgDataManager: NSObject {
    static let collectionManager = CollectionMsgDataManager()
    
    //MARK: collectionMsg to NIMMessage
    func messageModel(model: FavoriteMsgModel?) -> NIMMessage? {
        guard let faModel = model else {
            return nil
        }
        var dictModel: SessionDictModel?
        guard let data = faModel.data.data(using: .utf8) else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        guard let objectModel = dictModel  else {
            return nil
        }
        let message: NIMMessage = NIMMessage()
        switch faModel.type {
        case .text:
            message.text = objectModel.content
            break
        case .image:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                var image: UIImage?
                if let url = URL(string: attach.url) {
                    do {
                        let data = try Data(contentsOf: url)
                        image = UIImage(data: data)
                    } catch {
                        
                    }
                }
                guard let img = image else {
                    return nil
                }
                
                let imageObject = NIMImageObject(image: img, scene: NIMNOSSceneTypeMessage)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString = dateFormatter.string(from: Date())
                imageObject.displayName = dateString
                
                let option = NIMImageOption()
                option.compressQuality = 0.9
                imageObject.option = option
                
                message.messageObject = imageObject
                message.apnsContent = "sent_a_img".localized
                
                let setting = NIMMessageSetting()
                setting.scene = NIMNOSSceneTypeMessage
                message.setting = setting
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .audio:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMAudioCollectionAttachment.self, from: dataAttach)
                var audioData: Data?
                if let url = URL(string: attach.url) {
                    do {
                        let data = try Data(contentsOf: url)
                        audioData = data
                    } catch {
                    }
                }
                guard let audio = audioData else {
                    return nil
                }
                let audioObject = NIMAudioObject(data: audio, extension: attach.ext)
                message.messageObject = audioObject
                message.apnsContent = "sent_a_voice_msg".localized
                let setting = NIMMessageSetting()
                setting.scene = NIMNOSSceneTypeMessage
                message.setting = setting
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .video:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                var videoData: Data?
                if let url = URL(string: attach.url) {
                    do {
                        let data = try Data(contentsOf: url)
                        videoData = data
                    } catch {
                    }
                }
                guard let videoData1 = videoData else {
                    return nil
                }
                let videoObj = NIMVideoObject(data: videoData1, extension: attach.ext, scene: NIMNOSSceneTypeMessage)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString = dateFormatter.string(from: Date())
                videoObj.displayName = String(format: "sent_a_video_by", dateString)
                
                message.messageObject = videoObj
                message.apnsContent = "sent_a_video_msg".localized
                
                let setting = NIMMessageSetting()
                setting.scene = NIMNOSSceneTypeMessage
                message.setting = setting
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .location:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMLocationCollectionAttachment.self, from: dataAttach)
                let locationObject = NIMLocationObject(latitude: attach.lat, longitude: attach.lng, title: attach.title)
                message.messageObject = locationObject
                message.apnsContent = "send_location".localized
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .file:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMFileCollectionAttachment.self, from: dataAttach)
                var fileData: Data?
                if let url = URL(string: attach.url) {
                    do {
                        let data = try Data(contentsOf: url)
                        fileData = data
                    } catch  {
                    }
                }
                guard let file = fileData else {
                    return nil
                }
                let fileObject = NIMFileObject(data: file, extension: attach.ext)
                fileObject.displayName = attach.name
                
                message.messageObject = fileObject
                message.apnsContent = "sent_a_file".localized
                let setting = NIMMessageSetting()
                setting.scene = NIMNOSSceneTypeMessage
                message.setting = setting
                message.text = attach.name
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .nameCard:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any], let memberId = data[CMContactCard] as? String {
                    
                    let attachment = IMContactCardAttachment()
                    attachment.memberId = memberId
                    let customObject = NIMCustomObject()
                    customObject.attachment = attachment
                    message.messageObject = customObject
                    message.apnsContent = "recent_msg_desc_contact".localized
                    message.text = NIMSDKManager.shared.getAvatarIcon(userId: memberId).nickname ?? ""
                } else {
                    return nil
                }
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .sticker:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let bundleID = data[CMStickerBundleId] as? String
                    let bundleIcon = data[CMStickerIconImage] as? String
                    let bundleName = data[CMStickerName] as? String
                    let bundleDescription = data[CMStickerDiscription] as? String
                    let bundleUrl = data[CMRStickerURL] as? String
                    
                    let attachment = IMStickerCardAttachment()
                    attachment.bundleID = bundleID ?? ""
                    attachment.bundleIcon = bundleIcon ?? ""
                    attachment.bundleName = bundleName ?? ""
                    attachment.bundleDescription = bundleDescription ?? ""
                    attachment.bundleUrl = bundleUrl ?? ""
                    let customObject = NIMCustomObject()
                    customObject.attachment = attachment
                    message.messageObject = customObject
                    message.apnsContent = "recent_msg_desc_sticker_collection".localized
                    //message.text = ""
                } else {
                    return nil
                }
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .link:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let postUrl = data[CMShareURL] as? String
                    let title = data[CMShareTitle] as? String
                    let desc = data[CMShareDescription] as? String
                    let imageURL = data[CMShareImage] as? String
                    let contentType = data[CMShareContentType] as? String
                    let contentUrl = data[CMShareContentUrl] as? String
                    
                    let attachment = IMSocialPostAttachment()
                    attachment.postUrl = postUrl ?? ""
                    attachment.title = title ?? ""
                    attachment.desc = desc ?? ""
                    attachment.imageURL = imageURL ?? ""
                    attachment.contentType = contentType ?? ""
                    attachment.contentUrl = contentUrl ?? ""
                    let object = NIMCustomObject()
                    object.attachment = attachment
                    message.messageObject = object
                } else {
                    return nil
                }
            } catch {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .miniProgram:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let appId = data[CMAppId] as? String
                    let path = data[CMPath] as? String
                    let title = data[CMMPTitle] as? String
                    let desc = data[CMMPDesc] as? String
                    let imageURL = data[CMMPAvatar] as? String
                    let contentType = data[CMMPType] as? String
                    
                    let attachment = IMMiniProgramAttachment()
                    attachment.appId = appId ?? ""
                    attachment.path = path ?? ""
                    attachment.title = title ?? ""
                    attachment.desc = desc ?? ""
                    attachment.imageURL = imageURL ?? ""
                    attachment.contentType = contentType ?? ""
                    
                    let object = NIMCustomObject()
                    object.attachment = attachment
                    message.messageObject = object
                } else {
                    return nil
                }
            } catch  {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        case .voucher:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let postUrl = data[CMShareURL] as? String
                    let title = data[CMShareTitle] as? String
                    let desc = data[CMShareDescription] as? String
                    let imageURL = data[CMShareImage] as? String
                    let contentType = data[CMShareContentType] as? String
                    let contentUrl = data[CMShareContentUrl] as? String
                    
                    let attachment = IMVoucherAttachment()
                    attachment.postUrl = postUrl ?? ""
                    attachment.title = title ?? ""
                    attachment.desc = desc ?? ""
                    attachment.imageURL = imageURL ?? ""
                    attachment.contentType = contentType ?? ""
                    attachment.contentUrl = contentUrl ?? ""
                    let object = NIMCustomObject()
                    object.attachment = attachment
                    message.messageObject = object
                } else {
                    return nil
                }
            } catch  {
                printIfDebug("jsonerror = \(error.localizedDescription)")
            }
            break
        default:
            break
        }
        
        
        return message
    }
    
    
}

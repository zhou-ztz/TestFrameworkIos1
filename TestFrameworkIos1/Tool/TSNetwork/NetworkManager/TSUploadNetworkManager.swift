//
//  TSUploadNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 16/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  上传文件的网络请求
//  TODO: 上传前检查 上传文件中 分类型上"文件 图片 头像" 需要整合

import Foundation
import Alamofire
import OBS

class TSUploadNetworkManager {
    
    /// 默认图片压缩后最大物理体积200kb
    fileprivate static let postImageMaxSizeKb: CGFloat = 200
    /// 上传检查
    /// data: 上传的文件数据
    /// complete: 完成的回调,
    ///           existId 若文件存在则提取文件的id， isExist 文件是否存在
    private func uploadCheck(data: Data, complete: @escaping ((_ existId: Int?, _ isExist: Bool?, _ msg: String?, _ status: Bool) -> Void) ) -> Void {
        let hash = TSUtil.md5(data)
        var request = ApplicationNetworkRequest().checkFile
        request.urlPath = request.fullPathWith(replacers: [hash])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, nil, "network_problem".localized, false)
            case .failure(let response):
                if response.statusCode == 404 {
                    complete(nil, false, nil, true)
                } else {
                    complete(nil, nil, response.message, false)
                }
            case .success(let reponse):
                if let result = reponse.sourceData as? Dictionary<String, Any> {
                    let id = result["id"] as? Int
                    complete(id, true, nil, true)
                    return
                }
                assert(false, "服务器响应了无法解析的数据")
                complete(nil, nil, "network_problem".localized, false)
            }
        }
    }

    /// 上传文件
    /// imageField = "file"
    // 文件或图片时传file，头像传avatar
    func uploadVideoFile(data: Data, fileField: String = "file", videoSize: CGSize, complete: @escaping ((_ fileId: Int?, _ msg: String?, _ status: Bool) -> Void), uploadProgress: ((Double)->())? = nil) -> Void {
        // 请求1. 上传检查
        self.uploadCheck(data: data) { (existId, isExist, msg, status) in
            // 请求出错
            guard status, let isExist = isExist else {
                complete(nil, msg, false)
                return
            }
            // 已存在
            if isExist {
                complete(existId!, msg, status)
                return
            }

            // 请求2. 上传文件
            // 构建请求的url
            let requestPath: String = TSAppConfig.share.environment.uploadFileURL
            // 自定义header
            let authorization = TSCurrentUserInfo.share.accountToken?.token
            var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
            if let authorization = authorization {
                let token = "Bearer " + authorization
                coustomHeaders.updateValue(token, forKey: "Authorization")
            }
            // 文件传
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: fileField, fileName: "ios-video", mimeType: "video/mp4")
                multipartFormData.append("\(videoSize.height)".data(using: String.Encoding.utf8)!, withName: "height")
                multipartFormData.append("\(videoSize.width)".data(using: String.Encoding.utf8)!, withName: "width")
            }, usingThreshold: 0, to: requestPath, method: .post, headers: coustomHeaders) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { (progress) in
                        uploadProgress?(progress.fractionCompleted)
                    }
                    upload.responseJSON { response in
                        LogManager.Log("Request: \(requestPath)", loggingType: .apiRequestData)
                        LogManager.Log("Response: \(String(describing: response))", loggingType: .apiResponseData)
                        
                        XCGLoggerManager.shared.logRequestInfo("Request: \(requestPath)")
                        XCGLoggerManager.shared.logRequestInfo("Response: \(String(describing: response))")
                        
                        if response.result.isSuccess {
                            let resultDic = response.result.value as! Dictionary<String, Any>
                            if let requestId = resultDic["id"] as? Int {
                                complete(requestId, nil, true)
                            } else if let message = resultDic["message"] as? String {
                                complete(nil, message, false)
                            } else {
                                complete(nil, nil, false)
                            }
                        } else {
                            if response.response?.statusCode == 413 {
                                complete(nil, "video_over_size".localized, false)
                            } else {
                                complete(nil, response.result.error?.localizedDescription ?? "", false)
                            }
                        }
                    }
                case .failure(let encodingError):
                    complete(nil, encodingError.localizedDescription, false)
                }
            }
        }
    }

    /// 兼容旧的接口
    func uploadImage(image: UIImage, complete: @escaping ((_ fileId: Int?, _ msg: String?, _ status: Bool, _ reqId: Int?) -> Void)) -> Void {
        let originalImageData = image.jpegData(compressionQuality: 1)!
        let imageData = TSUtil.compressImageData(imageData: originalImageData, maxSizeKB: TSUploadNetworkManager.postImageMaxSizeKb)
        self.uploadFile(data: imageData, complete: complete)
    }

    /// 串行上传一组图片
    func upload(images: [UIImage], index: Int, finishIDs: [Int], complete: @escaping((_ fileIDs: [Int]) -> Void)) {
        guard let imgData = images[index].jpegData(compressionQuality: 1) else {
            complete([Int]())
            return
        }
        var fileID: Int?
        let group = DispatchGroup()
        var fileIDs = finishIDs
        group.enter()
        self.uploadFile(data: imgData) { (imgServerID, _, _, reqId) in
            fileID = imgServerID
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            guard let newID = fileID else {
                complete([Int]())
                return
            }
            fileIDs.append(newID)
            if fileIDs.count < images.count {
                self.upload(images: images, index: index + 1, finishIDs: fileIDs, complete: complete)
            } else {
                complete(fileIDs)
            }
        }
    }

    /// 为了兼容旧代码提供的API 后续合并
    func upload(imageDatas: [Data], mimeTypes: [String], index: Int, finishIDs: [Int], progressHandler: ((Progress) -> Void)? = nil, complete: @escaping((_ fileIDs: [Int]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            
            let totalItemsCount = imageDatas.count
            var processItemsCount = 0
            var fileIDs = Array<Int>()
            for (index, uploadData) in imageDatas.enumerated() {
                let mimeType = mimeTypes[index]
                let uploadData: Data = imageDatas[index]
                guard uploadData.isEmpty == false else {
                    print("\(#function) \(#file):\(#line): \(CurrentUserSessionInfo?.username) Upload data is empty.\n")
                    assertionFailure()
                    return
                }
            
                TSUploadNetworkManager().uploadFile(data: uploadData, mimeType: mimeType, reqId: index) { progress in
                    progressHandler?(progress)
                } complete: { imgServerID, _, _, reqId in
                    let newID = imgServerID ?? 0
                    if(newID != 0){
                        var datas = imageDatas
                        datas.remove(at: reqId ?? 0)
                        fileIDs.append(newID)
                    }
                    
                    processItemsCount += 1
                    
                    if(processItemsCount == totalItemsCount){
                        complete(fileIDs)
                    }
                }
            }
        }
    }
    ///

    /// 上传文件
    /// filekey在文件或图片时传file，头像传avatar,背景图上传是‘image’
    func uploadFile(data: Data, filekey: String = "file", fileName: String = "ios-file", mimeType: String = "image/jpeg", reqId: Int = 0, progressHandler: ((Progress) -> Void)? = nil, complete: @escaping ((_ fileId: Int?, _ msg: String?, _ status: Bool, _ reqId: Int?) -> Void)) -> Void {
        // 请求1. 上传检查
        TSUploadNetworkManager().uploadCheck(data: data) { (existId, isExist, msg, status) in
            // 请求出错
            guard status, let isExist = isExist else {
                LogManager.Log("\(#function) \(#file):\(#line): Upload file status: \(status) \(msg ?? "")\n", loggingType: .networkError)
                complete(nil, msg, false, nil)
                return
            }
            // 已存在
            if isExist {
                LogManager.Log("\(#function) \(#file):\(#line): \(status) \(msg ?? "") \([Int]())\n", loggingType: .apiResponseData)
                complete(existId!, msg, status, reqId)
                return
            }

            // 请求2. 上传文件
            // 构建请求的url
            let requestPath: String = TSAppConfig.share.environment.uploadFileURL
            // 自定义header
            let authorization = TSCurrentUserInfo.share.accountToken?.token
            var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
            if let authorization = authorization {
                let token = "Bearer " + authorization
                coustomHeaders.updateValue(token, forKey: "Authorization")
            }
            // 文件传
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: filekey, fileName: fileName, mimeType: mimeType)
            }, usingThreshold: 0, to: requestPath, method: .post, headers: coustomHeaders) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        progressHandler?(progress)
                    }
                    
                    upload.responseJSON { response in
                        if response.result.isSuccess {
                            if let resultDic = response.result.value as? Dictionary<String, Any>, let requestId = resultDic["id"] as? Int {
                                complete(requestId, nil, true, reqId)
                                print("requestId===\(requestId)")
                            } else {
                                
                                LogManager.Log("\(#function) \(#file):\(#line): Upload Failed: \("error_upload_success_decode_result_fail".localized)\n", loggingType: .networkError)

                                complete(nil, "error_upload_success_decode_result_fail".localized, true, reqId)
                            }
                        } else {
                            
                            LogManager.Log("\(#function) \(#file):\(#line): Upload Failed: \((response.result.error as NSError?)?.localizedDescription)\n", loggingType: .networkError)
                            complete(nil, (response.result.error as NSError?)?.localizedDescription, false, reqId)
                        }
                    }
                case .failure(let encodingError):
                    LogManager.Log("\(#function) \(#file):\(#line): Upload Failed: \(encodingError)\n", loggingType: .exception)
                    complete(nil, (encodingError as NSError?)?.localizedDescription, false, reqId)
                }
            }

        }
    }

    func scanImage(_ id: Int, complete: @escaping (_ isSensitive: Bool?, _ msg: String?, _ status: Bool?) -> Void) {
        var request = ApplicationNetworkRequest().scanFile
        request.urlPath = request.fullPathWith(replacers: [id.stringValue])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "network_problem".localized, false)
            case .failure(let response):
                if response.statusCode == 404 {
                    complete(nil, nil, true)
                } else {
                    complete(nil, response.message, false)
                }
            case .success(let reponse):
                if let result = reponse.sourceData as? Dictionary<String, Any> {
                    let isSensitive = result["is_sensitive"] as? Bool
                    complete(isSensitive, nil, true)
                    return
                }
                assert(false, "服务器响应了无法解析的数据")
                complete(nil, "network_problem".localized, false)
            }
        }
    }
    // 文件上传华为OBS
    func uploadFileToOBS(fileDatas: [Data], isImage: Bool = true, videoSize: CGSize = .zero, progressHandler: ((Progress) -> Void)? = nil, complete: @escaping (_ fileIds: [Int]) -> Void){
        ///获取obs key
        getTemporaryKey { model, message, isLocal in
            if let access = model?.access, let secret = model?.secret, let securitytoken = model?.securityToken, let expirestimestamp = model?.expiresAtTimestamp {
                if !isLocal {
                    let dict: [String: Any] = ["access": access, "secret": secret, "securitytoken": securitytoken, "expirestimestamp": expirestimestamp]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                        OBSHelper.shared.setOBSKey(data: jsonData)
                    } catch {
                        print("Error converting dictionary to JSON data: \(error)")
                    }
                }
                //aes 解密
                let deAccess = OBSHelper.shared.aesDecrypt(value: access)
                let desSecret = OBSHelper.shared.aesDecrypt(value: secret)
                ///初始化OBS
                OBSManager.shared.initializeOBS(accessKey: deAccess, secretKey: desSecret, securityToken: securitytoken)
                ///检查文件hash
                self.checkHash(datas: fileDatas) { models, datas  in
                    guard let datas = datas else {
                        complete([])
                        return
                    }
                    var finishModels: [UploadOBSModel] = models ?? []
                    
                    var fileList: [[String: Any]] = []

                    let group = DispatchGroup()
                    var isUploadAll = true
                    for model in datas {
                        guard let data = model.data, let filePath = self.savePhotoToSandbox(data: data) else {
                            return
                        }
                        
                        let hash = TSUtil.md5(data)
                        let date = Date()
                        let dateStr = date.string(format: "YYYY/MM/dd/HHmm", timeZone: nil)
                        let objectKey = dateStr + "/" + UUID().uuidString + self.randomHex4Digits() + (isImage ? ".jpg" : ".mp4")
                        print("objectKey = \(objectKey)")
                        var dict: [String: Any] = ["hash": hash, "object_key": objectKey, "mime": (isImage ? "image/jpeg" : "video/mp4"), "width": "", "height": ""]
                        let filePath1 = filePath.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
                        if isImage{
                            if let image = UIImage(contentsOfFile: filePath1)  {
                                dict["width"] = "\(Int(image.size.width))"
                                dict["height"] = "\(Int(image.size.height))"
                            }
                        } else {
                            dict["width"] = "\(Int(videoSize.width))"
                            dict["height"] = "\(Int(videoSize.height))"
                        }
                        fileList.append(dict)
                        let request = OBSUploadFileRequest(bucketName: "yippi-social", objectKey: objectKey, uploadFilePath: filePath1)
                        // 分段大小为5MB
                        request?.partSize = NSNumber(integerLiteral: 5 * 1024 * 1024)
                        // 开启断点续传模式
                        request?.enableCheckpoint = true
                        // 指定checkpoint文件路径
                        request?.checkpointFilePath = ""
                        // 开启MD5校验
                        request?.enableMD5Check = true
                        // 访问策略
                        request?.objectACLPolicy = .publicRead
                        //contentType
                        request?.contentType = (isImage ? OBSContentType.JPEG : OBSContentType.MP4)
                        
                        request?.uploadProgressBlock = { [weak self]  bytesSent, totalBytesSent, totalBytesExpectedToSend in
                            let progress = floor(Double(totalBytesSent * 10000 / totalBytesExpectedToSend)) / 100
                            if !isImage {
                                let spro = Progress(totalUnitCount: totalBytesSent * 10000)
                                spro.completedUnitCount = totalBytesExpectedToSend
                                progressHandler?(spro)
                            }
                            print(String(format: "%.1f%%", progress))
                        }
                        group.enter()
                        DispatchQueue.global(qos: .background).async {
                            
                            let task = OBSManager.shared.client?.uploadFile(request) {[weak self] response, error in
                                if let error = error {
                                    // 再次上传
                                    print("OBS uploadFile-error == \(error)")
                                    isUploadAll = false
                                }else{
                                    if isImage {
                                        let spro = Progress(totalUnitCount: 1)
                                        spro.completedUnitCount = 1
                                        progressHandler?(spro)
                                    }
                                    print("OBS response == \(response)")
                                    
                                }
                                group.leave()
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    group.notify(queue: DispatchQueue.main){
                        //如果有图片上传失败，重新发布
                        if !isUploadAll  {
                            complete([])
                            return
                        }

                        var fieldIDs = [Int]()
                        if let models = models {
                            for model in models {
                                fieldIDs.append(model.existId)
                            }
                        }
                         
                        if fileList.isEmpty {
                            complete(fieldIDs)
                            return
                        }
                        
                        var req = UploadFileSaveFileRequestType()
                        req.list = fileList
                        req.execute { result in
                            
                            if let resultDatas = result?.data {
                                
                                for resultData in resultDatas {
                                    fieldIDs.append(resultData.id ?? 0)
                                }
                                print("result===\(resultDatas)")
                                complete(fieldIDs)
                            }
                        } onError: { error in
                            complete([])
                            LogManager.Log("\(#function) \(#file):\(#line): Upload Failed: \(error)\n", loggingType: .exception)
                        }

                        
                    }
                    
                }
                
                
                
            }else {
                complete([])
            }
            
        }
       
     
    }
    
    func randomHex4Digits() -> String {
        let randomValue = Int.random(in: 0...65535)
        return String(format: "%04X", randomValue)
    }
    
    // 图片视频保存本地
    func savePhotoToSandbox(data: Data, isImage: Bool = true) -> String? {
       
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentsDirectory.appendingPathComponent("obsfile")

        var fileName = ""
        if isImage{
            fileName = "\(UUID().uuidString).jpg"
        }else {
            fileName = "\(UUID().uuidString).mp4"
        }
        
        if fileManager.fileExists(atPath: path.relativePath) == false {
            try! fileManager.createDirectory(atPath: path.relativePath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileURL = path.appendingPathComponent(fileName)
        print("filepath = \(fileURL.absoluteString)")
        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            return nil
        }
    }
    
    private func checkHash(datas: [Data], complete: @escaping (_ models: [UploadOBSModel]?, _ uploadDatas: [UploadOBSModel]?) -> Void){
        var hashs: [[String: Any]] = []
        var models: [UploadOBSModel] = []
        
        for data in datas {
            let hash = TSUtil.md5(data)
            let dict =  ["hash": hash]
            hashs.append(dict)
            let model = UploadOBSModel()
            model.data = data
            model.hashStr = hash
            models.append(model)
            
        }
        
        var request = UploadFileCheckHashRequestType()
        request.list = hashs
        request.execute { [weak self] result in
            var uploadDatas: [Data] = []
            if let resultDatas = result?.data {
                
                var existLists: [UploadOBSModel] = []
                
                for resultData in resultDatas {
                    if resultData.exists == true {
                        let model = UploadOBSModel()
                        model.existId = resultData.id ?? 0
                        model.hashStr = resultData.hash ?? ""
                        existLists.append(model)
                        
                        if let index = models.firstIndex(where: { uploadModel in
                            uploadModel.hashStr == resultData.hash
                        }){
                            models.remove(at: index)
                        }
                    }
                }
               
                complete(existLists, models)
            }else {
                
                complete(nil, models)
            }
        } onError: { error in
            complete(nil, nil)
        }

    }
    ///获取 OBS  AK , SK
    private func getTemporaryKey(complete: @escaping (_ model: TemporaryKey?, _ message: String?, _ isLocal: Bool) -> Void){
   
        let timeStamp = Date().timeIntervalSince1970
        if let data = OBSHelper.shared.getOBSKey(), let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let expirestimestamp = dict["expirestimestamp"] as? String, let access = dict["access"] as? String, let secret = dict["secret"] as? String, let securitytoken = dict["securitytoken"] as? String, (TimeInterval(expirestimestamp) ?? 0.0) > (timeStamp + 60)  {
            
            let model = TemporaryKey(expiresAt: "", secret: secret, access: access, securityToken: securitytoken, expiresAtTimestamp: expirestimestamp)
            complete(model, nil, true)
        }else{
            let request = UploadFileTemporaryKeyRequestType()
            request.execute { [weak self] result in
                if let model = result?.data {
                    complete(model, nil, false)
                }else{
                    complete(nil, nil, false)
                }
            } onError: { error in
                complete(nil, error.localizedDescription, false)
            }
        }

    }

}

struct UploadFileCheckHashRequestType: RequestType {
    typealias ResponseType = CheckHashDataResponse
    var list: [[String: Any]] = []
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/files/segments_uploaded/check-hash", method: .post, params: ["hash_list": list])
    }
}

struct CheckHashDataResponse: Decodable {
    let data: [CheckHashResponse]?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
    }
}

struct CheckHashResponse: Decodable {
    let exists: Bool?
    let id: Int?
    let hash: String?
    let saved: Bool?
    
    enum CodingKeys: String, CodingKey {
        case exists = "exists"
        case id = "id"
        case hash
        case saved
    }
}


class UploadOBSModel: NSObject {
    var hashStr: String = ""
    var existId: Int = 0
    var objectKey: String = ""
    var data: Data?
}


struct UploadFileSaveFileRequestType: RequestType {
    typealias ResponseType = CheckHashDataResponse
    var list: [[String: Any]] = []
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/files/segments_uploaded/save-file", method: .post, params: ["file_list": list])
    }
}

struct UploadFileTemporaryKeyRequestType: RequestType {
    typealias ResponseType = TemporaryKeyResponse
   
    var data: YPRequestData {
        return YPRequestData(path: "/api/v2/files/segments_uploaded/get_temporary_key", method: .get, params: nil)
    }
}

struct TemporaryKeyResponse: Decodable {
    let data: TemporaryKey?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
    }
}

struct TemporaryKey: Decodable {
    let expiresAt: String?
    let secret: String?
    let access: String?
    let securityToken: String?
    let expiresAtTimestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case expiresAtTimestamp = "expires_at_timestamp"
        case secret, access
        case securityToken = "security_token"
    }
}

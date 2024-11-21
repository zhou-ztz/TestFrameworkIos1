//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import Apollo
import MobileCoreServices

@objc protocol StickerManagerDelegate: class {
    
    @objc optional func downLoadCustomerSticker(sticker: CustomerStickerItem)
    
    func stickerDidRemoved(id: String)
    func stickerDidDownloaded(id: String)
    
    
}

class StickerManager {

    static let shared = StickerManager()
    
    weak var delegate: StickerManagerDelegate?

    func loadOwnStickerList(completion: ((Bool) -> ())?) {
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        YippiAPI.shared.getStickerListV2(userId: "\(userID)") { (data, error) in
            guard let dataDictionary = data, let bundles = dataDictionary["data"] else {
                completion?(false)
                return
            }
            let reversedBundles = bundles.reversed()
            let stickerManager = StickerManager.shared
            let group = DispatchGroup()

            reversedBundles.forEach({ (bundle) in
                if stickerManager.isBundleDownloaded("\(bundle.bundleID)") == false {
                    group.enter()
                    stickerManager.downloadSticker(for: "\(bundle.bundleID)") {
                        group.leave()
                    } onError: { _ in
                        completion?(false)
                    }
                }
            })

            // save the bundle again with the correct order
            group.notify(queue: DispatchQueue.global()) {
                var bundlesToStore = [Dictionary<String, String>]()
                reversedBundles.forEach { (bundle) in
                    var bundleDictionary = Dictionary<String, String>()
                    bundleDictionary["bundle_id"] = "\(bundle.bundleID)"
                    bundleDictionary["bundle_icon"] = bundle.bundleIcon
                    bundleDictionary["bundle_name"] = bundle.bundleName
                    bundleDictionary["uid"] = "\(userID)"
                    bundleDictionary["userId"] = "\(userID)"
                    bundlesToStore.append(bundleDictionary)
                }
               // NTESStickerManager.saveDownloadedStickerBundle(bundlesToStore)
                self.saveDownloadedStickerBundle(bundlesToStore)
                completion?(true)
            }
        }
    }
    
    func downloadSticker(for id: String, completion: EmptyClosure?, onError: @escaping (String) -> Void) {
        
        let mutation = DownloadStickerMutation(bundleId: id)
        YPApolloClient.perform(mutation: mutation) { (response, error) in
            guard error == nil else {
                // show fail loading
                onError("download_failed_try_again".localized)
                LogManager.LogError(name: "Download Sticker Normal Error: " + (error?.localizedDescription ?? ""), reason: nil)
                return
            }

            if let error = response?.errors, error.count > 0 {
                var logErrStr = ""
                for (index,err) in error.enumerated() {
                    logErrStr += String(format: "%i) %@\n", index+1, err.message.orEmpty)
                }
                LogManager.LogError(name: "Download Sticker GraphQL Error: " + logErrStr, reason: nil)
                onError("download_failed_try_again".localized)
                return
            }
            
            var posIndex = 0
            var stickerItems: [StickerItem] = []

            if let stickerLists = response?.data?.downloadSticker?.stickerLists {
                stickerItems = stickerLists.compactMap({ sticker in
                    
                    
                    let stickerItem = StickerItem(id: (sticker?.stickerId).orEmpty,
                                                  bundleId: String(sticker?.bundleId ?? -1),
                                                  icon: (sticker?.stickerIcon).orEmpty,
                                                  name: (response?.data?.downloadSticker?.bundleName).orEmpty,
                                                  position: "\(posIndex)")
                    
                    posIndex += 1
                    
                    return stickerItem
                })
            }
            
            //let bundleId = (response?.data?.downloadSticker?.bundleId).orEmpty
            let bundleIcon = (response?.data?.downloadSticker?.bundleIcon).orEmpty
            //NTESStickerManager.saveDownloadedSticker(bundleIcon, stickerList: stickerItems)
            //self.delegate?.stickerDidDownloaded(id: bundleId)
            self.saveDownloadedSticker(bundleIcon, stickerList: stickerItems)
            let name = Notification.Name("Notification_StickerBundleDownloaded")
            NotificationCenter.default.post(name:name, object: nil)
            completion?()
        }
    }
    
    func purchaseSticker(for id: String, password: String?, completion: EmptyClosure?) {
        guard let user = AppEnvironment.current.currentUser, let password = password  else { return }
        YippiAPI.shared.send(PurchaseSticker(bundleId: id, username: user.username, password: password)) { response in
            switch response {
            case .success(let result):
                DispatchQueue.main.async {
                   // NTESStickerManager.saveDownloadedSticker(id, stickerList: result)
                    self.saveDownloadedSticker(id, stickerList: result)
                    self.delegate?.stickerDidDownloaded(id: id)
                    let name = Notification.Name("Notification_StickerBundleDownloaded")
                    NotificationCenter.default.post(name:name, object: nil)
                    completion?()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
//                    Utils.showFailLoading(error.localizedDescription)
                }
            }
        }
    }
    
    func removeSticker(id: String, completion: EmptyClosure?, onError: ((String?) -> Void)?) {
        
        let mutation = RemoveStickerMutation(bundleId: id)
        YPApolloClient.perform(mutation: mutation) { (response, error) in
            guard error == nil else {
                onError?(error?.localizedDescription)
                return                
            }
            self.delegate?.stickerDidRemoved(id: id)
           // NTESStickerManager.removeBundle(id)
            self.removeBundle(id)
            let name = Notification.Name("Notification_StickerBundleDownloaded")
            NotificationCenter.default.post(name:name, object: nil)
            completion?()
        }
    }
    
    func isBundleDownloaded(_ id: String) -> Bool {
        let stickerPlistPath = AppUtil.shared.makeDocumentFullPath("\(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PREFIX)\(id)")
        return (AppUtil.shared.content(fromFile: stickerPlistPath) != nil) ? true : false
    }
    
    
    func saveDownloadedSticker(_ bundleID: String, stickerList: [StickerItem]) {
        var allSticker = [[String:Any]]()
        for sticker in stickerList {
            var dict = [String:Any]()
            
            if sticker.bundleID != "" {
                dict["bundle_id"] = sticker.bundleID
                dict["sticker_id"] = sticker.bundleID
                dict["sticker_icon"] = sticker.bundleID
                dict["sticker_name"] = sticker.bundleID
                dict[""] = sticker.position
            }
            
            allSticker.append(dict)
        }
        
        var stickerBundleInfoList = [[String:Any]]()
        
        for stickerBundleInfo in stickerList {
            var dict = [String:Any]()
            if stickerList.first != nil {
                dict["bundle_id"] = stickerBundleInfo.bundleID
                dict["uid"] = ""
                dict["bundle_icon"] = stickerBundleInfo.stickerIcon
                dict["bundle_name"] = stickerBundleInfo.stickerName
                dict["user_id"] = ""
            }
            
            stickerBundleInfoList.append(dict)
        }
        
        let firstObjectOfSticker = stickerBundleInfoList.first
        self.saveBundle(firstObjectOfSticker, sticker: allSticker)
    }
    
    func saveDownloadedStickerBundle(_ array: [Any]?) {
        let stickerPlistPath = AppUtil.shared.makeDocumentFullPath(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PLIST)
        AppUtil.shared.writeContent(array, location: stickerPlistPath)
    }
    
    func loadOwnStickerBundle() -> [Any]? {
        let stickerPlistPath = AppUtil.shared.makeDocumentFullPath(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PLIST)
        if AppUtil.shared.content(fromFile: stickerPlistPath) != nil {
            if let array = AppUtil.shared.content(fromFile: stickerPlistPath) as? [[String:Any]] {
                return array
            }
            return []
        }
        return []
    }
    
    func saveBundle(_ bundle: [String : Any]?, sticker array: [[String:Any]]?) {
        guard let array = array, let bundle = bundle else { return }
        if array.count == 0 { return }
        let bundleId = bundle["bundle_id"] as! String
        
        var bundleList = self.loadOwnStickerBundle()
        
        let resultArray = bundleList?.filter({
            if let bundleIdString = $0 as? String {
                if bundleIdString == bundleId{
                    return true
                }
            }
            return false
        })
        
        if resultArray!.count > 0 {
            self.resaveStickerBundle(array)
            return
        }
        
        bundleList?.insert(bundle, at: 0)
        self.saveDownloadedStickerBundle(bundleList)
    }
    
    func removeBundle(_ bundleId: String?) {
        if bundleId?.count ?? 0 == 0 {
            return
        }
        
        var bundleList = self.loadOwnStickerBundle()
        self.saveDownloadedStickerBundle(bundleList)
        
        bundleList = bundleList?.filter({
            if let bundleIdString = $0 as? String {
                if bundleIdString != bundleId{
                    return true
                }
            }
            return false
        })
        
        self.saveDownloadedStickerBundle(bundleList)
        
        let stickerPlistPath = AppUtil.shared.makeDocumentFullPath("\(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PREFIX)\(bundleId ?? "")")

        AppUtil.shared.deleteFile(atPath: stickerPlistPath)
    }
    
    func loadStickerBundle(_ bundleId: String?) -> [[String:Any]]? {
        let stickerPlistPath = AppUtil.shared.makeDocumentFullPath("\(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PREFIX)\(bundleId ?? "")")
        if AppUtil.shared.content(fromFile: stickerPlistPath) == nil {
            return []
        }
        
        return (AppUtil.shared.content(fromFile: stickerPlistPath) as! [[String:Any]])
    }
    
    func resaveStickerBundle(_ array: [[String:Any]]?) {
        if array?.count == 0 { return }
        
        let bundle = array!.first
        
        var bundleId: String? = nil
        if let value = bundle?["bundle_id"] {
            bundleId = "\(value)"
        }
        let stickerPlistPath = AppUtil.shared.makeDocumentFullPath("\(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PREFIX)\(bundleId ?? "")")
        let writeStatus = AppUtil.shared.writeContent(array, location: stickerPlistPath)

    }
    
    func fetchMyCustomerStickers(first: Int, after: String, callBackHandler: @escaping(_ stickerList: [CustomerStickerItem]?) -> Void){
        let query = FetchCustomStickersQuery(first: first, after: after)
        YPApolloClient.fetch(query: query, queue: DispatchQueue.global()){ (response, error)  in
            
            guard error == nil else {
                LogManager.LogError(name: "Fetch CustomerSticker Normal Error: " + (error?.localizedDescription ?? ""), reason: nil)
                return
            }

            var stickerItems : [CustomerStickerItem] = []
            if let stickerLists = response?.data?.fetchCustomStickers?.edges {
                stickerItems = stickerLists.compactMap({ sticker in
                    
                    let stickerItem = CustomerStickerItem(customStickerId: sticker?.node?.customStickerId ?? "", Typename: sticker?.node?.__typename ?? "", stickerUrl: sticker?.node?.stickerUrl ?? "")
                   
                    return stickerItem
                })

            }
            
            //对比当前本地贴图
            self.getCustomerStickerList { [weak self] (localStickers) in
                
                if let localStickers = localStickers {
                    for  item in stickerItems.reversed() {
                        var flag = true
                        for sticker in localStickers {
                            if item.customStickerId == sticker.customStickerId {
                                flag = false // 如果有相同id 退出该循环
                                continue
                            }
                            
                        }
                        if flag {
                            self?.saveLocal(sticker: item)
                        }
                        
                    }
                }
                
            }
            
            
          
            callBackHandler(stickerItems)
          

        }

        
    }
    func removeCustomerSticker(stickerId: String, callBack: @escaping(_ complete: Bool)-> Void){
        let mutation = RemoveCustomStickerMutation(custom_sticker_id: stickerId)
        YPApolloClient.perform(mutation: mutation){ [weak self] (response, error)  in
            guard let self = self else { return }
            guard error == nil else {
                callBack(false)
                return
            }
            
            callBack(true)
        }
    }
    
    func downloadCustomerSticker(stickerId: String, callBack: @escaping(_ complete: Bool, _ error: Error?, _ msg: String?)-> Void){
        let mutation = DownloadCustomStickerMutation(custom_sticker_id: stickerId)
       
        YPApolloClient.perform(mutation: mutation){ [weak self] (response, error)  in
            guard let self = self else { return }
            guard error == nil else {
                callBack(false, error, nil)
                return
            }
            if let sticker = response?.data?.downloadCustomSticker {
                let stickerItem = CustomerStickerItem(customStickerId: sticker.customStickerId , Typename: sticker.__typename , stickerUrl: sticker.stickerUrl ?? "")
                self.delegate?.downLoadCustomerSticker!(sticker: stickerItem)
                //保存本地
                self.saveLocal(sticker: stickerItem)
                callBack(true, nil, nil)
                return
            }
            print(response?.errors)
            if let errors = response?.errors {
                callBack(false, nil, errors[0].message)
            } else {
                callBack(false, nil, "please_retry_option".localized)
            }
        }
    }
    
    func createCustomerSticker(image: UIImage, isGif: Bool = false, data: Data? = nil, callBack: @escaping(_ msg: String?)-> Void){
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        var headers = YPCustomHeaders
        let tokenObj = TSAccountTokenModel()
        if let token = tokenObj?.token,
            let tokenType = tokenObj?.tokenType {
            headers.updateValue("\(tokenType) \(token)", forKey: "Authorization")

        }
        let typeStr = isGif ? "image/gif" : "image/png"
        
        var imagedata = imageData
        if let gifData = data {
            imagedata = gifData
        }
       
        let quert = ["query": "mutation UploadCustomSticker($file: Upload!) {uploadCustomSticker(file: $file) {__typename    custom_sticker_id    sticker_url}}"] as [String : Any]
        let flie = ["image": ["variables.file"] ] as [String : Any]
        
        let operationData = try! JSONSerialization.data(withJSONObject: quert, options: [])
        let operation = String(data: operationData, encoding: .utf8)!

        let flieData = try! JSONSerialization.data(withJSONObject: flie, options: [])
        let flieStr = String(data: flieData, encoding: .utf8)!

        let parameters = ["operations": operation , "map": flieStr]
       
        let boundary = "Boundary-\(UUID().uuidString)"
        let parameterData = createMultipartFormData(parameters: parameters, boundary: boundary, data: imagedata, mimeType: typeStr, fileName: "image")
       
        let request = NSMutableURLRequest(url: URL(string: TSAppConfig.share.rootServerAddress + "graphql/v1")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = parameterData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if (error != nil) {
                print(error)
                callBack(nil)
            } else {
                let httpResponse = response as? HTTPURLResponse
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601withFractionalSeconds
                let customer = try? jsonDecoder.decode(CreateCustomerStickerItem.self, from: data!)
                let msg = try? jsonDecoder.decode(CreateCustomerMaxError.self, from: data!)
                print("customer = \(customer?.data.uploadCustomSticker.stickerUrl)")
                if let sticker = customer {
                    DispatchQueue.main.async {
                        self.saveLocal(sticker: sticker.data.uploadCustomSticker)
                        self.delegate?.downLoadCustomerSticker!(sticker: sticker.data.uploadCustomSticker)
                    }
                   
                }
                
                if let errors = msg?.errors {
                    let msg = errors[0].message
                    callBack(msg)
                }
                
            

                
            }
        }


        dataTask.resume()
  
        
    }
    
    func createMultipartFormData(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    fileName: String) -> Data {
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendStr(boundaryPrefix)
            body.appendStr("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendStr("\(value)\r\n")
        }
        var name = ".png"
        if mimeType == "image/gif" {
            name = ".gif"
        }

        body.appendStr(boundaryPrefix)
        body.appendStr("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(fileName + name)\"\r\n")
        body.appendStr("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendStr("\r\n")
        body.appendStr("--".appending(boundary.appending("--")))

        return body as Data
    }


    func getCustomerStickerList(callBackHandler: @escaping(_ stickerList: [CustomerStickerItem]?) -> Void){
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = documentsPath + "/customerSticker/" + "/\(userID)/" + "customerSticker.plist"
       
        var stickers = [CustomerStickerItem]()
       
        if FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/") {
            let url = URL(fileURLWithPath: filePath)
            let data = try! Data(contentsOf: url)
            let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
            let dictArray = plist as! [[String:String]]
            print("dictArray = \(dictArray)")
            
            for dict in dictArray {
                let cId = dict["customStickerId"]! as String
                let name =  dict["Typename"]! as String
                let path = dict["stickerUrl"]! as String

                let item = CustomerStickerItem(customStickerId: cId , Typename: name, stickerUrl: path)
                stickers.append(item)

            }
        }
        
    
        callBackHandler(stickers)
    }
    
    //保存本地
    func saveLocal(sticker: CustomerStickerItem){
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = documentsPath + "/customerSticker/" + "/\(userID)/" + "customerSticker.plist"
        let temArray = NSMutableArray()
        if FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/") {

            let url = URL(fileURLWithPath: filePath)
            let data = try! Data(contentsOf: url)
            let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
            let dictArray = plist as! [[String:String]]
            print("dictArray = \(dictArray)")
            temArray.addObjects(from: dictArray)
            
        }else{
            try! FileManager.default.createDirectory(atPath: documentsPath + "/customerSticker/" + "/\(userID)/" , withIntermediateDirectories: true, attributes: nil)
        }
        
        let dict = ["Typename": sticker.Typename!, "customStickerId": sticker.customStickerId!, "stickerUrl": sticker.stickerUrl!] as [String: String]
        temArray.insert(dict, at: 0)
        temArray.write(toFile: filePath, atomically: true)
       

        
    }
    
    // 删除本地贴图
    func deleteLocal(sticker: CustomerStickerItem, index: Int){
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = documentsPath + "/customerSticker/" + "/\(userID)/" + "customerSticker.plist"
        let temArray = NSMutableArray()
        if FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/") {
            let url = URL(fileURLWithPath: filePath)
            let data = try! Data(contentsOf: url)
            let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
            let dictArray = plist as! [[String:String]]
            print("dictArray = \(dictArray)")
            temArray.addObjects(from: dictArray)
        }
        
        if temArray.count > index {
            temArray.removeObject(at: index)
            temArray.write(toFile: filePath, atomically: true)
        }
    }
    
    func deleteLocalWithStickerId(sticlerId: String){
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = documentsPath + "/customerSticker/" + "/\(userID)/" + "customerSticker.plist"

        let array = NSMutableArray()
        var temArray: [[String:String]] = []
        if FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/") {
            let url = URL(fileURLWithPath: filePath)
            let data = try! Data(contentsOf: url)
            let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
            let dictArray = plist as! [[String:String]]
            print("dictArray = \(dictArray)")
            //temArray.addObjects(from: dictArray)
            temArray.append(contentsOf: dictArray)
        }
        
       
        if let index = temArray.firstIndex(where: {
            $0["customStickerId"] == sticlerId
        }) {
            temArray.remove(at: index)
        }
        
        array.addObjects(from: temArray)
        array.write(toFile: filePath, atomically: true)
        
    }
    
    //同步服务器到本地
    func saveServeToLocal(){
        self.fetchMyCustomerStickers(first: 150, after: "") { (stickerItems) in
          
        }
    }
    
    //删除自定义贴图 多个
    func removeCustomerStickers(stickerIds: [String], callBack: @escaping(_ complete: Bool)-> Void){
        let mutation = RemoveCustomStickersMutation(custom_sticker_ids: stickerIds)
        YPApolloClient.perform(mutation: mutation){ (response, error)  in

            guard error == nil else {
                callBack(false)
                return
            }

            callBack(true)
        }
    }
    //删贴图 多个
    func removeStickers(stickerIds: [String], callBack: @escaping(_ complete: Bool)-> Void){
        let mutation = RemoveStickersMutation(bundle_ids: stickerIds)
        YPApolloClient.perform(mutation: mutation){ (response, error)  in

            guard error == nil else {
                callBack(false)
                return
            }
            
            for bundle_id in stickerIds {
                self.delegate?.stickerDidRemoved(id: bundle_id)
                //NTESStickerManager.removeBundle(bundle_id)
                StickerManager.shared.removeBundle(bundle_id)
            }
            let name = Notification.Name("Notification_StickerBundleDownloaded")
            NotificationCenter.default.post(name:name, object: nil)
            callBack(true)
        }
    }
    //move to front
    func sortCustomerStickers(custom_stickers: [CustomStickerInput]?, callBack: @escaping(_ complete: Bool)-> Void){
        let mutation = SortCustomStickerMutation(custom_stickers: custom_stickers)
        YPApolloClient.perform(mutation: mutation){ (response, error)  in
            guard error == nil else {
                callBack(false)
                return
            }

            callBack(true)
        }
    }
    //move to front
    func sortStickers(stickers: [StickerInput]?, callBack: @escaping(_ complete: Bool)-> Void){
        let mutation = SortStickerMutation(stickers: stickers)
        YPApolloClient.perform(mutation: mutation){ (response, error)  in
            guard error == nil else {
                callBack(false)
                return
            }
            

            callBack(true)
        }
    }
    //排序本地自定义贴图
    func sortLocalCustomerStickers(custom_stickers: [CustomerStickerItem]){
        
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = documentsPath + "/customerSticker/" + "/\(userID)/" + "customerSticker.plist"
        let array = NSMutableArray()
        var temArray: [[String:String]] = []
        if FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/") {
            let url = URL(fileURLWithPath: filePath)
            let data = try! Data(contentsOf: url)
            let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
            let dictArray = plist as! [[String:String]]
            print("dictArray = \(dictArray)")
            //temArray.addObjects(from: dictArray)
            temArray.append(contentsOf: dictArray)
        }
        
       
        for sticker in custom_stickers {
          
            if let index = temArray.firstIndex(where: {
                $0["customStickerId"] == sticker.customStickerId
            }) {
                temArray.remove(at: index)
            }
     
        }
            
        
        
        for sticker in custom_stickers.reversed() {
            let dict = ["Typename": sticker.Typename!, "customStickerId": sticker.customStickerId!, "stickerUrl": sticker.stickerUrl!] as [String: String]
            temArray.insert(dict, at: 0)
        }
        array.addObjects(from: temArray)
        array.write(toFile: filePath, atomically: true)
       
        
    }
    
}

extension NSMutableData {
    func appendStr(_ string: String) {
        let data = string.data(using: String.Encoding.utf8)
        append(data!)
    }
}


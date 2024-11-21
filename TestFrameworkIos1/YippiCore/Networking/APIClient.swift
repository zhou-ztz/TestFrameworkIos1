import Foundation
import UIKit

 enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

 protocol APIClientType {
    associatedtype ResponseDataContainer: Decodable
}

/// Implementation of a generic-based API client
@objcMembers
class APIClient : NSObject {
    private let baseEndpointUrl: URL
    private let publicKey: String
    private let privateKey: String
    private var jsonType = false
    
    let session = URLSession(configuration: .default)
    private let boundaryString = "Boundary-\(NSUUID().uuidString)"
    
    init(baseEndpointUrl: URL = URL(string: FeedIMSDKManager.shared.param.apiBaseURL)!,
                isJsonType: Bool = false) {
        self.baseEndpointUrl = baseEndpointUrl
        self.jsonType = isJsonType
        self.publicKey = ""
        self.privateKey = ""
    }
    
    init(baseEndpointUrl: URL = URL(string: FeedIMSDKManager.shared.param.apiBaseURL)!, publicKey: String, privateKey: String) {
        self.baseEndpointUrl = baseEndpointUrl
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    /// Sends a request to servers, calling the completion method when finished
     func send<T: APIRequest>(_ request: T, completion: @escaping ResultCallback<T.Response>) {
        let endpoint = self.endpoint(for: request)
        var urlRequest = URLRequest(url: endpoint)

        urlRequest.setValue(Constants.platform, forHTTPHeaderField: Constants.Headers.ClientType)
        urlRequest.setValue(AppEnvironment.current.appVersion, forHTTPHeaderField: Constants.Headers.ClientVersion)
        urlRequest.setValue(Device.currentUDID, forHTTPHeaderField: Constants.Headers.DeviceID)
        urlRequest.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: Constants.Headers.AcceptLanguage)
        urlRequest.setValue("rewards_link", forHTTPHeaderField: Constants.Headers.ClientAppName)
        
        urlRequest.httpMethod = request.requestMethod.rawValue

        // Multipart
        if let file = request.file {
            var parameters: [String: String]
            do {
                parameters = try URLQueryItemEncoder.encodeAsDictionary(request)
            } catch {
                fatalError("Wrong parameters: \(error)")
            }
            
            if let uid = AppEnvironment.current.currentUser?.uid {
                parameters["uid"] = uid
            }

            urlRequest.setValue("multipart/form-data; boundary=\(boundaryString)", forHTTPHeaderField:"Content-Type")
            urlRequest.httpBody = createMultipartFormData(parameters: parameters, boundary: boundaryString, data: file.binaryData, mimeType: file.mimeType, fileName: file.fileName)
        } else {
            switch request.requestMethod {
            case .post, .put, .patch:
                //TODO(chew): Make APIClient to support post using JSON instead
                if !jsonType {
                    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
                    
                    //use TSUid instead AppEnvironment.current.currentUser?.uid
                    let TSUid = UserDefaults.standard.object(forKey: "TSCurrentUserInfoModel.uid") as? Int
                    
                    let commonQueryItems = [
                        URLQueryItem(name: "uid", value: String(TSUid.orZero))
                    ]
                    let customQueryItems: [URLQueryItem]
                    do {
                        customQueryItems = try URLQueryItemEncoder.encode(request)
                    } catch {
                        fatalError("Wrong parameters: \(error)")
                    }
                    var components = URLComponents()
                    components.queryItems = (commonQueryItems + customQueryItems)
                    urlRequest.httpBody = components.query?.data(using: .utf8)
                } else {
                    do {
                        let jsonData = try JSONEncoder().encode(request)
                        LogManager.Log("JSON encoder:\(String(describing: String(data: jsonData, encoding: .utf8)))", loggingType: .apiRequestData)
                        urlRequest.httpBody = jsonData
                        
                        if let token = UserDefaults.standard.object(forKey: "TSAccountTokenSaveKey") as? String {
                            urlRequest.allHTTPHeaderFields = [
                                "Authorization" : "Bearer \(token)",
                                "X-Client-App-Name" : "rewards_link"
                            ]
                        }
                        
                        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
                        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
                        
                        
                    } catch {
                        LogManager.Log("Failed encode\n\(error.localizedDescription)", loggingType: .networkError)
                    }
                }
            default:
                break
            }
        }
        
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.deserializeResponse(data: data, response: response, error: error, completion: completion)
        }
        task.resume()
    }
    
    open func deserializeResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ResultCallback<T>) {
        if let data = data {
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601withFractionalSeconds
                let standaloneObj = try jsonDecoder.decode(T.self, from: data)
                completion(.success(standaloneObj))
            } catch let err {
                LogManager.Log(err, loggingType: .exception)
                guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any?> else {
                    completion(.failure(err))
                    return
                }
                if let message = dictionary["message"] as? String {
                    completion(.failure(APIError.server(code: 999, message: message)))
                } else {
                    completion(.failure(APIError.server(code: 999, message: NSLocalizedString("unexpected_error", comment: ""))))
                }
            }
            
        } else if let error = error {
            completion(.failure(error))
        }
    }
    
    /// Download bundles 
     func get(_ addressUrl: String, completion: @escaping ResultCallback<Data>) {
        
        guard let url = URL(string: addressUrl) else {
            completion(.failure(APIError.server(code: -1, message: "Invalid url")))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.get.rawValue
        
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func createMultipartFormData(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    fileName: String) -> Data {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))

        return body as Data
    }
    
    
    /// Encodes a URL based on the given request
    /// Everything needed for a  request to servers is encoded directly in this URL
    func endpoint<T: APIRequest>(for request: T) -> URL {
        guard let path = URL(string: request.resourceName, relativeTo: baseEndpointUrl) else {
            fatalError("Bad resourceName: \(request.resourceName)")
        }
        
        var components = URLComponents(url: path, resolvingAgainstBaseURL: true)!

        switch request.requestMethod {
            case .get, .delete:
                // Custom query items needed for this specific request
                let customQueryItems: [URLQueryItem]
                
                do {
                    customQueryItems = try URLQueryItemEncoder.encode(request)
                } catch {
                    fatalError("Wrong parameters: \(error)")
                }
                
                components.queryItems = self.commonQueryItems + customQueryItems
        default:
            break
        }
        
        // Construct the final URL with all the previous data
        return components.url!
    }
    
    // MARK: - Private methods
    
    // Common query items needed for all requests
    var commonQueryItems: [URLQueryItem] {
        get {
            let timestamp = "\(Date().timeIntervalSince1970)"
            let hash = "\(timestamp)\(privateKey)\(publicKey)".md5
            return [
                URLQueryItem(name: "ts", value: timestamp),
                URLQueryItem(name: "hash", value: hash),
                URLQueryItem(name: "apikey", value: publicKey)
            ]
        }
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

@objcMembers
 class YippiAPI: APIClient {
     static let shared = YippiAPI()
     static var togaShared = YippiAPI(baseEndpointUrl: URL(string: AppEnvironment.current.config.apiBaseURL)!, isJsonType: true)
    
    @objc  func downloadSticker(bundleId: String, completion: (([StickerItem]?, Error?) -> Void)?) {
        YippiAPI.shared.send(DownloadSticker(bundleId: bundleId)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    @objc  func getStickerList(completion: (([UserBundle]?, Error?) -> Void)?) {
        YippiAPI.shared.send(GetMyStickers()) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    
    @objc  func getStickerListV2(userId:String, completion: ((Dictionary<String, [UserBundle]>?, Error?) -> Void)?) {
        YippiAPI.shared.send(GetMyStickersV2(userId: userId)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }

    @objc  func sessionOpenEgg(eggId: Int, isGroup: Bool, completion: ((ClaimEggResponse?, Error?) -> Void)?) {
        let claimType: claimType = isGroup == true ? .group : .personal
        self.send(openEgg(eggId: eggId, feedId: nil, type: claimType)) { (response) in
            switch response {
                case  .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
            }
        }
    }

     func openLiveEgg(eggId: Int? = nil, feedId: Int, completion: ((ClaimEggResponse?, Error?) -> Void)?) {
        YippiAPI.togaShared.send(openEgg(eggId: eggId, feedId: feedId, type: .live)) { (response) in
            switch response {
                case  .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
            }
        }
    }
    
    @objc  func sessionOpenPersonalEgg(eggId:Int,completion: ((EggResponseModel?, Error?) -> Void)?) {
        self.send(openPersonalEgg(eggId: eggId)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    @objc  func sessionOpenGroupEgg(eggId:Int,groupId:String,completion: ((EggResponseModel?, Error?) -> Void)?) {
        self.send(openGroupEgg(eggId: eggId, groupId: groupId)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
     func liveOpenEgg(eggId: Int? = nil, feedId: Int, completion: ((EggResponseModel?, Error?) -> Void)?) {
        self.send(openGroupEgg(eggId: eggId, groupId: nil, feedId: feedId)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    @objc  func createWhiteboardChatroom(roomName: String, completion: ((CreateChatroomRequestResult?, Error?) -> Void)?) {
        self.send(CreateChatroomRequest(roomName: roomName)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    @objc  func closeWhiteboardChatroom(roomId: String, completion: ((CloseChatroomRequestResult?, Error?) -> Void)?) {
        self.send(CloseChatroomRequest(roomId: roomId)) { response in
            switch response {
            case .success(let result):
                completion?(result, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
}

import Foundation

struct GetAppInfo: APIRequest {
    typealias Response = AppInfo
    
    var resourceName: String {
        return "version/api/getappinfo"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let os: String
    let version: String
    let uid: Int?
    
    init(os: String = "ios",
         version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
         uid: Int? = nil) {
        self.os = os
        self.version = version
        self.uid = uid
    }
}

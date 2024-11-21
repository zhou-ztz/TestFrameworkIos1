//
//  ErrorLoggingManager.swift
//  YippiCore
//
//  Created by Jerry Ng on 16/04/2021.
//  Copyright © 2021 Chew. All rights reserved.
//

import Foundation

public enum LoggingType {
    case exception, networkError, apiRequestData, apiResponseData, others
}

@objcMembers
public class LogManager: NSObject  {
    static let shared = LogManager()
    private override init() { }

    private var data: [String:Any] = [:]

    public class func LogError(name: String, file: String = #file, line: Int = #line,
                               funName: String = #function, reason: String?) {
        
        let userId = UserDefaults.standard.object(forKey: "TSCurrentUserInfoModel.uid") as? Int
        #if DEBUG
        #else
        
        let title = [name, file, "\(line)", funName].joined(separator: ", ")
        
        #endif
    }

    public class func BFLogError(name: String, file: String = #file, line: Int = #line,
                                 funName: String = #function, code: Int, description: String?) {
        let userId = UserDefaults.standard.object(forKey: "TSCurrentUserInfoModel.uid") as? Int

        #if DEBUG
        
        #else
        
        let title = [name, file, "\(line)", funName].joined(separator: ", ")
        
        #endif
    }

    public class func Log(_ object: Any..., name: String = "", file: String = #file, line: Int = #line,
                          funName: String = #function, loggingType: LoggingType) {
        
        let title = [name, file, "\(line)", funName].joined(separator: ", ")
        let userId = UserDefaults.standard.object(forKey: "TSCurrentUserInfoModel.uid") as? Int
        
        switch loggingType {
        case .exception:
            fallthrough
        case .networkError:
            fallthrough
        default:
            #if DEBUG
            if let data = String(describing: object).data(using: .utf8, allowLossyConversion: false){
                print("⛈⛈⛈'")
                print(data.prettyPrintedJSONString ?? "")
                print("⛈⛈⛈'\n")
            }
            #else
            break
            #endif

        }
    }

    public class func setDeviceString(_ string:String, forKey key:String) {
        shared.data[key] = string
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        if #available(iOS 13.0, *) {
            guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
                  let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .withoutEscapingSlashes]),
                  let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
            return prettyPrintedString
        } else {
            return ""
            // Fallback on earlier versions
        }
    }
}

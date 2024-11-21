//
//  TSURLExtension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//

import Foundation

import Regex

extension URL {
    
    func ts_serverLinkUrlProcess() -> URL {
        let strUrl = self.absoluteString
        let newStrUrl = strUrl.ts_serverLinkProcess()
        if let newUrl = URL(string: newStrUrl) {
            return newUrl
        }
        return self
    }
    
    func appendQueryItems(queryItems:[URLQueryItem]) -> URL? {
        guard queryItems.count > 0 else {
            return self
        }
        guard let originalURLComponent = URLComponents(string: self.absoluteString) else {
            return nil
        }
        var newURLComponent = URLComponents()
        newURLComponent.scheme = originalURLComponent.scheme
        newURLComponent.host = originalURLComponent.host
        newURLComponent.path = originalURLComponent.path
        newURLComponent.queryItems = originalURLComponent.queryItems
        if newURLComponent.queryItems == nil {
            newURLComponent.queryItems = [URLQueryItem]()
        }
        for queryItem in queryItems {
            newURLComponent.queryItems?.append(queryItem)
        }
        return newURLComponent.url
    }
    
    func resolve(completion: ((String?) -> Void)?) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let resolvedUrl = response?.url {
                completion?(resolvedUrl.absoluteString)
            } else {
                completion?(nil)
            }
        }.resume()
    }
    
    func handleDeepLinkOrUniversalUrl() -> URL {
        var urlString: String = ""
        urlString = self.absoluteString
        
        let server = TSUtil.getCurrentEnvironmentConfig()
        
        if self.host == server.universalLinkApiSchema {
            urlString = "\(server.deepLinkSchema)://\(self.path)"
        } else if self.host == server.universalLinkWebSchema {
            urlString = "\(server.deepLinkSchema)://\(self.path)"
        }
        
        return URL(string: urlString)!
    }
    
    func getSizeInMB() -> Double {
        do {
            let data = try Data(contentsOf: self)
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB]
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(data.count)).replacingOccurrences(of: ",", with: ".")
            if let double = Double(string.replacingOccurrences(of: " MB", with: "")) {
                return double
            }
        } catch {
            print("Unable to load data: \(error)")
        }
        
        return 0.0
    }
}

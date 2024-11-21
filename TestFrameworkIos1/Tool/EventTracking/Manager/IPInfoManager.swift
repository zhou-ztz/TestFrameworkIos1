//
//  IPInfoManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/31.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation

class IPInfoManager {
    static let shared = IPInfoManager()
    
    private let ipInfoURL = URL(string: "https://ipinfo.io/ip")!
    private let userDefaultsKey = "storedIPAddress"
    
    func fetchIPAddress(completion: @escaping (String?) -> Void) {
        URLSession.shared.dataTask(with: ipInfoURL) { data, response, error in
            if let error = error {
                print("Error fetching IP address:", error)
                completion(nil)
                return
            }
            
            guard let data = data,
                  let ipAddress = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            else {
                print("Invalid data")
                completion(nil)
                return
            }
            
            self.storeIPAddress(ipAddress)
            completion(ipAddress)
        }.resume()
    }
    
    private func storeIPAddress(_ ipAddress: String) {
        UserDefaults.standard.set(ipAddress, forKey: userDefaultsKey)
    }
    
    func retrieveStoredIPAddress() -> String? {
        return UserDefaults.standard.string(forKey: userDefaultsKey)
    }
}


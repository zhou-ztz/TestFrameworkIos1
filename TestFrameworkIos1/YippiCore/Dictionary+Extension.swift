//
//  Dictionary+Extension.swift
//  Yippi
//
//  Created by Yong Tze Ling on 30/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

extension Dictionary {
    
    var toJSON: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return nil
        }
        return String(data: theJSONData, encoding: .ascii)
    }
}

extension String {
    
    var toDictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch { }
        }
        return nil
    }
}

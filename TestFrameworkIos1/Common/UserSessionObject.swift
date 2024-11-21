//
//  UserSessionObject.swift
//  Yippi
//
//  Created by ChuenWai on 06/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

class TSDuration: NSObject, NSCoding, Codable {
    var start_time: Int
    var end_time: Int

    init(start_time: Int, end_time: Int) {
        self.start_time = start_time
        self.end_time = end_time
    }

    required convenience init(coder aDecoder: NSCoder) {
        let start_time = aDecoder.decodeInteger(forKey: "start_time")
        let end_time = aDecoder.decodeInteger(forKey: "end_time")
        self.init(start_time: start_time, end_time: end_time)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(start_time, forKey: "start_time")
        aCoder.encode(end_time, forKey: "end_time")
    }

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

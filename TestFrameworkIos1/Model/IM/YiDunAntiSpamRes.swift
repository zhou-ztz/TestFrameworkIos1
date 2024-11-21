//
//  YiDunAntiSpam.swift
//  Yippi
//
//  Created by Kit Foong on 26/10/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation

// MARK: - YiDunAntiSpamRes
struct YiDunAntiSpamRes: Decodable {
    var ext: [Ext] = []
    let code, suggestion, status: Int
    let type, version, taskID, extString: String
    
    enum CodingKeys: String, CodingKey {
        case extString = "ext"
        case code, suggestion, type, version
        case taskID = "taskId"
        case status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try (values.decode(Int.self, forKey: .code) ?? 0)
        suggestion = try (values.decode(Int.self, forKey: .suggestion) ?? 0)
        type = try (values.decode(String.self, forKey: .type) ?? "")
        version = try (values.decode(String.self, forKey: .version) ?? "")
        taskID = try (values.decode(String.self, forKey: .taskID) ?? "")
        status = try (values.decode(Int.self, forKey: .status) ?? 0)
        
        extString = try (values.decode(String.self, forKey: .extString) ?? "")
        if extString.isEmpty == false, let data = extString.data(using: .utf8) {
            do {
                let jsonDecoder = JSONDecoder()
                if type == "text" {
                    print(extString)
                    if let singleExt = try (jsonDecoder.decode(Ext.self, from: data) ?? nil) {
                        ext.append(singleExt)
                    }
                } else {
                    ext = try (jsonDecoder.decode([Ext].self, from: data) ?? [])
                }
            } catch {
                print(error.localizedDescription)
                ext = []
            }
        } else {
            ext = []
        }
    }
}

// MARK: - EXT
struct Ext: Codable {
    let antispam: Antispam
    
    enum CodingKeys: String, CodingKey {
        case antispam
    }
}

// MARK: - Antispam
struct Antispam: Codable {
    let frameSize, status: Int?
    let suggestion, censorType, censorTime, resultType: Int
    let isRelatedHit: Bool?
    let name, dataID: String?
    let taskID: String
    let labels: [YiDunLabel]
    
    enum CodingKeys: String, CodingKey {
        case frameSize, status
        case suggestion, censorType, censorTime, resultType
        case isRelatedHit
        case name
        case dataID = "dataId"
        case taskID = "taskId"
        case labels
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        frameSize = try? values.decode(Int.self, forKey: .frameSize)
        status = try? values.decode(Int.self, forKey: .status)
        suggestion = try (values.decode(Int.self, forKey: .suggestion) ?? 0)
        censorType = try (values.decode(Int.self, forKey: .censorType) ?? 0)
        censorTime = try (values.decode(Int.self, forKey: .censorTime) ?? 0)
        resultType = try (values.decode(Int.self, forKey: .resultType) ?? 0)
        isRelatedHit = try? values.decode(Bool.self, forKey: .isRelatedHit)
        name = try? values.decode(String.self, forKey: .name)
        dataID = try? values.decode(String.self, forKey: .dataID)
        taskID = try (values.decode(String.self, forKey: .taskID) ?? "")
        labels = try (values.decode([YiDunLabel].self, forKey: .labels) ?? [])
    }
}

// MARK: - Label
struct YiDunLabel: Codable {
    let subLabels: [SubLabels]?
    let level, label: Int
    let rate: Double?
    
    enum CodingKeys: String, CodingKey {
        case subLabels
        case level, label
        case rate
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        subLabels = try? values.decode([SubLabels].self, forKey: .subLabels)
        level = try (values.decode(Int.self, forKey: .level) ?? 0)
        label = try (values.decode(Int.self, forKey: .label) ?? 0)
        rate = try? values.decode(Double.self, forKey: .rate)
    }
}

// MARK: - SubLabel
struct SubLabels: Codable {
    let subLabel: Int
//    let hitStrategy, subLabel, rate: Int
//    let details: Details
}

// MARK: - Details
struct Details: Codable {
    let hitInfos: [HitInfo]
}

// MARK: - HitInfo
struct HitInfo: Codable {
    let y1, x1, y2, x2: Double
    let value, group: String
}

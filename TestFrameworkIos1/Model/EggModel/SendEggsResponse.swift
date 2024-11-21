//
//  SendEggsResponse.swift
//  Yippi
//
//  Created by Francis Yeap on 5/23/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct SendEggsResponseType: Codable {
    let id, ownerID: Int
    let title, body: String
    let type: Int
    let targetType, targetID: String
    let currency: Int
    let amount: String
    let state: Int
    let createdAt, updatedAt: String
    let redpacketID: Int
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerID = "owner_id"
        case title, body, type
        case targetType = "target_type"
        case targetID = "target_id"
        case currency, amount, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case redpacketID = "redpacket_id"
        case user
    }
    
    
    // MARK: - User
    struct User: Codable {
        let id: Int
        let avatar: Avatar?
        let name: String
        let verified: Verified?
        let extra: Extra
        let certification: Certification?
    }
    
    struct Verified: Codable {
        let type: String
        let icon: String?
        let verifiedDescription: String
        
        enum CodingKeys: String, CodingKey {
            case type, icon
            case verifiedDescription = "description"
        }
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let name, phone: String
        let number, desc: String?
        let files: [Int]?
    }
    
    struct Certification: Codable {
        let id: Int
        let certificationName: String
        let userID: Int
        let data: DataClass?
        let examiner, status: Int
        let createdAt, updatedAt: String
        let icon: String?
        let category: Category
        
        enum CodingKeys: String, CodingKey {
            case id
            case certificationName = "certification_name"
            case userID = "user_id"
            case data, examiner, status
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case icon, category
        }
    }
    
    struct Category: Codable {
        let name, displayName: String
        let categoryDescription: String?
        
        enum CodingKeys: String, CodingKey {
            case name
            case displayName = "display_name"
            case categoryDescription = "description"
        }
    }
    
    // MARK: - Avatar
    struct Avatar: Codable {
        let url: String
        let vendor, mime: String
        let size: Int
        let dimension: Dimension
    }
    
    // MARK: - Dimension
    struct Dimension: Codable {
        let width, height: Int
    }
    
    // MARK: - Extra
    struct Extra: Codable {
        let userID, likesCount, commentsCount, followersCount: Int
        let followingsCount: Int
        let updatedAt: String
        let feedsCount, questionsCount, answersCount, checkinCount: Int
        let lastCheckinCount: Int
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case likesCount = "likes_count"
            case commentsCount = "comments_count"
            case followersCount = "followers_count"
            case followingsCount = "followings_count"
            case updatedAt = "updated_at"
            case feedsCount = "feeds_count"
            case questionsCount = "questions_count"
            case answersCount = "answers_count"
            case checkinCount = "checkin_count"
            case lastCheckinCount = "last_checkin_count"
        }
    }

}

struct SendEggResponse: Decodable {
    let redpacketId: Int
    
    enum CodingKeys: String, CodingKey {
        case redpacketId = "redpacket_id"
    }
}

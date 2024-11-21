//
//  SocialTokenSlotDetails.swift
//  Yippi
//
//  Created by Francis Yeap on 17/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation


struct SocialTokenSlotDetailsRequestType : RequestType {
    typealias ResponseType = SocialTokenSlotDetails
    
    var id: Int
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/event-slot/getSlotDetails/\(id)",
            method: .get, params: nil)
    }
}


struct SocialTokenSlotDetails : Codable {
    
    struct Banner : Codable {
        let colorCode : String?
        let id : Int?
        let imgUrl : String?
        
        enum CodingKeys: String, CodingKey {
            case colorCode = "color_code"
            case id = "id"
            case imgUrl = "img_url"
        }
    }
    
    struct Flag : Codable {
        let imgUrl : String?
        let iso : String?

        enum CodingKeys: String, CodingKey {
            case imgUrl = "img_url"
            case iso = "iso"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            imgUrl = try values.decodeIfPresent(String.self, forKey: .imgUrl)
            iso = try values.decodeIfPresent(String.self, forKey: .iso)
        }
    }
    

    struct Applicant : Codable {

        let id : Int
        let slotId : Int
        let user : User?


        enum CodingKeys: String, CodingKey {
            case id = "id"
            case slotId = "slot_id"
            case user
        }

        struct Avatar : Codable {

            let url : String?


            enum CodingKeys: String, CodingKey {
                case url = "url"
            }
        }
        

        struct User : Codable {
            let avatar : Avatar?
            let country : String?
            let id : Int
            let name : String
            let username : String


            enum CodingKeys: String, CodingKey {
                case avatar = "avatar"
                case country = "country"
                case id = "id"
                case name = "name"
                case username = "username"
            }
        }
    }
    
    let applicants : [Applicant]?
    let available : Int
    let currentCount : Int
    let flags : [Flag]?
    let id : Int
    let banner: Banner?
    // not needed
    //    let country : String
    //    let eventDate : String?
    //    let maxCount : Int?
    //    let slotEnd : String
    //    let slotStart : String
    
    
    enum CodingKeys: String, CodingKey {
        case applicants = "applicants"
        case available = "available"
        case currentCount = "current_count"
        case flags = "flags"
        case id = "id"
        case banner = "banner"
        
        // not needed
        //        case country = "country"
        //        case eventDate = "event_date"
        //        case maxCount = "max_count"
        //        case slotEnd = "slot_end"
        //        case slotStart = "slot_start"
    }
}

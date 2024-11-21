// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

@objcMembers
public class MeetingListItem: NSObject, Decodable {
    public let id, uid, name: String
    public let content, start, end, createtime: String
    public let roomid, role, logo, logolarge: String?
    public let creator, memberCount, applyCount: String
    public let isJoin: Int?

    public var startDate: String {
        return self.start.convertDateFromString(timeType: 0)
    }
    public var endDate: String {
        return self.end.convertDateFromString(timeType: 0)
    }
}

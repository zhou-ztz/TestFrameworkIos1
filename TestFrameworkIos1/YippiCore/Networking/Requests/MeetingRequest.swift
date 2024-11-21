// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

 struct getMeetingList: APIRequest {
     typealias Response = [MeetingListItem]

     var resourceName: String {
        return "meeting/api/meetingList"
    }
    
     var requestMethod: RequestMethod {
        return.post
    }
    
     let type: Int?
     let uid: String?
    
     init(
        type: Int? = nil,
        uid: String? = nil) {
        self.type = type
        self.uid = uid
    }
}

 struct addMeetingRequest: APIRequest {
     typealias Response = MeetingListItem

     var requestMethod: RequestMethod {
        return .post
    }

     var resourceName: String {
        return "meeting/api/createMeeting"
    }

     let uid: String?
     let name: String?
     let content: String?
     let start: String?
     let end: String?
     let image: Data?
     let member: String?

     var file: TypedFile? {
        guard let fileData = image else { return nil }
        return TypedFile(binaryData: fileData, fileName: "avatar.jpg", mimeType: "image/jpg")
    }

     var excludedEncodeKeys: [String]? {
        return ["image"]
    }

     init (
        uid: String? = nil,
        name: String? = nil,
        content: String? = nil,
        start: String? = nil,
        end: String? = nil,
        image: Data? = nil,
        member: String? = nil) {
        self.uid = uid
        self.name = name
        self.content = content
        self.start = start
        self.end = end
        self.image = image
        self.member = member
    }
}

struct uploadImage: APIRequest {
    typealias Response = MeetingListItem
    
    var resourceName: String {
        return "meeting/api/add"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    var binaryData: Data? {
        return imageData
    }
    
    let imageData: Data?
    
    init(data: Data? = nil) {
        self.imageData = data
    }
}

struct deleteMeeting: APIRequest {
    typealias Response = [String:String]
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    var resourceName: String {
        return "meeting/api/del"
    }
    
    let uid: String?
    let room_id: String?
    
    init (
        uid: String? = nil,
        room_id: String? = nil){
            self.uid = uid
            self.room_id = room_id
        }
}

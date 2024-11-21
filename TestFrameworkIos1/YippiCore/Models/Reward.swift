// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

@objcMembers
public class SendRewardResult: NSObject, APIResponseType {
    public let message: String?
    public let state: ApiState
}

import Foundation

public struct State: Decodable {
    public let code: Int
    public let msg: String
    public let debugMsg: String
    public let url: String
}

public protocol APIResponseType: Decodable {
    var state: ApiState { get } /// Removed in latest api
    var message: String? { get }
}

/// Top level response for every request to the Marvel API
/// Everything in the API seems to be optional, so we cannot rely on having values here
public struct APIResponse<Response: Decodable>: Decodable {
    /// Whether it was ok or not
    public let state: State
    /// Message that usually gives more information about some error
    public let message: String?
    
    public let data: Response?
    
    enum CodingKeys: String, CodingKey {
        case state
        case message
        case data
    }
    
    // NOTE: Need this because of server return empty object {} instead of null for failed API requests which cause issue on decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(State.self, forKey: .state)
        let message = try container.decodeIfPresent(String.self, forKey: .message)
        
        if state.code == 0 || state.code == 200 {
            self.data = try container.decode(Response?.self, forKey: .data)
        } else {
            self.data = nil
        }
        
        self.state = state
        self.message = message
    }
}

//
//    SocialExchange.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


struct SocialExchangeRequestType: RequestType {
    typealias ResponseType = SocialExchangeModel
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/token/exchangeRates",
            method: .get, params: nil)
    }
}

struct SocialExchangeModel : Codable {
    struct Data : Codable {

        let fromTokenId : Int
        let fromTokenName : String
        let inverseValue : Int
        let toTokenId : Int
        let toTokenName : String
        let value : Int


        enum CodingKeys: String, CodingKey {
            case fromTokenId = "from_token_id"
            case fromTokenName = "from_token_name"
            case inverseValue = "inverse_value"
            case toTokenId = "to_token_id"
            case toTokenName = "to_token_name"
            case value = "value"
        }
    }

    let data : [Data]?


    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}



struct SocialSwapTokenRequestType: RequestType {
    typealias ResponseType = SocialTokenBalanceModel
    
    var fromToken: Int
    var toToken: Int
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/token/exchangeToken",
            method: .post, params: [
                "from_token": fromToken,
                "to_token": toToken
        ])
    }
}


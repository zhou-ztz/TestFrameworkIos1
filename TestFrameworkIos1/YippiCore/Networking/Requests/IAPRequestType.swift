//
//  IAPRequestType.swift
//  Yippi
//
//  Created by Yong Tze Ling on 10/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

struct IAPProductsRequestType: RequestType {
    typealias ResponseType = IAPProductsResponse
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/wallet/api/iap/products",
            method: .get,
            params: nil)
    }
}

struct IAPProductsResponse: Decodable {
    let productID: [String]
    
    enum CodingKeys: String, CodingKey {
        case productID
    }
}

struct IAPReceiptValidationType: RequestType {
    
    typealias ResponseType = ReceiptValidationResponse
    
    let receipt: String
    let productId: String
    
    var data: YPRequestData {
        let params: [String: Any] = [
            "receipt": receipt,
            "product_id": productId
        ]
        
        return YPRequestData(path: "/wallet/api/iap/apple/verify", method: .put, params: params)
    }
}

struct ReceiptValidationResponse: Decodable {
    let status: Bool?
    let message: String?
    let yipps: YippsResponse?
    
    enum CodingKeys: String, CodingKey {
        case status, message, yipps
    }
}

struct YippsResponse: Decodable {
    let sum: String?
    let type: Int?
    
    enum CodingKeys: String, CodingKey {
        case sum, type
    }
}

struct IAPInitiateRequest: RequestType {
    typealias ResponseType = IAPInitiateResponse
    
    let productId: String
    
    var data: YPRequestData {
        let params: [String: Any] = [
            "product_id": productId
        ]
        
        return YPRequestData(path: "/wallet/api/iap/apple/initiate", method: .post, params: params)
    }
}

struct IAPInitiateResponse: Decodable {
    let status: Bool?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case status, message
    }
}

enum IAPManagerError: Error {
    case noPermission
    case noProductIDsFound
    case noProductsFound
    case productRequestFailed
    case initiateFailed(message: String)
    case validationFail(message: String)
    case purchaseFailed(message: String)
    case needVerifyKyc(error: YPErrorType)
    case serverProductsIdFailed(message: String)
}

extension IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noPermission: return "iap_not_allowed".localized
        case .noProductIDsFound: return "iap_product_ids_not_found".localized
        case .noProductsFound: return "iap_not_found".localized
        case .productRequestFailed: return "iap_unable_to_fetch".localized
        case .initiateFailed(let message): return message
        case .validationFail(let message): return message
        case .purchaseFailed(let message): return message
        case .needVerifyKyc(let error): return error.localizedDescription
        case .serverProductsIdFailed(let message): return message
        }
    }
}

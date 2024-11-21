//
//  Apollo.swift
//  Yippi
//
//  Created by Francis Yeap on 5/17/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import Apollo

public var YPApolloClient: ApolloClient {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 10.0
    // Add additional headers as needed
    let tokenObj = TSAccountTokenModel()
    if let token = tokenObj?.token,
        let tokenType = tokenObj?.tokenType {
        var headers = YPCustomHeaders
        headers.updateValue("\(tokenType) \(token)", forKey: "Authorization")
        configuration.httpAdditionalHeaders = headers // Replace `<token>`
        
    }
    
    let url = URL(string: TSAppConfig.share.rootServerAddress + "graphql/v1")!
    
    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
}

public var YPCustomHeaders: [String: String] {
    return YPHTTPHeaderFields.headers
}

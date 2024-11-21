//
//  DataReponseModel.swift
//  Yippi
//
//  Created by Francis Yeap on 5/14/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

struct DataReponseModel<T: Decodable>: Decodable {
    let data: T
}

struct EmptyResponseModel: Decodable { }

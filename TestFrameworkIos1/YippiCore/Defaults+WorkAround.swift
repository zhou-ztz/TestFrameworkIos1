//
//  Defaults+WorkAround.swift
//  YippiCore
//
//  Created by apple on 2022/3/22.
//  Copyright © 2022 Chew. All rights reserved.
//

import SwiftyUserDefaults
import Foundation

extension DefaultsSerializable {
    public static var _defaultsArray: DefaultsArrayBridge<[T]> { return DefaultsArrayBridge() }
}
extension DefaultsSerializable where Self: Codable {
    public static var _defaults: DefaultsCodableBridge<Self> { return DefaultsCodableBridge() }
    public static var _defaultsArray: DefaultsCodableBridge<[Self]> { return DefaultsCodableBridge() }
}

extension DefaultsSerializable where Self: RawRepresentable {
    public static var _defaults: DefaultsRawRepresentableBridge<Self> { return DefaultsRawRepresentableBridge() }
    public static var _defaultsArray: DefaultsRawRepresentableArrayBridge<[Self]> { return DefaultsRawRepresentableArrayBridge() }
}

extension DefaultsSerializable where Self: NSCoding {
    public static var _defaults: DefaultsKeyedArchiverBridge<Self> { return DefaultsKeyedArchiverBridge() }
    public static var _defaultsArray: DefaultsKeyedArchiverBridge<[Self]> { return DefaultsKeyedArchiverBridge() }
}


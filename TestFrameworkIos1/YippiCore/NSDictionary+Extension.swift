// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

public extension NSDictionary {
    func valueAsDouble(forKey: String, defaultValue: Double = 0) -> Double{
        if let any = object(forKey: forKey) {
            if let number = any as? NSNumber {
                return number.doubleValue
            } else if let str = any as? NSString {
                return str.doubleValue
            }
        }
        return defaultValue
    }
    
    func valueAsFloat(forKey: String, defaultValue: Float = 0) -> Float{
        if let any = object(forKey: forKey) {
            if let number = any as? NSNumber {
                return number.floatValue
            } else if let str = any as? NSString {
                return str.floatValue
            }
        }
        return defaultValue
    }
    
    func valueAsInt(forKey: String, defaultValue: Int = 0) -> Int{
        if let any = object(forKey: forKey) {
            if let number = any as? NSNumber {
                return number.intValue
            } else if let str = any as? NSString {
                return str.integerValue
            }
        }
        return defaultValue
    }
    
    func valueAsString(forKey: String, defaultValue: String = "") -> String{
        if let any = object(forKey: forKey) {
            if let number = any as? NSNumber {
                return number.stringValue
            } else if let str = any as? String {
                return str
            }
        }
        return defaultValue
    }
    
    func valueAsBoolean(forKey: String, defaultValue: Bool = false) -> Bool {
        if let any = object(forKey: forKey) {
            if let num = any as? NSNumber {
                return num.boolValue
            } else if let str = any as? NSString {
                return str.boolValue
            }
        }
        return defaultValue
    }
}

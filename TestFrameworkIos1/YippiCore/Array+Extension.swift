// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import CryptoSwift
import UIKit

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    func removingDuplicates<T: Equatable>(byKey key: KeyPath<Element, T>)  -> [Element] {
        var result = [Element]()
        var seen = [T]()
        for value in self {
            let key = value[keyPath: key]
            if !seen.contains(key) {
                seen.append(key)
                result.append(value)
            }
        }
        return result
    }

    func toAES256Encryption() -> String {
        var returnStr = ""

        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            let encryptData = String(data: data, encoding: .utf8)
            let encryptor = try AES(key: "GDnDRbDPYyUsiO6PlpBnbDKP3mhNI0Zc".bytes, blockMode: ECB())
            let cipherText = try encryptor.encrypt(encryptData!.bytes)

            returnStr = cipherText.toBase64()
        } catch let error {
            LogManager.LogError(name: "Encryption Error", reason: error.localizedDescription)
        }

        return returnStr
    }
    // 数组去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}

extension Array where Element == String {
    func containsIgnoringCase(_ element: Element) -> Bool {
        contains { $0.caseInsensitiveCompare(element) == .orderedSame }
    }
}

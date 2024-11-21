//
//  ExtensionStringCrypto.swift
//  RewardsLink
//
//  Created by Kelvin Leong on 23/05/2024.
//

import Foundation
import CommonCrypto
import Security

extension String {
    
    var md5: String {
        guard let data = self.data(using: .utf8) else { return "" }
        let md5Data = data.md5
        return md5Data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var md5Hex: String {
        guard let data = self.data(using: .utf8) else { return "" }
        return data.md5.hexString
    }
    
    var sha256: String {
        guard let data = self.data(using: .utf8) else { return "" }
        return data.sha256.hexString
    }
    
    var base64Encode: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }
    
    var base64Decode: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func tripleDesEncrypt(key: String, iv: String) -> String? {
        guard let data = self.data(using: .utf8),
              let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            return nil
        }
        
        let keyLength = kCCKeySize3DES
        let dataLength = data.count
        let bufferSize = dataLength + kCCBlockSize3DES
        var buffer = Data(count: bufferSize)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            data.withUnsafeBytes { dataBytes in
                ivData.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithm3DES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, keyLength,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, dataLength,
                                bufferBytes.baseAddress, bufferSize,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            return nil
        }
        
        buffer.count = numBytesEncrypted
        return buffer.base64Encode
    }
    
    func tripleDESDecrypt(key: String, iv: String) -> String? {
        guard let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            return nil
        }
        
        let keyLength = kCCKeySize3DES
        let dataLength = self.count
        let bufferSize = dataLength + kCCBlockSize3DES
        var buffer = Data(count: bufferSize)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            Data(base64Encoded: self)!.withUnsafeBytes { dataBytes in
                ivData.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithm3DES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, keyLength,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, dataLength,
                                bufferBytes.baseAddress, bufferSize,
                                &numBytesDecrypted)
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            return nil
        }
        
        buffer.count = numBytesDecrypted
        return String(data: buffer, encoding: .utf8)
    }
}

extension Data {
    var md5: Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var sha256: Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    
    var base64Encode: String? {
        return self.base64EncodedString()
    }
    
    var base64Decode: String? {
        return String(data: self, encoding: .utf8)
    }
    
    // Encrypt the data using AES-256-CBC
    func aes256Encrypt(key: Data, iv: Data) -> Data? {
        return aesCrypt(operation: CCOperation(kCCEncrypt), key: key, iv: iv)
    }
    
    // Decrypt the data using AES-256-CBC
    func aes256Decrypt(key: Data, iv: Data) -> Data? {
        return aesCrypt(operation: CCOperation(kCCDecrypt), key: key, iv: iv)
    }
    
    // Common cryptographic function
    private func aesCrypt(operation: CCOperation, key: Data, iv: Data) -> Data? {
        guard key.count == kCCKeySizeAES256 else {
            print("Error: Failed to set a key size")
            return nil
        }
        
        guard iv.count == kCCBlockSizeAES128 else {
            print("Error: Failed to set an IV size")
            return nil
        }
        
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: self.count + kCCBlockSizeAES128)
        
        let status = CCCrypt(
            operation,                      // Operation (encrypt/decrypt)
            CCAlgorithm(kCCAlgorithmAES),   // Algorithm
            CCOptions(kCCOptionPKCS7Padding), // Options for padding
            key.bytes,                      // Key bytes
            key.count,                      // Key length
            iv.bytes,                       // IV bytes
            self.bytes,                     // Input data bytes
            self.count,                     // Input data length
            &outBytes,                      // Output data buffer
            outBytes.count,                 // Output data buffer length
            &outLength                      // Output data length
        )
        
        guard status == kCCSuccess else {
            print("Error: \(status)")
            return nil
        }
        
        return Data(bytes: outBytes, count: outLength)
    }
}

// Helper extension to get bytes from Data
private extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

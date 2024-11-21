//
//  AppUtil.swift
//  Yippi
//
//  Created by Khoo on 10/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import iOSPhotoEditor
import IQKeyboardManagerSwift
import CommonCrypto



let MAX_UPLOAD_IMAGE_SIZE = 2000000.0
let IPHONEX_STATUS_BAR_HEIGHT = 45.0
let STATUS_BAR_HEIGHT = 20.0

class AppUtil: NSObject {
    static let shared = AppUtil()
    
    func getIPAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
   
    func isFileExist(_ string: String?) -> Bool {
        guard let string = string else { return false }
        if FileManager.default.fileExists(atPath: string) {
            return true
        }
        return false
    }
    
    func makeDocumentFullPath(_ filename: String) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let docDir = paths[0]
        let fullPath = "\(docDir)/\(filename)"
        return fullPath
    }
    
    func getFilesFromPath(_ path: URL) -> [URL] {
        let fileManager = FileManager.default
        var files : [URL] = []
        do {
            if let temp = try? fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil) {
                files = temp
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
        return files
    }
    
    @discardableResult func deleteFile(atPath filePath: String?) -> Bool {
        guard let filePath = filePath else { return false }
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch {
            
        }
        
        return false
    }
    
    @discardableResult func addSkipBackupAttributeToItem(at URL: URL?) -> Bool {
        guard let URL = URL  else { return false }
        assert(FileManager.default.fileExists(atPath: URL.path))
        
        var success = false
        do {
            try (URL as NSURL).setResourceValue(NSNumber(value: true), forKey: .isExcludedFromBackupKey)
            success = true
        } catch {
            
        }
        
        return success
    }
    
    func write(_ data: Data?, toFile location: String?) -> Bool {
        guard let data = data, let location = location else { return false }
        do {
            if let url = URL(string: location) {
                try data.write(to: url, options: .atomic)
                if isFileExist(location) {
                    addSkipBackupAttributeToItem(at: URL(fileURLWithPath: location))
                    
                    return true
                }
            }
        } catch {}
        
        return false
    }
    
    func writeContent(_ content: [Any]?, location: String?) -> Bool {
        guard let content = content, let location = location else { return false }
        if let url = URL(string: location) {
            let status = (content as NSArray).write(to: url, atomically: false)
            if status && isFileExist(location) {
                addSkipBackupAttributeToItem(at: URL(fileURLWithPath: location))
            }
            
            return status
        }
        return false
    }
    
    func content(fromFile location: String?) -> Any? {
        if let location = location {
            var object: Any? = NSArray(contentsOfFile: location)
            if object == nil {
                object = NSDictionary(contentsOfFile: location) as Dictionary?
            }
            return object
        }
        return nil
    }
    
    func resizeImage(forThumbnail image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        var newSize: CGSize = CGSize()
        let scale: CGFloat = CGFloat(image.size.width / 50.0)
        
        newSize.width = CGFloat(image.size.width / scale)
        newSize.height = CGFloat(image.size.height / scale)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizeImage(forUpload image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        var newSize = AppUtil.shared.resize(forUpload: image.size)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imageData = newImage?.pngData()
        var imageSize:Double = Double(imageData?.count ?? 0)
        
        if newImage != nil {
            while imageSize > MAX_UPLOAD_IMAGE_SIZE {
                newSize = CGSize(width: newSize.width * 0.8, height: newSize.height * 0.8)
                UIGraphicsBeginImageContext(newSize)
                newImage!.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                imageData = newImage!.pngData()
                imageSize = Double(imageData!.count)
            }
        }
        
        return newImage
    }
    
    func resize(forUpload size: CGSize) -> CGSize {
        var scaleFactor: CGFloat = 1.0
        let maxWidth: CGFloat = 1000.0
        let maxHeight: CGFloat = 1000.0
        
        if size.width <= maxWidth && size.height <= maxHeight {
            return size
        }
        
        if size.width >= size.height {
            scaleFactor = size.width / maxWidth
        } else {
            scaleFactor = size.height / maxHeight
        }
        
        return CGSize(width: CGFloat(size.width / scaleFactor), height: CGFloat(size.height / scaleFactor))
    }
    
    func generateQRCode(_ string: String?) -> UIImage? {
        guard let string = string else { return nil }
        let stringData = string.data(using: .isoLatin1)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        
        let qrCode = qrFilter?.outputImage
        
        return AppUtil.shared.createNonInterpolatedUIImage(from: qrCode, withScale: 20 * UIScreen.main.scale)
    }
    
    func createNonInterpolatedUIImage(from image: CIImage?, withScale scale: CGFloat) -> UIImage? {
        
        guard let image = image else { return nil }
        // Render the CIImage into a CGImage
        let cgImage = CIContext(options: nil).createCGImage(image, from: image.extent)
        
        // Now we'll rescale using CoreGraphics
        UIGraphicsBeginImageContext(CGSize(width: image.extent.size.width * scale, height: image.extent.size.width * scale))
        let context = UIGraphicsGetCurrentContext()
        // We don't want to interpolate (since we've got a pixel-correct image)
        context!.interpolationQuality = CGInterpolationQuality.none
        context?.draw(cgImage!, in: context!.boundingBoxOfClipPath)
        // Get the image out
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        // Tidy up
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func fileLocation(fromUrl url: String?) -> URL? {
        guard let url = url else { return nil }
        let defaults = UserDefaults.standard
        var fileName = defaults.object(forKey: url) as? String
        
        if fileName == nil {
            let udid = CFUUIDCreate(nil)
            fileName = CFUUIDCreateString(nil, udid) as String?
        }
        
        let filePath = AppUtil.shared.makeDocumentFullPath(fileName ?? "")
        if AppUtil.shared.isFileExist(filePath) {
            return URL(fileURLWithPath: filePath)
        }
        
        return nil
        
    }
    
    func image(from view: UIView?) -> UIImage? {
        guard let view = view else { return nil }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func convert(intoMD5 string: String?) -> String? {
        guard let string = string else { return nil }
        let str = string.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>(bitPattern: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result![i])
        }
        
        return String(format: hash as String)
    }
    
    func rotate(_ src: UIImage?, orientation: UIImage.Orientation) -> UIImage? {
        guard let src = src else { return nil }
        UIGraphicsBeginImageContext(src.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        if orientation == .right {
            context?.rotate(by: .pi/2)
        } else if orientation == .left {
            context?.rotate(by: .pi/2)
        } else if orientation == .down {
            // NOTHING
        } else if orientation == .up {
            context?.rotate(by: .pi/2)
        }
        
        src.draw(at: CGPoint(x: 0, y: 0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func nsStringIsValidEmail(_ checkString: String?) -> Bool {
        guard let checkString = checkString else { return false }
        let stricterFilter = false
        let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailRegex = stricterFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: checkString)
        
    }
    
    func isIphoneX() -> Bool {
        let screenHeight = UIScreen.main.bounds.size.height
        return screenHeight == 812.0
    }
    
    func navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    func statusBarHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.size.height
        return CGFloat((screenHeight == 812.0) ? IPHONEX_STATUS_BAR_HEIGHT : STATUS_BAR_HEIGHT)
    }
    
    func bottomSpace() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.size.height
        return (screenHeight == 812.0) ? 35.0 : 0.0
    }
    
    func createPhotoEditor(for image: UIImage?) -> PhotoEditorViewController? {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        
        let vc = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
        vc.image = image
        return vc
    }
    
    /// 设备IP - 埋点数据
    func getDeviceIP() -> String {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first ?? ""
    }
    
    /// 获取当前经度
    func getCurrentLongitude() -> String {
        return Device.appLoction.coordinate.longitude.toFloat == 0 ? "101.61245365502157" : Device.appLoction.coordinate.longitude.stringValue
    }
    
    /// 获取当前纬度
    func getCurrentLatitude() -> String {
        return Device.appLoction.coordinate.latitude.toFloat == 0 ? "3.1679279092002086" : Device.appLoction.coordinate.latitude.stringValue
    }
}

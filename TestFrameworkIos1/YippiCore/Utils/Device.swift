// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation
import CoreTelephony
import KeychainAccess
import AVFoundation
import CoreLocation

public struct Device {
    public static let currentUDID = Device.uniqueDeviceIdentifier()
    private static func uniqueDeviceIdentifier() -> String {
        let keychain = Keychain(service: AppEnvironment.current.bundleIdentifier)
        var deviceUUID = String.empty
        do {
            if let uuid = try keychain.getString(Constants.KeyChain.deviceUUID) {
                deviceUUID = uuid
            } else {
                deviceUUID = UIDevice.current.identifierForVendor?.uuidString ?? String.empty
                keychain[Constants.KeyChain.deviceUUID] = deviceUUID
            }
        } catch {
            LogManager.Log(error, loggingType: .exception)
        }
        return deviceUUID
    }
    
    public static func currentCountry() -> Country? {
        let networkInformation = CTTelephonyNetworkInfo()
        guard let carrier = networkInformation.subscriberCellularProvider,
              let code = carrier.isoCountryCode else {
            return Country.default
        }
        
        let country = Country(isoCode: code)
        return country
    }
    
    public static var appLoction: CLLocation = CLLocation()
    
    public static var sizeRatioBasedOnIphone8: CGFloat {
        return UIScreen.main.bounds.width / 375
    }
    
    public static func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? String.empty
    }
    
    public static func appBuildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? String.empty
    }
    
    public static func hasTopNotch() -> Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        
        return false
    }
    
    public static func safeTop() -> Int {
        return UIScreen.main.bounds.size.height < 812 ? 20: 44
    }
    
    public static var isLandscape: Bool {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            return false
        case .landscapeLeft, .landscapeRight:
            return true
        default:
            return UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
    }
    
    public static var screenOrientation: UIDeviceOrientation {
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            return .landscapeLeft
        } else {
            return .portrait
        }
    }
    
    public static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod1,1":  return "iPod Touch 1"
        case "iPod2,1":  return "iPod Touch 2"
        case "iPod3,1":  return "iPod Touch 3"
        case "iPod4,1":  return "iPod Touch 4"
        case "iPod5,1":  return "iPod Touch (5 Gen)"
        case "iPod7,1":   return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"
        case "iPhone5,1":   return "iPhone 5"
        case  "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3":  return "iPhone 5c (GSM)"
        case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1":  return "iPhone 5s (GSM)"
        case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1":   return "iPhone 7"
        case "iPhone9,2":  return "iPhone 7 Plus"
        case "iPhone9,3":  return "iPhone 7"
        case "iPhone9,4":  return "iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":   return "iPhone 8"
        case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
        case "iPhone10,3","iPhone10,6":   return "iPhone X"
            
        case "iPhone11,8":   return "iPhone XR"
        case "iPhone11,2":   return "iPhone XS"
        case "iPhone11,6","iPhone11,4":   return "iPhone XS Max"
        case "iPhone12,1":   return "iPhone 11"
        case "iPhone12,3":   return "iPhone 11 Pro"
        case "iPhone12,5":   return "iPhone 11 Pro Max"
        case "iPhone12,8":   return "iPhone SE2"
        case "iPhone13,1":   return "iPhone 12 mini"
        case "iPhone13,2":   return "iPhone 12"
        case "iPhone13,3":   return "iPhone 12 Pro"
        case "iPhone13,4":   return "iPhone 12 Pro Max"
            
        case "iPhone14,2":   return "iPhone 13 Pro"
        case "iPhone14,4":   return "iPhone 13 mini"
        case "iPhone14,5":   return "iPhone 13"
        case "iPhone14,6":   return "iPhone SE3"
        case "iPhone14,3":   return "iPhone 13 Pro Max"
        case "iPhone14,7":   return "iPhone 14"
        case "iPhone14,8":   return "iPhone 14 Plus"
        case "iPhone15,2":   return "iPhone 14 Pro"
        case "iPhone15,3":   return "iPhone 14 Pro Max"
            
        case "iPad1,1":   return "iPad"
        case "iPad1,2":   return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":   return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
            
        case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":   return "Apple TV 4"
        case "i386", "x86_64":   return "Simulator"
        default:  return identifier
        }
    }
    
    public static func isSmallScreenDevice() -> Bool {
        if UIScreen.main.bounds.height > 700 {
            return false
        }
        
        return true
    }
    
    public static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

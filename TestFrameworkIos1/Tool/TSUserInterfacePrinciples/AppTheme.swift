import UIKit
import SwiftHEXColors

public extension AppTheme {
    static func UIColorFromRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}

// TODO: https://medium.com/ios-os-x-development/a-smart-way-to-manage-colours-schemes-for-ios-applications-development-923ef976be55
@objcMembers
public class AppTheme : NSObject {

    public static let dimmedLightBackground = UIColor(white: 100.0/255.0, alpha: 0.3)
    public static let dimmedDarkBackground = UIColor(white: 50.0/255.0, alpha: 0.3)
    public static let dimmedDarkestBackground = UIColor(white: 0, alpha: 0.5)

    public static let materialBlack = UIColor(red: 36, green: 37, blue: 38  )

    public static let primaryColor = UIColor(hexString: "#ED1A3B")!
    public static let primaryBlueColor = UIColor(hexString: "#3bb3ff")!
    //UIColor(hexString: "#2CACE3") // UIColor(hexString: "#0FC5E1") //0FACF3 (choose this?)
    public static let primaryRedColor = UIColor(hexString: "#ED1A3B")!
    public static let primaryLightGreyColor = UIColor(hexString: "#f6f6f6")!
    public static let primaryLightColor = UIColor(hexString: "#72c6ea")! // UIColor(hexString: "#0FC5E1") //0FACF3 (choose this?)

    public static let secondaryColor = UIColorFromRGB(red: 254, green: 207, blue: 12) // #sunflow

    public static let selectedPrimaryColor = UIColor(hexString: "#1F7DA6")!
    public static let aquaGreen = UIColorFromRGB(red: 16, green: 206, blue:  136)
    public static let warmBlue = UIColorFromRGB(red: 19, green: 96, blue:  185)
    public static let dullBlue = UIColorFromRGB(red: 71, green: 110, blue: 154) // #dullBlue
    public static let twilightBlue = UIColorFromRGB(red: 12, green: 77, blue: 152) // #twilightBlue
    public static let aquaBlue = UIColorFromRGB(red: 59, green: 179, blue: 255)
    public static let sunflowerYellow = UIColorFromRGB(red: 254, green: 220, blue: 0.0) // #sunflowerYellow
    public static let squash =  UIColorFromRGB(red: 246, green: 147, blue: 33) // #squash
    public static let brownGrey = UIColorFromRGB(red: 136, green: 136, blue: 136)
    public static let softBlue = UIColorFromRGB(red: 102, green: 169, blue: 240)
    public static let lightBlue = UIColor(hexString: "#d3e7f8")!
    public static let grey = UIColor(hexString: "#F0F0F0")!
    public static let backgroundColor = UIColorFromRGB(red: 245, green: 245, blue: 245)
    public static let darkGrey = UIColorFromRGB(red: 66, green: 66, blue: 66)
    public static let lightGrey = UIColor.lightGray
    public static let pinkishGrey = UIColorFromRGB(red: 199, green: 199, blue: 199)
    public static let headerTitleGrey = UIColorFromRGB(red: 128, green: 128, blue: 128)
    public static let white = UIColor.white
    public static let black = UIColorFromRGB(red: 3, green: 3, blue: 3)
    public static let red = UIColor(red: 0.87, green: 0.13, blue: 0.12, alpha: 1.0)
    public static let blue = UIColor(hexString: "#2CACE3")!
    public static let waveBlue = UIColorFromRGB(red: 4, green: 36, blue: 68)
    public static let headerGrey = UIColorFromRGB(red: 240, green: 240, blue: 240)
    public static let blueGrey = UIColor(hexString: "#99a9b4")!
    public static let inputContainerGrey = UIColor(hex: 0xf5f5f5)
    public static let imStickerBorder = UIColor(hexString: "#e9e9e9")!
    public static let indicatorColor = UIColorFromRGB(red: 240, green: 240, blue: 240)
    public static let toxicGreen = UIColor(hexString: "#23da35")!
    public static let orange = UIColorFromRGB(red: 245, green: 166, blue: 35)
    public static let dimOrange = UIColorFromRGB(red: 245, green: 149, blue: 40)
    public static let mentionBlueColor = UIColor(hex: 0x0092ff)
    public static let warmGrey = UIColorFromRGB(red: 155, green: 155, blue: 155)
    public static let dodgerBlue = UIColor(red: 59.0/255.0, green: 179.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    public static let inactiveGrey = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1.0)
    public static let shadowGrey = UIColor(red: 112.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 1.0)
    public static let errorRed = UIColorFromRGB(red: 224, green: 1, blue: 0)
    
    public static let merchantNameLightGrey = UIColor(hexString: "#b8b8b8")!
    
    public static let merchantNameTextGrey = UIColor(hexString: "#5D5C5D")!
    
    public static let feedExpandBlue = UIColor(hexString: "#3498DB")!
    
    
    public struct LocationTag {
        public static let locationTagBg = UIColorFromRGB(red: 197, green: 233, blue: 255)
    }
    
    public struct Sticker {
        public static let lightBlue = UIColorFromRGB(red: 232, green: 246, blue: 255)
    }
    
    public struct Live {
        public static let treasureRed = UIColorFromRGB(red: 218, green: 0, blue: 0)
        public static let treasureYellow = UIColorFromRGB(red: 247, green: 181, blue: 0)
        public static let liveSettingBackground = UIColorFromRGB(red: 255, green: 255, blue: 255)
        public static let liveSettingTitleBg = UIColorFromRGB(red: 249, green: 249, blue: 249)
        public static let liveSettingTitleText = UIColorFromRGB(red: 0, green: 0, blue: 0.85)
        public static let liveSettingQualityBorder = UIColorFromRGB(red: 220, green: 220, blue: 220)
    }
    
    struct PopupMenu {
        public static let backgroundColor = UIColor(hexString: "#202020")!
        public static let selectedBackgroundColor = UIColor(hexString: "#2E2E2E")!
    }
    
    public struct IM {
        public static let RecordSelectLabelTextColor = UIColor(hexString: "ffffff")
        public static let RecordSelectLabelTextGrayColor = UIColor(hexString: "999999")
        public static let RecordSelectStartButtonGrayColor = UIColor(hexString: "d0d0d0")
    }
    
    public struct Font {
        public static func italic(_ size: CGFloat) -> UIFont {
            return UIFont.italicSystemFont(ofSize: size)
        }
        
        public static func regular(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size)
        }
        
        public static func semibold(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        
        public static func bold(_ size: CGFloat) -> UIFont {
            return UIFont.boldSystemFont(ofSize: size)
        }

        public static func heavy(_ size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .heavy)
        }
    }
    
    public static func AppGradientColor(width: CGFloat, height: CGFloat, colorTop: CGColor, colorBottom: CGColor) -> CAGradientLayer {
        //let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [colorTop, colorBottom]
        layer.locations = [0.0, 0.35]
        layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        return layer
        //}()
    }

    typealias fontSize = FontSize
}

@objcMembers
public class FontSize: NSObject {
    public static let defaultNicknameSmallFontSize : CGFloat = 9
    public static let defaultTipAndNotiFontSize : CGFloat = 9
    public static let defaultLocationDefaultFontSize : CGFloat = 12
    public static let defaultNicknameFontSize : CGFloat = 13
    public static let defaultTextFontSize : CGFloat = 14
    public static let defaultChatroomMsgFontSize : CGFloat = 16

    private static func adjustFontSize(fontSize: CGFloat) -> CGFloat {
        var calculatedFontSize = CGFloat(fontSize)
        let textSizeScale = UserDefaults.standard.integer(forKey: "textSize")

        switch textSizeScale {
        case 0:
            calculatedFontSize = CGFloat(fontSize) * 0.9
            break
        case 1:
            calculatedFontSize = CGFloat(fontSize)
            break
        case 2:
            calculatedFontSize = CGFloat(fontSize) * 1.10
            break
        case 3:
            calculatedFontSize = CGFloat(fontSize) * 1.20
            break
        case 4:
            calculatedFontSize = CGFloat(fontSize) * 1.30
            break
        case 5:
            calculatedFontSize = CGFloat(fontSize) * 1.40
            break
        default:
            calculatedFontSize = CGFloat(fontSize)
            break
        }
        return calculatedFontSize
    }

    public static var tipAndNotiFontSize: CGFloat {
        get {
            return adjustFontSize(fontSize: defaultTipAndNotiFontSize)
        }
    }

    public static var locationDefaultFontSize: CGFloat {
        get {
            return adjustFontSize(fontSize: defaultLocationDefaultFontSize)
        }
    }

    public static var nicknameFontSize: CGFloat {
        get {
            return adjustFontSize(fontSize: defaultNicknameFontSize)
        }
    }

    public static var nicknameSmallFontSize: CGFloat {
        get {
            return adjustFontSize(fontSize: defaultNicknameSmallFontSize)
        }
    }

    public static var defaultFontSize: CGFloat {
        get {
            return adjustFontSize(fontSize: defaultTextFontSize)
        }
    }

    public static var chatroomMsgFontSize: CGFloat {
        get {
            return adjustFontSize(fontSize: defaultChatroomMsgFontSize)
        }
    }
}

import Foundation
import UIKit

public enum ButtonStyle {
    case textButton(text: String, textColor: UIColor)
    case stickerButton(text: String)
    case deleteSticker(image: UIImage?)
    case downloadSticker(image: UIImage?)
    case `default`(text: String, color: UIColor)
    case waveButton(text: String, backgroundColor: UIColor, textColor: UIColor, borderWidth: CGFloat)
    case custom(text: String, textColor: UIColor, backgroundColor: UIColor, cornerRadius: CGFloat, fontWeight: UIFont.Weight = .bold)
}

public extension UIButton {
    
    func applyStyle(_ style: ButtonStyle) {
        setImage(nil, for: .normal)
        setTitle(nil, for: .normal)
        self.contentMode = .center
        self.imageView?.contentMode = .scaleAspectFit
        
        switch style {
        case .stickerButton(let text):
            setTitleColor(AppTheme.red, for: .normal)
            setTitle(text, for: .normal)
            applyBorder(color: AppTheme.red, width: 1)
            roundCorner()
            titleLabel?.font = AppTheme.Font.bold(14)
            
        case .deleteSticker(let image):
            applyBorder()
            setImage(image, for: .normal)
            
        case .downloadSticker(let image):
            applyBorder()
            setImage(image, for: .normal)
            
        case let .textButton(text, textColor):
            setTitle(text, for: .normal)
            setTitleColor(textColor, for: .normal)
            titleLabel?.font = AppTheme.Font.regular(13)
            
        case let .default(text, color):
            setTitle(text.uppercased(), for: .normal)
            setTitleColor(AppTheme.warmBlue, for: .normal)
            roundCorner(self.bounds.height/2)
            backgroundColor = color
            titleLabel?.font = AppTheme.Font.semibold(15)
        
        case let .waveButton(text, backgroundColor, textColor, borderWidth):
            setTitle(text, for: .normal)
            self.backgroundColor = backgroundColor
            setTitleColor(textColor, for: .normal)
            titleLabel?.font = AppTheme.Font.regular(14)
            if borderWidth > 0.0 {
                applyBorder(color: textColor, width: borderWidth)
            }
            
        case let .custom(text, textColor, backgroundColor, cornerRadius, fontWeight):
            setTitle(text, for: .normal)
            setTitleColor(textColor, for: .normal)
            titleLabel?.font = fontWeight == .bold ? AppTheme.Font.bold(14) : AppTheme.Font.regular(14)
            self.backgroundColor = backgroundColor
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            titleLabel?.lineBreakMode = .byWordWrapping
            roundCorner(cornerRadius)
        }
    }
    
    func getIndexPath(_ tableView: UITableView) -> IndexPath? {
        let buttonPosition = self.convert(CGPoint(), to: tableView)
        return tableView.indexPathForRow(at: buttonPosition)
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: state)
        }
    }
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }
}

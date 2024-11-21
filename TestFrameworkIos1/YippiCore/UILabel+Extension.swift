import Foundation
import UIKit

public enum LabelStyle {
    case bold(size: CGFloat, color: UIColor)
    case semibold(size: CGFloat, color: UIColor)
    case regular(size: CGFloat, color: UIColor)
    case heavy(size: CGFloat, color: UIColor)
}

public extension UILabel {
    
    func applyStyle(_ style: LabelStyle, setAdaptive: Bool = false) {
        switch style {
        case let .regular(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = AppTheme.Font.regular(Device.sizeRatioBasedOnIphone8 * size)
            } else {
                self.font = AppTheme.Font.regular(size)
            }
            
            break
        case let .semibold(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = AppTheme.Font.semibold(Device.sizeRatioBasedOnIphone8 * size)
            } else {
                self.font = AppTheme.Font.semibold(size)
            }
            break
            
        case let .bold(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = AppTheme.Font.bold(Device.sizeRatioBasedOnIphone8 * size)
            } else {
                self.font = AppTheme.Font.bold(size)
            }
            break

        case let .heavy(size, color):
            self.textColor = color
            if setAdaptive == true {
                self.font = AppTheme.Font.heavy(Device.sizeRatioBasedOnIphone8 * size)
            } else {
                self.font = AppTheme.Font.heavy(size)
            }
            break
        }
    }
}


enum LabelImagePosition {
    case front, back
}

extension UILabel {
    func setUnderlinedText(text: String) {
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        self.attributedText = attributedText
    }
    
    func setTextWithIcon(text: String, image: UIImage, imagePosition: LabelImagePosition, imageSize: CGSize, yOffset: CGFloat = 0.0) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: yOffset, width: imageSize.width, height: imageSize.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let textAfterIcon = NSAttributedString(string: text)
        switch imagePosition {
        case .front:
            completeText.append(attachmentString)
            completeText.append(NSMutableAttributedString(string: " "))
            completeText.append(textAfterIcon)
        case .back:
            completeText.append(textAfterIcon)
            completeText.append(NSMutableAttributedString(string: " "))
            completeText.append(attachmentString)
        }
        self.attributedText = completeText
    }
    
    func setTextWithIcon(text: NSAttributedString, image: UIImage, imagePosition: LabelImagePosition, imageSize: CGSize, yOffset: CGFloat = 0.0) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: yOffset, width: imageSize.width, height: imageSize.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let textAfterIcon = text
        switch imagePosition {
        case .front:
            completeText.append(attachmentString)
            completeText.append(NSMutableAttributedString(string: " "))
            completeText.append(textAfterIcon)
        case .back:
            completeText.append(textAfterIcon)
            completeText.append(NSMutableAttributedString(string: " "))
            completeText.append(attachmentString)
        }
        self.attributedText = completeText
    }
    
    func setTextWithIcon(text: NSMutableAttributedString, image: UIImage, imagePosition: LabelImagePosition, imageSize: CGSize, yOffset: CGFloat = 0.0) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: yOffset, width: imageSize.width, height: imageSize.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let textAfterIcon = text
        switch imagePosition {
        case .front:
            completeText.append(attachmentString)
            completeText.append(NSMutableAttributedString(string: " "))
            completeText.append(textAfterIcon)
        case .back:
            completeText.append(textAfterIcon)
            completeText.append(NSMutableAttributedString(string: " "))
            completeText.append(attachmentString)
        }
        self.attributedText = completeText
    }
    
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            let mutableString: String = myText
            
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
            print("this number \(safeTrimmedString.count) should never be less\n")
            print("then this number \(readMoreLength)")
            
            // "safeTrimmedString.count - readMoreLength" should never be less then the readMoreLength because it'll be a negative value and will crash
            let trimmedForReadMore: String = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "") + trailingText
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }
    
    var visibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        if let myText = self.text {
            
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: myText, attributes: attributes as? [NSAttributedString.Key : Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
}


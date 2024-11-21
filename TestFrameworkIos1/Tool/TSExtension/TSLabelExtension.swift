//
//  TSLabelExtension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit
//import NIMPrivate


extension UILabel {
    convenience init(text: String?, font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .left) {
        self.init(frame: CGRect.zero)
        self.textColor = textColor
        self.font = font
        self.text = text
        self.textAlignment = alignment
    }
    
    func shortenedText(with content: String, maxlines: Int, lastText: String = "sticker_see_all".localized) {
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.paragraphSpacing = 3
//        paragraphStyle.headIndent = 0.000_1
//        paragraphStyle.tailIndent = -0.000_1
//        let attribute = [NSAttributedString.Key.font: self.font, NSAttributedString.Key.paragraphStyle: paragraphStyle.copy(), NSAttributedString.Key.strokeColor: TSColor.main.theme]
//        
//        
//        func widthOfAttributeString(contentHeight: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
//            let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphstyle.copy()]
//            let att: NSString = NSString(string: attributeString.string)
//            let rectToFit1 = att.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
//            if attributeString.length == 0 {
//                return 0
//            }
//            return rectToFit1.size.width
//        }
//        
//        
//        self.attributedText = content
//            .attributonString()
//            .setTextFont(14)
//            .setlineSpacing(0)
//        
//        let arr: NSArray = NSArray(array: LabelLineText.getSeparatedLines(fromLabelAddAttribute: attributedText, frame: frame, attribute: attribute))
//        
//        let rangeArr: NSArray = NSArray(array: LabelLineText.getSeparatedLinesRange(fromLabelAddAttribute: attributedText, frame: frame, attribute: attribute))
//        
//        var sixLineText: NSString = ""
//        var sixRange: NSRange?
//        let sixReplaceRange: NSRange?
//        var replaceLocation: NSInteger = 0
//        let replaceText: String = lastText
//        
//        let replaceAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: replaceText)
//        let replacefirstAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: "...")
//        replaceAtttribute.addAttributes(attribute, range: NSRange(location: 0, length: replaceAtttribute.length))
//        
//        if arr.count > maxlines {
//            sixLineText = NSString(string: "\(arr[maxlines - 1] )")
//            let modelSix: rangeModel = rangeArr[maxlines - 1] as! rangeModel
//            for (index, _) in rangeArr.enumerated() {
//                if index > maxlines - 2 {
//                    break
//                }
//                let model: rangeModel = rangeArr[index] as! rangeModel
//                replaceLocation = replaceLocation + model.locations
//            }
//            
//            // 计算出最合适的 range 范围来放置 "阅读全文  " ，让 UI 看起来就是刚好拼接在第六行最后面
//            sixReplaceRange = NSRange(location: replaceLocation + modelSix.locations - replaceText.count, length: replaceText.count)
//            sixRange = NSRange(location: replaceLocation, length: modelSix.locations)
//            let mutableReplace: NSMutableAttributedString = NSMutableAttributedString(attributedString: (attributedText?.attributedSubstring(from: sixRange!))!)
//            
//            /// 这里要处理 第六行是换行的空白 或者 第六行未填满就换行 的情况
//            var lastRange: NSRange?
//            if modelSix.locations == 1 {
//                /// 换行直接追加
//                lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - 1)
//            } else {
//                /// 如果第六行最后一个字符是 \n 换行符的话，需要将换行符扔掉，再 追加 “查看更多”字样
//                let mutablepassLastString: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: modelSix.locations - 1, length: 1)))
//                var originI: Int = 0
//                if mutablepassLastString.string == "\n" {
//                    originI = 1
//                }
//                for i in originI..<modelSix.locations - 1 {
//                    /// 获取每一次替换后的属性文本
//                    let mutablepass: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: 0, length: modelSix.locations - i)))
//                    mutablepass.append(replaceAtttribute)
//                    let mutablePassWidth = widthOfAttributeString(contentHeight: 20, attributeString: mutablepass, font: UIFont.systemFont(ofSize: 15), paragraphstyle: paragraphStyle)
//                    /// 判断当前系统是不是 11.0 及以后的 是就不处理，11.0 以前要再细判断(有没有空格，有的情况下再判断宽度对比小的话要多留两个汉字距离来追加 阅读全文 字样)
//                    if #available(iOS 11.0, *) {
//                        if mutablePassWidth <= width * 2 / 3 {
//                            lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
//                            break
//                        }
//                    } else if mutablePassWidth <= width * 2 / 3 {
//                        let mutableAll: NSMutableAttributedString = NSMutableAttributedString(attributedString: (attributedText?.attributedSubstring(from: NSRange(location: 0, length: replaceLocation + modelSix.locations - i)))!)
//                        if mutableAll.string.contains(" "),
//                            mutablePassWidth <= (width * 2 / 3 - font.pointSize * 2.0) {
//                            lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
//                            break
//                        }
//                    } else {
//                        lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
//                        break
//                    }
//                }
//            }
//            if lastRange == nil {
//                lastRange = NSRange(location: 0, length: replaceLocation)
//            }
//            
//            let mutable: NSMutableAttributedString = NSMutableAttributedString(attributedString: (attributedText?.attributedSubstring(from: lastRange!))!)
//            mutable.append(replacefirstAtttribute)
//            mutable.append(replaceAtttribute)
//            attributedText = NSAttributedString(attributedString: mutable)
//        }
//        self.sizeToFit()
    }
}


extension UILabel {
    /**
        Call `<label>.layoutIfNeeded()` before this function, if your label is using auto layout.
    */
    func countLabelLines() -> Int {
        let myText = self.text.orEmpty as NSString
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: self.font]

        let labelRect = myText.boundingRect(with:CGSize(width:self.bounds.width,
                                                        height:CGFloat.greatestFiniteMagnitude),
                                            options:NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes:attributes,
                                            context:nil)
        return Int(ceil(CGFloat(labelRect.height) / self.font.lineHeight))
    }


    func isTruncated() -> Bool {
        guard (self.numberOfLines > 0) else {
            fatalError("Number of lines is set to 0 which means that the label will grow dynamically!")
        }

        return (self.countLabelLines() > self.numberOfLines)
    }
    
    func createGradientImage(w:CGFloat, h:CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size:CGSize(width:w, height:h))

        return renderer.image {
            rendererContext in

            let gradient = CGGradient(colorsSpace:nil, colors:[UIColor.clear.cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor] as CFArray, locations:[0, 0.45, 0.60, 1])!

            rendererContext.cgContext.drawLinearGradient(gradient, start:CGPoint(x:0, y:0), end:CGPoint(x:w, y:0), options:[])
        }
    }
    
}



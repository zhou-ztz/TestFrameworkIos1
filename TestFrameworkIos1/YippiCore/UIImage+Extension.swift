//
//  UIImage+Extension.swift
//  Yippi
//
//  Created by francis on 03/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import ImageIO

extension UIImageView {
    public func loadGif(name: String, speedMultiplier: Double = 0.0) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name, speedMultiplier: speedMultiplier)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}

extension UIImage {
    func rotatedImage(with angle: CGFloat) -> UIImage {
        let updatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: angle))
            .size
        
        return UIGraphicsImageRenderer(size: updatedSize)
            .image { _ in
                
                let context = UIGraphicsGetCurrentContext()
                
                context?.translateBy(x: updatedSize.width / 2.0, y: updatedSize.height / 2.0)
                context?.rotate(by: angle)
                
                draw(in: CGRect(x: -size.width / 2.0, y: -size.height / 2.0, width: size.width, height: size.height))
            }
            .withRenderingMode(renderingMode)
    }
    
    public convenience init?(contentsOfURL url:String) {
        guard let imgUrl = URL(string: url) else { return nil }
        do {
            let imgData = try Data(contentsOf: imgUrl)
            self.init(data: imgData)
        } catch {
            return nil
        }
    }
    
    public class func gif(data: Data, speedMultiplier: Double = 0.0) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source, speedMultiplier: speedMultiplier)
    }
    
    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        
        return gif(data: imageData)
    }
    
    public class func gif(name: String, speedMultiplier: Double = 0.0) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        
        return gif(data: imageData, speedMultiplier: speedMultiplier)
    }
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as? Double ?? 0
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource, speedMultiplier: Double = 0.0) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum:Double = 0
            
            for val: Int in delays {
                var newVal: Double = 0.0
                if speedMultiplier > 0 {
                    newVal = Double(val) - (Double(val)/speedMultiplier)
                } else {
                    newVal = Double(val)
                }
                sum += newVal
            }
            
            return Int(sum)
            
        }()
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
    
    func addWatermark () -> UIImage? {
        guard let watermarkImage = UIImage.set_image(named: "ic_rl_watermark") else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, _: false, _: 0.0)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        watermarkImage.draw(in: CGRect(x: 16 * Constants.bestPixelRatio,
                                       y: self.size.height - (Constants.watermarkSize + 16) * Constants.bestPixelRatio,
                                       width: Constants.watermarkSize * Constants.bestPixelRatio,
                                       height: Constants.watermarkSize * Constants.bestPixelRatio))
        let resultImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    class func image(_ text:String, size:(CGFloat,CGFloat), backColor:UIColor = UIColor.orange, textColor: UIColor = UIColor.white, isCircle: Bool = true) -> UIImage? {
        // 过滤空""
        if text.isEmpty { return nil }
        // 取第一个字符
        let letter = (text as NSString).substring(to: 1)
        let sise = CGSize(width: size.0, height: size.1)
        let rect = CGRect(origin: CGPoint.zero, size: sise)
        // 开启上下文
        UIGraphicsBeginImageContext(sise)
        // 拿到上下文
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        // 取较小的边
        let minSide = min(size.0, size.1)
        // 是否圆角裁剪
        if isCircle {
            UIBezierPath(roundedRect: rect, cornerRadius: minSide*0.5).addClip()
        }
        // 设置填充颜色
        ctx.setFillColor(backColor.cgColor)
        // 填充绘制
        ctx.fill(rect)
        let attr = [NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: minSide*0.5)]
        // 写入文字
        (letter as NSString).draw(at: CGPoint(x: minSide*0.25, y: minSide*0.25), withAttributes: attr)
        // 得到图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        return image
    }
    
    ///文字转图片
    static func imageFromText(_ bgColor:UIColor,str:String,imageWidth:CGFloat)->UIImage {
        let size = CGSize(width: imageWidth, height: imageWidth)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context:CGContext =  UIGraphicsGetCurrentContext()!//获取画笔上下文
        
        context.setAllowsAntialiasing(true) //抗锯齿设置
        
        bgColor.set()
        
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let fontWidth = imageWidth/2.5/2
        
        
        let y = (imageWidth - fontWidth*1.3)/2
        //画字符串
        let font = UIFont.systemFont(ofSize: fontWidth)
        
        let attrs = [NSAttributedString.Key.font:font,NSAttributedString.Key.foregroundColor:UIColor.white]
        
        let x = (imageWidth - str.size(withAttributes: attrs).width)/2
        str.draw(at: CGPoint(x: x, y: y), withAttributes:attrs)
        
        // 转成图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UIImageView {
    func setViewHidden(_ hidden: Bool) {
        if hidden == false {
            self.isHidden = hidden
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
            }) { finished in
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }) { finished in
                self.isHidden = hidden
            }
        }
    }
}


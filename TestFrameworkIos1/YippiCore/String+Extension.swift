import Foundation
import UIKit
import NaturalLanguage

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

public extension String {
    init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
    
    static var empty: String {
        return ""
    }
    
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    
    var containOnlyNumber: Bool { !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil }
    
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    
    func toDouble() -> Double {
        return Double(self) ?? 0
    }
    //获取emoji表情数组
    var emojis: [Character] {
        return filter{$0.isEmoji}
    }
    
    var firstLetter: String {
        let latinString = self.applyingTransform(StringTransform.toLatin, reverse: false) ?? "#"
        let noDiacriticString = latinString.applyingTransform(StringTransform.stripDiacritics, reverse: false) ?? "#"
        
        let firstLetter = noDiacriticString.prefix(1).uppercased()
        
        return String(firstLetter)
    }
    
    func toBdayDate(by format:String) -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = format
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatterGet.date(from: self) {
            return (date)
        } else {
            return (Date())
        }
    }
    
    func toDate(from fromFormat: String = "yyyy-MM-dd HH:mm:ss", to toFormat: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fromFormat
        df.timeZone = TimeZone(abbreviation: "UTC")
        if let date = df.date(from: self) {
            df.dateFormat = toFormat
            df.timeZone = TimeZone.current
            return df.string(from: date)
        } else {
            return ""
        }
    }
    
    func toUTCDate(from fromFormat: String = "yyyy-MM-dd HH:mm:ss", to toFormat: String) -> String {
        let df = DateFormatter()
        df.dateFormat = fromFormat
        df.timeZone = TimeZone.current
        if let date = df.date(from: self) {
            df.dateFormat = toFormat
            df.timeZone = TimeZone(abbreviation: "UTC")
            return df.string(from: date)
        } else {
            return ""
        }
    }
    
    func convertDateFromString(timeType: Int) -> String {
        let data = Date(timeIntervalSince1970: TimeInterval(self) ?? 0.0)
        let df = DateFormatter()
        if(timeType == 0) {
            df.dateFormat = "yyyy-MM-dd HH:mm"
        } else if(timeType == 1) {
            df.dateFormat = NSLocalizedString("dateformat4", comment: "")
        } else if(timeType == 2) {
            df.dateFormat = "yyyy-MM-dd"
        } else if(timeType == 3) {
            df.dateFormat = NSLocalizedString("dateformat5", comment: "")
        }
        let date = df.string(from: data)
        return date
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                
            }
        }
        return nil
    }
    
    
    var urlValue: URL? {
        return URL(string: self)
    }
    
    func lines(font : UIFont, width : CGFloat) -> Int {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return Int(boundingBox.height/font.lineHeight)
    }
    
    // By Kit Foong (Same as checkFileIsExist, just add paremeter for appended name for file checking)
    func checkFileIsExistSpecial(appendname: String) -> String? {
        var theFileName : String?
        let url = URL(fileURLWithPath: self)
        theFileName = url.deletingPathExtension().lastPathComponent + "_" + appendname.replacingOccurrences(of: " ", with: "") + "." + url.pathExtension
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsUrl!.appendingPathComponent(theFileName!.removingPercentEncoding!)
        if FileManager.default.fileExists(atPath: filePath.path) {
            return filePath.path
        } else {
            return nil
        }
    }
    
    func checkFileIsExist() -> String? {
        let theFileName = URL(fileURLWithPath: self).lastPathComponent
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsUrl!.appendingPathComponent(theFileName.removingPercentEncoding!)
        if FileManager.default.fileExists(atPath: filePath.path) {
            return filePath.path
        } else {
            return nil
        }
    }
    
    func getUrlStringFromString() -> String? {
        let tempStrArray = self.components(separatedBy: "\n")
        var urlString: String? = nil
        for i in 0 ..< tempStrArray.count {
            if tempStrArray[i].isURL() {
                urlString = getURLStringFromSubstring(text: tempStrArray[i])
            }
        }
        return  urlString
    }
    
    func getURLStringFromSubstring(text: String) -> String? {
        let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        var match = ""
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .init(rawValue: 0))
            let nsstr = text as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            regex.enumerateMatches(in: text, options: .init(rawValue: 0), range: all, using: { (result, flags, _) in
                match = nsstr.substring(with: result!.range)
            })
        } catch {
            return ""
        }
        return match
    }
    
    func isURL() -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
            for match in matches {
                guard let _ = Range(match.range, in: self) else { continue }
                return true
            }
        } catch let error {
            assert(false, error.localizedDescription)
            return false
        }
        return false
    }
    
    func removeNewLineChar() -> String? {
        return self.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\n\r", with: "\n").replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n", with: "                                                                                            ")
    }
    
    func findLanguage() -> String {
        if #available(iOS 12.0, *) {
            let languageRecog = NLLanguageRecognizer()
            languageRecog.processString(self)
            return (languageRecog.dominantLanguage?.rawValue) ?? "unknown"
        } else if #available(iOS 11.0, *) {
            let tagger = NSLinguisticTagger(tagSchemes:[.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
            tagger.string = self
            let language = tagger.dominantLanguage
            return language ?? "unknown"
        } else {
            let length = self.utf16.count
            let languageCode = CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRange(location: 0, length: length)) as String? ?? "unknown"
            return languageCode
        }
    }
    
    func detectLanguages() -> [String] {
        var detectedLanguages: [String:Int] = [:]
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = self
        
        tokenizer.enumerateTokens(in: self.startIndex..<self.endIndex) { tokenRange, _ in
            let token = self[tokenRange]
            let languageRecognizer = NLLanguageRecognizer()
            languageRecognizer.processString(String(token))
            print("\(String(token)) - \(languageRecognizer.languageHypotheses(withMaximum: 1))")
            if let confidence = languageRecognizer.languageHypotheses(withMaximum: 1).first?.value , confidence >= 0.85 ,  confidence <= 1.15 {
                if let dominantLanguage = languageRecognizer.dominantLanguage {
                    if let value = detectedLanguages[dominantLanguage.rawValue] {
                        detectedLanguages[dominantLanguage.rawValue] = value + 1
                    } else {
                        detectedLanguages[dominantLanguage.rawValue] = 1
                    }
                }
            }
            return true
        }
        //处理马来语和印尼语的混淆问题
        if let malayCount = detectedLanguages["ms"], detectedLanguages["id"] == nil {
            detectedLanguages["id"] = malayCount
        }
        if let indonesianCount = detectedLanguages["id"], detectedLanguages["ms"] == nil {
            detectedLanguages["ms"] = indonesianCount
        }
        print("detectedLanguages : \(detectedLanguages)")
        return detectedLanguages.keys.sorted()
        
    }

    
    
    static func format(strings: [String], boldFont: UIFont = UIFont(name: "PingFangTC-Regular", size: 11.0) ?? UIFont.boldSystemFont(ofSize: 14), boldColor: UIColor = UIColor(red: 0.93, green: 0.10, blue: 0.23, alpha: 1.00), inString string: String, font: UIFont = UIFont.systemFont(ofSize: 11), color: UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
    
    func replace(at index: Int, _ newChar: Character) -> String {
        var chars = Array(self)
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    
    func randomStringWithLength(length: Int) -> String {
        if length == 0 {
            return ""
        }
        var ret = ""
        while (ret.count < length) {
            let append = String(arc4random())
            ret = ret + append
        }
        var ret1: NSString = ret as NSString
        ret1 = ret1.substring(to: length) as NSString
        ret = String(ret1)
        return ret
    }
    
    func withHashtagPrefix() -> String {
        var newString = self
        if !newString.hasPrefix("#") {
            newString.insert("#", at: self.startIndex)
        }
        return newString
    }
    
    func isValidURL() -> Bool {
        var escapedString = self.removingPercentEncoding
        
        let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head + "+(.)+" + tail
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        return predicate.evaluate(with: escapedString)
    }
    
    func transformToPinYin() ->String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "").uppercased()
    }
    
    func isNotLetter()-> Bool {
        let upperCaseStr: String = self.uppercased()
        let c = Character(upperCaseStr)
        if  c >= "A", c <= "Z"{
            return false
        } else {
            return true
        }
    }
    
    func removingSpecialCharacters() -> String {
        return self.replacingOccurrences(of: "[^\\x00-\\x7F]", with: "", options: .regularExpression, range: nil)
    }
    
    
    func rangesOfString(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
              let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension String {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
            .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

//
//  LocalizationManager.swift
//  YippiCore
//
//  Created by Chew on 6/1/19.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

public enum LanguageIdentifier: String, CaseIterable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case korean = "ko"
    case filipino = "fil"
    case indonesian = "id"
    case japanese = "ja"
    case malay = "ms"
    case thai = "th"
    case vietnamese = "vi"
    
    var twoLetterCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "cn"
        case .chineseTraditional: return "cn"
        case .korean: return "ko"
        case .filipino: return "ph"
        case .indonesian: return "in"
        case .japanese: return "ja"
        case .malay: return "my"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
    
    public var txtLanguageCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "zh"
        case .chineseTraditional: return "zh"
        case .korean: return "kr"
        case .filipino: return "ph"
        case .indonesian: return "id"
        case .japanese: return "jp"
        case .malay: return "ms"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
    
    var txtTranslateTwoLetterCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "zh"
        case .chineseTraditional: return "zh-TW"
        case .korean: return "kr"
        case .filipino: return "ph"
        case .indonesian: return "id"
        case .japanese: return "jp"
        case .malay: return "ms"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
    
    var txtISOCode: String {
        switch self {
        case .english: return "en"
        case .chineseSimplified: return "zh-CN"
        case .chineseTraditional: return "zh-TW"
        case .korean: return "kr"
        case .filipino: return "ph"
        case .indonesian: return "id"
        case .japanese: return "jp"
        case .malay: return "ms"
        case .thai: return "th"
        case .vietnamese: return "vi"
        }
    }
}

@objcMembers
public class LocalizationManager: NSObject {
    private static let defaultLanguage = "en"
    
    private static var preferredLanguageCode: String {
        guard let preferredLanguage = Locale.preferredLanguages.first else {
            return defaultLanguage
        }
        return preferredLanguage
    }
    
    public class func availableLanugages() -> [String] {
        return [LanguageIdentifier.english.rawValue, LanguageIdentifier.chineseSimplified.rawValue, LanguageIdentifier.chineseTraditional.rawValue, LanguageIdentifier.korean.rawValue, LanguageIdentifier.indonesian.rawValue, LanguageIdentifier.malay.rawValue, LanguageIdentifier.japanese.rawValue, LanguageIdentifier.filipino.rawValue, LanguageIdentifier.thai.rawValue, LanguageIdentifier.vietnamese.rawValue]
    }
    
    public class func getDisplayNameForLanguageIdentifier(identifier: String) -> String {
        switch identifier {
        case LanguageIdentifier.chineseSimplified.rawValue:
            return "简体中文"
        case LanguageIdentifier.chineseTraditional.rawValue:
            return "繁体中文"
        case LanguageIdentifier.korean.rawValue:
            return "한국어f"
        case LanguageIdentifier.filipino.rawValue:
            return "Tagalog"
        case LanguageIdentifier.indonesian.rawValue:
            return "Bahasa Indonesian"
        case LanguageIdentifier.japanese.rawValue:
            return "日本語"
        case LanguageIdentifier.malay.rawValue:
            return "Bahasa Malaysia"
        case LanguageIdentifier.thai.rawValue:
            return "ไทย"
        case LanguageIdentifier.vietnamese.rawValue:
            return "Tiếng Việt"
        default:
            return "English"
        }
    }
    
    public class func getDefaultLanguage() -> String {
        var langCode = preferredLanguageCode
        let splitArray = langCode.components(separatedBy: "-")
        
        if splitArray.count > 1 {
            if let index = langCode.lastIndex(of: "-") {
                let substring = langCode[..<index]
                langCode = String(substring)
            }
        }
        
        setCurrentLanguage(identifier: langCode)
        return langCode
    }
    
    public class func getISOLanguageCode() -> String {
        let languageIdentifier = LanguageIdentifier(rawValue: getCurrentLanguage()) ?? .english
        return languageIdentifier.txtISOCode
    }
    
    public class func getShortLanguageCode() -> String {
        let languageIdentifier = LanguageIdentifier(rawValue: getCurrentLanguage()) ?? .english
        return languageIdentifier.twoLetterCode
    }
    
    public class func getTxtTranslateShortLanguageCode() -> String {
        let languageIdentifier = LanguageIdentifier(rawValue: getCurrentLanguage()) ?? .english
        return languageIdentifier.txtTranslateTwoLetterCode
    }
    
    public class func getCurrentLanguage() -> String {
        guard let currentLanguage = Defaults.currentLanguage else {
            return getDefaultLanguage()
        }
        
        return currentLanguage == "" ? getDefaultLanguage() : currentLanguage
    }
    
    public class func getCurrentLanguageCode() -> String {
        guard let currentLanguage = Defaults.currentLanguage else {
            return getDefaultLanguage()
        }
        let lang = currentLanguage.components(separatedBy: "-")
        if lang.count > 0 {
            return lang[0]
        }
        return currentLanguage == "" ? getDefaultLanguage() : currentLanguage
    }
    
    public class func getCurrentISOLanguageCode() -> String {
        guard let currentLanguage = Defaults.currentLanguage else {
            return getDefaultLanguage()
        }
        
        return currentLanguage == "" ? getDefaultLanguage() : currentLanguage
    }
    
    public class func setCurrentLanguage(identifier: String) {
        let selectedLanguage = availableLanugages().contains(identifier) ? identifier : defaultLanguage
        
        Defaults.currentLanguage = selectedLanguage
        
        if identifier == LanguageIdentifier.english.rawValue {
            UserDefaults.standard.set([LanguageIdentifier.english.rawValue, LanguageIdentifier.chineseSimplified.rawValue], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([selectedLanguage, LanguageIdentifier.english.rawValue], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
    
    public class func applyAppLanguage() {
        Bundle.setLanguage(getCurrentLanguage())
    }
    
    public class func isUsingChinese() -> Bool {
        return [LanguageIdentifier.chineseSimplified.rawValue, LanguageIdentifier.chineseTraditional.rawValue].contains(getCurrentLanguage())
    }
}

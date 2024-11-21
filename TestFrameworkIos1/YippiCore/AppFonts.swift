//
//  AppFonts.swift
//  YippiCore
//
//  Created by Jerry Ng on 20/07/2021.
//  Copyright © 2021 Chew. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
public class AppFonts : NSObject {
    
    public enum Body {
        case regular12, regular14, regular16
        
        public var font: UIFont {
            switch self {
            case .regular12:
                return UIFont.systemFont(ofSize: 12, weight: .regular)
            case .regular14:
                return UIFont.systemFont(ofSize: 14, weight: .regular)
            case .regular16:
                return UIFont.systemFont(ofSize: 16, weight: .regular)
            }
        }
    }
    
    public enum Headline {
        case medium10, bold12, medium14, medium16, medium18, bold18
        
        public var font: UIFont {
            switch self {
            case .medium10:
                return UIFont.systemFont(ofSize: 10, weight: .medium)
            case .bold12:
                return UIFont.systemFont(ofSize: 12, weight: .bold)
            case .medium14:
                return UIFont.systemFont(ofSize: 14, weight: .medium)
            case .medium16:
                return UIFont.systemFont(ofSize: 16, weight: .medium)
            case .medium18:
                return UIFont.systemFont(ofSize: 18, weight: .medium)
            case .bold18:
                return UIFont.systemFont(ofSize: 18, weight: .bold)
            }
        }
    }
    
    public enum Tag {
        case medium10, medium12, bold16, bold20
        
        public var font: UIFont {
            switch self {
            case .medium10:
                return UIFont.systemFont(ofSize: 10, weight: .medium)
            case .medium12:
                return UIFont.systemFont(ofSize: 12, weight: .medium)
            case .bold16:
                return UIFont.systemFont(ofSize: 16, weight: .bold)
            case .bold20:
                return UIFont.systemFont(ofSize: 20, weight: .bold)
            }
        }
    }
    
}

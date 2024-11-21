//
//  OccupiedView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/20.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

/// 占位图类型
enum PlaceholderViewType: Equatable {
    /// 网络请求失败
    case network
    
    case networkWithRetry
    /// 数据为空
    case empty
    
    /// 动态被删除或者过期
    case removed
    
    case needLocationAccess
    
    case emptyResult
    
    case custom(image: UIImage?, text: String?)
    
    case customWithButton(image: UIImage?, text: String, buttonText: String?)
    
    case emptyChat
    
    case serverError
    //系统维护
    case serverUnavailable
    
    case contentRemoved
    
    case websiteError
    
    case noComment
    
    case imEmpty
    
    case teenMode
    
    case noVoucher
    
    var content: (image: UIImage?, text: String?, content: String?) {
        switch self {
        case .network, .networkWithRetry:
            return (UIImage.set_image(named: "placeholder_no_internet"), "rw_error_title_no_internet".localized, "rw_error_message_no_internet".localized)
        case .empty:
            return (UIImage.set_image(named: "placeholder_no_result"), "rw_error_title_no_content_found".localized, "")
        case .removed:
            return (UIImage.set_image(named: "placeholder_no_result"), "rw_error_title_no_content_found".localized, "rw_content_removed_or_deleted_message".localized)
            
        case .needLocationAccess:
            return (UIImage.set_image(named: "placeholder_location"), "placeholder_locationaccess_error".localized, "")
        case .emptyResult:
            return (UIImage.set_image(named: "placeholder_no_result"), "rw_error_title_no_result_found".localized, "rw_error_message_no_result_found".localized)
        case .emptyChat:
            return (UIImage.set_image(named: "placeholder_no_message"), "rw_error_title_no_message".localized, "rw_error_message_no_message".localized)
        case .serverError:
            return (UIImage.set_image(named: "reward_link_404"), "rw_error_title_something_wrong".localized, "rw_error_message_something_wrong".localized)
        case .serverUnavailable:
            return (UIImage.set_image(named: "maintenance"), "rw_error_title_maintenance".localized, "rw_error_message_maintenance".localized)
        case .contentRemoved:
            return (UIImage.set_image(named: "placeholder_no_result"), "reward_link_empty_list".localized, "")
        case .websiteError:
            return (UIImage.set_image(named: "placeholder_no_internet"), "text_invalid_web_url".localized, "")
        case .teenMode:
            return (UIImage.set_image(named: "placeholder_no_result"), "teen_mode_placeholder_msg".localized, "")
        case .noVoucher:
            return (UIImage.set_image(named: "placeholder_no_result"), "rw_no_voucher_placeholder_msg".localized, "")
        case .custom(let image, let text):
            return (image, text, "")
        case let .customWithButton(image, text, _ ):
            return (image, text, "")
        case .noComment:
            return (UIImage(), "rw_no_comments_yet".localized, "rw_be_first_comment".localized)
        case .imEmpty:
            return (UIImage.set_image(named: "placeholder_chat_empty"), "rw_text_say_hi_to_new_friend".localized, "")
        }
    }
    
    var buttonText: String? {
        switch self {
        case .customWithButton(_, _, let buttonText):
            return buttonText
        case .needLocationAccess:
            return "placeholder_locationaccess_button".localized
        case .serverError:
            return "retry".localized
        case .networkWithRetry, .network:
            return "rw_refresh".localized
        case .teenMode:
            return "teen_mode_placeholder_turn_off_teen_mode".localized
        default:
            return nil
        }
    }
}

class NormalPlaceholderView {

    /// 返回一个带占位图片的 imageView
    ///
    /// - Parameter name: 占位图片的名称
    /// - Returns: 带占位图片的 imageView
    class func imageView(name: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage.set_image(named: name))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}



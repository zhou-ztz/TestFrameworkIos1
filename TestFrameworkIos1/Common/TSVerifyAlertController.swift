//
//  TSVerifyAlertController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//
//  去认证弹窗选择界面
//  因多处使用，故公共一个，便于统一管理
/**
 注：
 1. 关于认证状态的判断，还需要进一步完善和统一，具体可参考TSNewsHelper和TSNewsEditController前的认证状态判断。但那个位置和投稿混淆，需要独立出来；
 2. 关于该页面应更多的使用到
 
 **/

import Foundation

/// 认证弹窗界面
class TSVerifyAlertController: TSAlertController {

    init(title: String?, message: String?, cancelTitle: String = "cancel".localized) {
        super.init(title: title, message: message, style: .actionsheet, sheetCancelTitle: cancelTitle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

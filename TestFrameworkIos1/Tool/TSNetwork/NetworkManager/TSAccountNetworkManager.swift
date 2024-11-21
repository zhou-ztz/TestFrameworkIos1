//
//  TSAccountNetworkManager.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/27.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  账户相关网络请求管理

import UIKit
import RealmSwift

import ObjectMapper

class TSAccountNetworkManager: NSObject {

    // MARK: - 验证码

    /// 验证码类型
    enum CAPTCHAType: String {
        case register
        case change
        //case login
    }
    /// 验证码渠道
    enum CAPTCHAChannel: String {
        case phone
        case username
    }

    /// 发送验证码
    /// 发送验证码的网络请求
    ///
    /// - Parameters:
    ///   - channel: 接收验证码的渠道：Phone、Email
    ///   - type: 验证码类型，分为.register、.change
    ///   - account: 账号，接收验证码的账户
    ///   - complete: 完成回调
    func sendCaptcha(channel: CAPTCHAChannel, type: CAPTCHAType, account: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        var path = TSURLPathV2.path.rawValue
        switch type {
        default:
            path += TSURLPathV2.Account.sendCAPTCHA.rawValue
        }
        var params = [String: Any]()
        switch channel {
        case .phone:
            params.updateValue(account, forKey: "phone")
        case .username:
            params.updateValue(account, forKey: "username")
        }
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            if status {
                complete(message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, status)
            }
        })

    }

    // MARK: - 登录

    /// 重置信息
    fileprivate func reset() -> Void {
        // 重置相关信息
        TSAccountTokenModel.reset()
        TSCurrentUserInfoSave.reset()
        IMTokenModel.reset()
        TSCurrentUserInfo.share.accountToken = nil
        TSCurrentUserInfo.share.accountManagerInfo = nil
    }

    /// 登录请求
    ///
    /// - Parameters:
    ///  - loginField: 登录字段：name/email/phone
    ///  - code：验证码登录(已经注册的手机号)，与password互斥
    func login(loginField: String, password: String, code: String = "", complete: @escaping ((_ message: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.auth.rawValue
        var params = ["login": loginField, "password": password]
        /// 验证码登录
        if code.isEmpty == false {
            params = ["login": loginField, "verifiable_code": code]
        }
        let createDate = Date()
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            // 1.网络请求失败处理
            guard status else {
                self.reset()
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, false)
                return
            }
            // 2.服务器数据异常处理
            guard let dataDic = data as? [String : Any], let token = Mapper<TSAccountTokenModel>().map(JSONObject: dataDic) else {
                self.reset()
                message = "error_data_server_return".localized
                complete(message, false)
                return
            }
            // 3.正常数据解析
            // 保存token 和 用户信息
            token.createInterval = Int(createDate.timeIntervalSince1970)
            token.save()
            TSCurrentUserInfo.share.accountToken = token
            UserDefaults.standard.set(TSAppConfig.share.environment.identifier, forKey: AppEnvironment.AppEnvinronmentIdentifier)
            RequestNetworkData.share.configAuthorization(token.token)
            complete(nil, true)
        })
    }

    // MARK: - Token刷新
    /// 刷新服务器通行口令
    class func refreshAccountToken(token: String, complete: @escaping ((_ message: String?, _ status: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.auth.rawValue + "/\(token)"
        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            // 1.网络请求失败处理
            guard status else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, false)
                return
            }
            // 2.服务器数据异常处理
            guard let dicData = data as? [String : Any] else {
                message = "error_data_server_return".localized
                complete(message, false)
                return
            }
            // 3.正常数据解析
            let token = dicData["token"] as! String
            let ttl = dicData["ttl"] as! Int
            let refreshTTL = dicData["refresh_ttl"] as! Int
            // token重置
            let tokenModel = TSAccountTokenModel()
            tokenModel?.token = token
            tokenModel?.expireInterval = ttl
            tokenModel?.refreshTTL = refreshTTL
            tokenModel?.save()
            TSCurrentUserInfo.share.accountToken = tokenModel
            complete(message, true)
        })
    }

    // MARK: - 注册

    /// 注册
    ///
    /// - Parameters:
    ///   - name: 用户名
    ///   - account: 账号：邮箱、手机号
    ///   - password: 密码
    ///   - captcha: 验证码
    ///   - channel: 注册渠道 Email/Phone
    func register(name: String, account: String, password: String?, captcha: String, channel: CAPTCHAChannel, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue
        var params = [String: Any]()
        params.updateValue(name, forKey: "name")
        params.updateValue(captcha, forKey: "verifiable_code")
        if let passWord = password {
            params.updateValue(password, forKey: "password")
        }
        switch channel {
        case .username:
            params.updateValue(account, forKey: "username")
            params.updateValue("sms", forKey: "verifiable_type")
        case .phone:
            params.updateValue(account, forKey: "phone")
            params.updateValue("sms", forKey: "verifiable_type")
        }
        let createDate = Date()
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            // 1.网络请求失败处理
            guard status else {
                self.reset()
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(message, false)
                return
            }
            // 2.服务器数据异常处理
            guard let token = Mapper<TSAccountTokenModel>().map(JSONObject: data) else {
                self.reset()
                message = "error_data_server_return".localized
                complete(message, false)
                return
            }
            // 3.正常数据解析
            // 保存token 注：这里不同于登录，没有用户相关的信息
            token.createInterval = Int(createDate.timeIntervalSince1970)
            token.save()
            TSCurrentUserInfo.share.accountToken = token
            UserDefaults.standard.set(TSAppConfig.share.environment.identifier, forKey: AppEnvironment.AppEnvinronmentIdentifier)
            RequestNetworkData.share.configAuthorization(token.token)
            complete(nil, true)
        })
    }

    // MARK: - 密码

    /// 修改密码
    ///   - oldPwd: 旧密码
    ///   - newPwd: 新密码
    ///   - confirmPwd: 确认密码，传nil时内部使用newPwd代替
    ///   - complete: 请求完成的回调
    func updatePassword(oldPwd: String, newPwd: String, confirmPwd: String? = nil, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Account.updatePwd.rawValue
        var params = [String: Any]()
        params.updateValue(oldPwd, forKey: "old_password")
        params.updateValue(newPwd, forKey: "password")
        params.updateValue((nil == confirmPwd) ? newPwd : confirmPwd!, forKey: "password_confirmation")
        try! RequestNetworkData.share.textRequest(method: .put, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            } else {
                message = "edit_success".localized
            }
            complete(message, status)
        })
    }

    /// 找回密码
    ///
    /// - Parameters:
    ///   - account: 账号，手机号或邮箱
    ///   - password: (新)密码
    ///   - CAPTCHA: 验证码
    ///   - channel: 渠道: Phone、Email
    ///   - complete: 请求完成时的回调
    func retrievePassword(account: String, password: String, captcha: String, channel: CAPTCHAChannel, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.Account.retrievePwd.rawValue
        var params = [String: Any]()
        params.updateValue(captcha, forKey: "verifiable_code")
        params.updateValue(password, forKey: "password")
        switch channel {
        case .username:
            params.updateValue(account, forKey: "username")
            params.updateValue("sms", forKey: "verifiable_type")
        case .phone:
            params.updateValue(account, forKey: "phone")
            params.updateValue("sms", forKey: "verifiable_type")
        }
        try! RequestNetworkData.share.textRequest(method: .put, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            if let dict = data as? [String: Any] {
                let code = dict["code"] as? Int
                message = dict["message"] as? String
                if code == 14 {
                    complete(message, false)
                    return
                }
            }
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

}

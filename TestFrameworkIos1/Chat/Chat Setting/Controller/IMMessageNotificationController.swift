//
//  IMMessageNotificationController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/24.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK


class IMMessageNotificationController: TSViewController {
    var data = [[IMNoticationData]]()
    var isUpdate: Bool = false
    var disableRemoteNotification = false //手机是否关闭通知功能
//    var disturbView: DisturbTimeView?
//    var settingData: SettingNotificationsResponse?
    var enableVoiceOrVideoNotification: Bool = false
    var enableMessageNotification: Bool = false
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .grouped)
        tb.rowHeight = 44
        tb.register(IMMessageNotificationCell.self, forCellReuseIdentifier: IMMessageNotificationCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        //tb.sectionIndexBackgroundColor = .clear
        tb.backgroundColor = .white
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCloseButton(backImage: true, titleStr: "title_notifications".localized)
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    @objc func refreshData(){
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            let remoteNotification = notificationSettings.notificationCenterSetting == .enabled
            self.disableRemoteNotification = !remoteNotification
            DispatchQueue.main.async {
                self.getData()
                self.tableView.reloadData()
            }
        }
    }
    
    func getData() {
//        SettingNotificationsType.init(key: "subscriber", value: 1, start: nil, end: nil, requestMethod: .get).execute {[weak self] response in
//            guard let response = response else {
//                return
//            }
//            self?.settingData = response
//            DispatchQueue.main.async {
//                self?.buildData()
//                self?.tableView.reloadData()
//            }
//        } onError: { [weak self] (error) in
//            print("error = \(error.localizedDescription)")
//            self?.showError(message: error.localizedDescription)
//            DispatchQueue.main.async {
//                self?.buildData()
//                self?.tableView.reloadData()
//            }
//        }
    }
    
    func updateData(key: String, value: Int, start: String?, end: String?){
//        SettingNotificationsType.init(key: key, value: value, start: start, end: end, requestMethod: .patch).execute {[weak self] response in
//            guard let response = response else {
//                return
//            }
//            self?.settingData = response
//            DispatchQueue.main.async {
//                self?.buildData()
//                self?.tableView.reloadData()
//            }
//            
//        } onError: { [weak self] (error) in
//            print("error = \(error.localizedDescription)")
//            self?.showError(message: error.localizedDescription)
//            DispatchQueue.main.async {
//                self?.buildData()
//                self?.tableView.reloadData()
//            }
//        }
    }
    
//    func buildData() {
//        guard let setting = NIMSDK.shared().apnsManager.currentSetting() else { return }
//        let enableNoDisturbing = setting.noDisturbing
//        let keys = UserDefaults.standard.dictionaryRepresentation().keys
//        var isContain = false
//        for key in keys {
//            if key == Constants.VoiceOrVideoMuteNotificationKey {
//                isContain = true
//                continue
//            }
//        }
//        
//        if !isContain {
//            UserDefaults.standard.setValue(true, forKey: Constants.VoiceOrVideoMuteNotificationKey)
//        }
//        
//        //免打扰开启，则视频通知关闭
//        if enableNoDisturbing {
//            UserDefaults.standard.setValue(!enableNoDisturbing, forKey: Constants.VoiceOrVideoMuteNotificationKey)
//        } else {
//            if enableVoiceOrVideoNotification {
//                UserDefaults.standard.setValue(true, forKey: Constants.VoiceOrVideoMuteNotificationKey)
//            }
//        }
//        
//        let voiceCallNotification = UserDefaults.standard.bool(forKey: Constants.VoiceOrVideoMuteNotificationKey)
//        
//        //为了检测是不是没使用过这function，如果开始与结束时间等于0就自己set一个default时间
//        let startTime = setting.noDisturbingStartH  * 60 + setting.noDisturbingStartM
//        let endTime = setting.noDisturbingEndH  * 60 + setting.noDisturbingEndM
//        
//        if startTime == endTime {
//            setting.noDisturbingStartH = 22
//            setting.noDisturbingStartM = 0
//            setting.noDisturbingEndH = 8
//            setting.noDisturbingEndM = 0
//            self.updateAPNSSetting(setting: setting)
//        }
//        
//        let noDisturbingStart = String(format: "%02zd:%02zd", setting.noDisturbingStartH , setting.noDisturbingStartM )
//        let noDisturbingEnd = String(format: "%02zd:%02zd", setting.noDisturbingEndH , setting.noDisturbingEndM )
//        
//        self.data.removeAll()
//        var array = [IMNoticationData]()
//        var feedArray = [IMNoticationData]()
//        var liveArray = [IMNoticationData]()
//        var array1 = [IMNoticationData]()
//        if disableRemoteNotification {// 通知权限关闭
//            let model = IMNoticationData(headerTitle: "rw_notifications_alert_warning".localized, footerTitle: "notifications_no_disturb_tips".localized, contentTitle: "notifications_no_disturb".localized, extraInfo: enableNoDisturbing, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            //feed
//            let feedmodel1 = IMNoticationData(headerTitle: "settings_notifications_label_feed".localized, footerTitle: "", contentTitle: "settings_notifications_feed_likes_and_comments_feed".localized, extraInfo: voiceCallNotification, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            let feedmodel2 = IMNoticationData(headerTitle: "".localized, footerTitle: "".localized, contentTitle: "settings_notifications_feed_tipping".localized, extraInfo: (self.settingData?.tag == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            let feedmodel3 = IMNoticationData(headerTitle: "".localized, footerTitle: "".localized, contentTitle: "settings_notifications_feed_new_followers".localized, extraInfo: (self.settingData?.follow == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
////            let feedmodel4 = IMNoticationData(headerTitle: "".localized, footerTitle: "".localized, contentTitle: "settings_notifications_feed_new_subscribers".localized, extraInfo: (self.settingData?.subscriber == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            
//            //Live
//            let liveModel = IMNoticationData(headerTitle: "settings_notifications_label_live".localized, footerTitle: "", contentTitle: "settings_notifications_live_live_notifications".localized, extraInfo: (self.settingData?.live == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            
//            //msg
//            let msgModel = IMNoticationData(headerTitle: "message".localized, footerTitle: "notifications_no_disturb_tips".localized, contentTitle: "settings_notifications_message_ios".localized, extraInfo: voiceCallNotification, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
////            let msgModel = IMNoticationData(headerTitle: "Message".localized, footerTitle: "".localized, contentTitle: "settings_notifications_message_message_notifications".localized, extraInfo: true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//
//            array.append(model)
//            feedArray.append(feedmodel1)
//            //feedArray.append(feedmodel2)
//            feedArray.append(feedmodel3)
//            //feedArray.append(feedmodel4)
//            //liveArray.append(liveModel)
//            array1.append(msgModel)
//            //array1.append(msgModel1)
//            data.append(array)
//            data.append(feedArray)
//            //data.append(liveArray)
//            data.append(array1)
//        } else {
//            let model = IMNoticationData(headerTitle: "notifications_no_disturb_tips".localized, footerTitle: "notifications_no_disturb_tips".localized, contentTitle: "notifications_no_disturb".localized, extraInfo: enableNoDisturbing, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            
//            let model1 = IMNoticationData(headerTitle: "", footerTitle: "", contentTitle: "time_from".localized, extraInfo: false, userInteraction: !enableNoDisturbing, forbidSelect: true, centerFooter: true, detailTitle: noDisturbingStart)
//            
//            let model2 = IMNoticationData(headerTitle: "", footerTitle: "", contentTitle: "time_to".localized, extraInfo: false, userInteraction: !enableNoDisturbing, forbidSelect: true, centerFooter: true, detailTitle: noDisturbingEnd)
//            //feed
//            let feedmodel1 = IMNoticationData(headerTitle: "settings_notifications_label_feed".localized, footerTitle: "", contentTitle: "settings_notifications_feed_likes_and_comments_feed".localized, extraInfo: voiceCallNotification, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            let feedmodel2 = IMNoticationData(headerTitle: "".localized, footerTitle: "".localized, contentTitle: "settings_notifications_feed_tipping".localized, extraInfo: (self.settingData?.tag == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            let feedmodel3 = IMNoticationData(headerTitle: "".localized, footerTitle: "".localized, contentTitle: "settings_notifications_feed_new_followers".localized, extraInfo: (self.settingData?.follow == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
////            let feedmodel4 = IMNoticationData(headerTitle: "".localized, footerTitle: "".localized, contentTitle: "settings_notifications_feed_new_subscribers".localized, extraInfo: (self.settingData?.subscriber == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            
//            //Live
//            let liveModel = IMNoticationData(headerTitle: "settings_notifications_label_live".localized, footerTitle: "", contentTitle: "settings_notifications_live_live_notifications".localized, extraInfo: (self.settingData?.live == 0) ? false : true, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//            //msg
//            let msgModel = IMNoticationData(headerTitle: "message".localized, footerTitle: "notifications_no_disturb_tips".localized, contentTitle: "settings_notifications_message_ios".localized, extraInfo: voiceCallNotification, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
////            let msgModel1 = IMNoticationData(headerTitle: "message".localized, footerTitle: "".localized, contentTitle: "settings_notifications_message_message_notifications".localized, extraInfo: messageNotification, userInteraction: disableRemoteNotification, forbidSelect: true, centerFooter: true, detailTitle: "")
//
//            
//            array.append(model)
//            array.append(model1)
//            array.append(model2)
//            feedArray.append(feedmodel1)
//            //feedArray.append(feedmodel2)
//            feedArray.append(feedmodel3)
//            //feedArray.append(feedmodel4)
//            //liveArray.append(liveModel)
//            array1.append(msgModel)
//            //array1.append(msgModel1)
//            data.append(array)
//            data.append(feedArray)
//            //data.append(liveArray)
//            data.append(array1)
//        }
//    }
    
    //MARK: - Message Notification Action
    func onActionMessageNotificationSettingValueChange(sender: UISwitch) {
        let switcher = sender
        let setting =  NIMSDK.shared().apnsManager.currentSetting()
        guard let settings = setting else {
            return
        }
        //当前在正处于免打扰
        settings.noDisturbing = switcher.isOn
        self.updateAPNSSetting(setting: settings)
    }
    
    func onActionSetNoDisturbingStart(){
//        guard let setting = NIMSDK.shared().apnsManager.currentSetting() else { return }
//        let pickerView = NIMTimePickerView(frame: self.view.bounds)
//        pickerView.refresh(withHour: Int(setting.noDisturbingStartH), minute: Int(setting.noDisturbingStartM))
//        pickerView.show(in: self.view.window) { [weak self] (hour, minute) in
//            if self?.disturbView != nil {
//                self?.disturbView!.refreshStartTime(startHour: hour, startMinute: minute)
//            }
//        }
    }
    
    func onActionSetNoDisturbingEnd(){
//        guard let setting = NIMSDK.shared().apnsManager.currentSetting() else { return }
//        let pickerView = NIMTimePickerView(frame: self.view.bounds)
//        pickerView.refresh(withHour: Int(setting.noDisturbingEndH), minute: Int(setting.noDisturbingEndM))
//        pickerView.show(in: self.view.window) { [weak self] (hour, minute) in
//            if self?.disturbView != nil {
//                self?.disturbView!.refreshEndTime(endHour: hour, endMinute: minute)
//            }
//        }
    }
    
    func onActionVoiceAndVideoCallNotificationSettingValueChange(sender: UISwitch) {
        let switcher = sender
        UserDefaults.standard.setValue(switcher.isOn, forKey: Constants.VoiceOrVideoMuteNotificationKey)
        UserDefaults.standard.synchronize()
        //当前在正处于免打扰
        guard let setting = NIMSDK.shared().apnsManager.currentSetting() else { return }
        if (switcher.isOn && setting.noDisturbing) {
            let alert = TSAlertController(title: "settings_notification_do_not_disturb_dialog_title_Disable_do_not_disturb".localized, message: "settings_notification_do_not_disturb_dialog_subtitle_disable_do_not_disturb".localized, style: .alert, hideCloseButton: true, animateView: false, allowBackgroundDismiss: false)
            
            let dismissAction = TSAlertAction(title: "Close".localized, style: TSAlertActionStyle.cancel) { (_) in
                self.refreshData()
                UserDefaults.standard.setValue(false, forKey: Constants.VoiceOrVideoMuteNotificationKey)
                UserDefaults.standard.synchronize()
                alert.dismiss()
            }
            
            let deleteAction = TSAlertAction(title: "settings_notification_do_not_disturb_button_confirm_to_cancel".localized, style: TSAlertActionStyle.theme) { (_) in
                setting.noDisturbing = false
                self.updateAPNSSetting(setting: setting)
                alert.dismiss()
            }
            
            alert.addAction(deleteAction)
            alert.addAction(dismissAction)
            
            self.present(alert, animated: false, completion: nil)
        } else {
            setting.noDisturbing = true
            setting.noDisturbingStartH = 00
            setting.noDisturbingStartM = 00
            setting.noDisturbingEndH = 23
            setting.noDisturbingEndM = 59
            self.updateAPNSSetting(setting: setting)
        }
    }
    
    @objc func switchBtnAction(_ sender: UISwitch) {
        let section = sender.tag / 1000
        let row = sender.tag % 1000 - 1
        let array = self.data[section]
        let model = array[row]
        
        switch model.contentTitle {
        case "notifications_no_disturb".localized: // 免打扰
            guard let setting = NIMSDK.shared().apnsManager.currentSetting() else {
                return
            }
            if sender.isOn {
//                disturbView = DisturbTimeView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), title: "notifications_no_disturb".localized, startHour: Int(setting.noDisturbingStartH), startMinute: Int(setting.noDisturbingStartM), endHour: Int(setting.noDisturbingEndH), endMinute: Int(setting.noDisturbingEndM))
//                disturbView?.show(view: self.view.window!)
//                disturbView?.timeCall = { [weak self] start in
//                    if start {
//                        self?.onActionSetNoDisturbingStart()
//                    }else {
//                        self?.onActionSetNoDisturbingEnd()
//                    }
//                }
//                disturbView?.completeHandler = { [weak self] (startHour, startMinute, endHour, endMinute) in
//                    if (startHour == endHour && startMinute == endMinute) {
//                        self?.showSuccess(message: "timeend_timestart_different".localized)
//                        setting.noDisturbing = false
//                        self?.updateAPNSSetting(setting: setting)
//                    } else {
//                        setting.noDisturbing = true
//                        setting.noDisturbingStartH = UInt(startHour)
//                        setting.noDisturbingStartM = UInt(startMinute)
//                        setting.noDisturbingEndH = UInt(endHour)
//                        setting.noDisturbingEndM = UInt(endMinute)
//                        self?.updateAPNSSetting(setting: setting)
//                    }
//                }
//                
//                disturbView?.closeCall = { [weak self]  in
//                    self?.refreshData()
//                }
            } else {
                let alert = TSAlertController(title: "settings_notification_do_not_disturb_dialog_title_Disable_do_not_disturb".localized, message: "settings_notification_do_not_disturb_dialog_subtitle_disable_do_not_disturb".localized, style: .alert, hideCloseButton: true, animateView: false, allowBackgroundDismiss: false)
                
                let dismissAction = TSAlertAction(title: "Close".localized, style: TSAlertActionStyle.cancel) { (_) in
                    self.refreshData()
                    alert.dismiss()
                }
                
                let deleteAction = TSAlertAction(title: "settings_notification_do_not_disturb_button_confirm_to_cancel".localized, style: TSAlertActionStyle.theme) { (_) in
                    setting.noDisturbing = false
                    self.updateAPNSSetting(setting: setting)
                    self.enableVoiceOrVideoNotification = true
                    self.enableMessageNotification = true
                    alert.dismiss()
                }
                
                alert.addAction(deleteAction)
                alert.addAction(dismissAction)
                
                self.present(alert, animated: false, completion: nil)
            }
            break
        case "settings_notifications_feed_tipping".localized, "settings_notifications_feed_new_followers".localized, "settings_notifications_feed_new_subscribers".localized:
            let key = self.rowForKey(row: row)
            let value = sender.isOn ? 1 : 0
            updateData(key: key, value: value, start: nil, end: nil)
            break
        case "settings_notifications_live_live_notifications".localized:
            let value = sender.isOn ? 1 : 0
            updateData(key: "live", value: value, start: nil, end: nil)
            break
        case "settings_notifications_message_ios".localized:
            self.onActionVoiceAndVideoCallNotificationSettingValueChange(sender: sender)
            break
        default:
            break
        }
    }
    
    func rowForKey(row: Int) -> String {
        var key = "follow"
        switch row {
        case 1:
            key = "follow"
        case 2:
            key = "subscriber"
        default:
            break
        }
        return key
    }
    
    //MARK: - Private
    func updateAPNSSetting(setting: NIMPushNotificationSetting) {
        NIMSDK.shared().apnsManager.updateApnsSetting(setting) { [weak self] (error) in
            self?.isUpdate = true
            if let _ = error {
                self?.showError(message: "distrupt_setting_fail".localized)
                self?.refreshData()
            } else {
                let noDisturbingStart = String(format: "%02zd:%02zd:00", setting.noDisturbingStartH , setting.noDisturbingStartM )
                let noDisturbingEnd = String(format: "%02zd:%02zd:00", setting.noDisturbingEndH , setting.noDisturbingEndM )
                let value: Int = setting.noDisturbing ? 1: 0
                var startTime = noDisturbingStart.toUTCDate(from: "HH:mm:ss", to: "HH:mm:ss")
                var endTime = noDisturbingEnd.toUTCDate(from: "HH:mm:ss", to: "HH:mm:ss")
                
                if startTime.isEmpty {
                    startTime = "22:00:00"
                }
                
                if endTime.isEmpty {
                    endTime = "08:00:00"
                }
                
                self?.updateData(key: "silent", value: value, start: startTime, end: endTime)
            }
        }
    }
}

extension IMMessageNotificationController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.data[section]
        if array.count > 0 && section == 0 {
            let model = array[0]
            if model.extraInfo {
                return array.count
            } else {
                return 1
            }
        }
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IMMessageNotificationCell.cellIdentifier) as! IMMessageNotificationCell
        cell.selectionStyle = .none
        let array = self.data[indexPath.section]
        let model = array[indexPath.row]
        cell.titleL.text = model.contentTitle
        cell.switchBtn.isHidden = false
        if indexPath.section == 0 {
            cell.switchBtn.isHidden = (indexPath.row != 0)
        }
        if indexPath.section == 1 {
            cell.switchBtn.isHidden = indexPath.row == 0
        }
        cell.accessoryType = (indexPath.section == 1 && indexPath.row == 0) ? .disclosureIndicator : .none
        cell.contentL.isHidden = indexPath.row == 0
        cell.contentL.text = model.detailTitle
        cell.switchBtn.isOn = model.extraInfo
        cell.switchBtn.isUserInteractionEnabled = !model.userInteraction
        cell.switchBtn.tag = indexPath.section * 1000 + indexPath.row + 1
        cell.switchBtn.addTarget(self, action: #selector(switchBtnAction(_:)), for: .valueChanged)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let array = self.data[indexPath.section]
        let model = array[indexPath.row]
        if model.contentTitle == "settings_notifications_feed_likes_and_comments_feed".localized {
//            let vc = LikesCommentsFeedController()
//            vc.settingData = settingData
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 36))
        let line = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 1))
        line.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        line.isHidden = false
        let lable = UILabel(frame: CGRect(x: 15, y: 3, width: ScreenWidth - 20, height: 30))
        lable.font = UIFont.systemFont(ofSize: 12)
        lable.textColor = .lightGray
        lable.numberOfLines = 0
        let array = self.data[section]
        if array.count > 0 {
            let model = array[0]
            lable.text = model.headerTitle
            if  section == 0{
                if !model.userInteraction {
                    lable.text = ""
                    lable.textAlignment = .left
                    lable.height = 36
                }else{
                    lable.textAlignment = .center
                    lable.height = 100
                }
                line.isHidden = true
            }
        }
        headView.addSubview(lable)
        headView.addSubview(line)
        headView.backgroundColor = .white
        return headView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let array = self.data[section]
        if array.count > 0 {
            let model = array[0]
            if section == 0{
                if model.userInteraction {
                    return 100
                }
                return 0.01
            }
        }
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 36))
        let lable = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 20, height: 36))
        lable.font = UIFont.systemFont(ofSize: 12)
        lable.textColor = .lightGray
        lable.numberOfLines = 0
        let array = self.data[section]
        if array.count > 0 && section == 0 {
            let model = array[0]
            lable.text = model.footerTitle
            lable.textAlignment = .left
            lable.height = 36
        }
        footView.addSubview(lable)
        footView.backgroundColor = .white
        return footView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 36
        }
        return 0.01
    }
}

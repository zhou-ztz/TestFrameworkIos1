//
//  CreateGroupViewController.swift
//  Yippi
//
//  Created by Liew Chuen Wai on 12/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import MobileCoreServices
import TZImagePickerController
import NIMSDK

class CreateGroupViewController: TSTableViewController {

    private let identifier = "cell"
    private let headerIdentifier = "header"
    
    private let pagination = 50

    var member: [String] = []
    var userInfos: [UserInfoModel] = []
    let dispatchgroup = DispatchGroup()
    public var finishBlock: createGroupFinishBlock?
    let countLabel = UILabel()
    var containText: Bool = false
    let loader = TSIndicatorWindowTop(state: .loading, title: "loading".localized)

    init(member: [String], completion: createGroupFinishBlock?) {
        super.init(nibName: nil, bundle: nil)

        self.member = member
        self.finishBlock = completion
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "new_group".localized
        tableView.register(UINib(nibName: "CreateGroupTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        tableView.register(UINib(nibName: "CreateGroupTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: headerIdentifier)
        tableView.tableFooterView = UIView()
        tableView.mj_footer = nil
        tableView.mj_header = nil
        
        let currentUsername = CurrentUserSessionInfo?.username ?? ""
        self.member = member.filter{$0 !=  currentUsername}

        fetchUserInfo(username: member)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setRightButton(title: "btn_create".localized, img: nil)
        self.setRightButtonTextColor(color: TSColor.main.theme)
        self.setRightCustomViewWidth(Max: true)
        self.rightButton?.frame = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        self.rightButtonEnable(enable: containText)
    }
    
    func getAvatar(username: String) -> String {
        var avatarUrl = ""
        
        for info in userInfos {
            if info.username == username {
                avatarUrl = info.avatarUrl.orEmpty
                break
            }
        }
        return avatarUrl
    }

    func getName(username: String) -> String {
        var name = ""

        for info in userInfos {
            if info.username == username {
                name = info.name
                break
            }
        }
        return name
    }

    func fetchUserInfo(username: [String]) {
        if username.count > pagination {
            TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: member) { (models, msg, status) in
                if let models = models {
                    self.userInfos += models
                    let newArray = Array(username.suffix(from: 50))
                    self.fetchUserInfo(username: newArray)
                }
            }
        } else {
            TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: member) { (models, msg, status) in
                if let models = models {
                    self.userInfos += models
                    self.tableView.reloadData()
                }
            }
        }
    }
    

    override func rightButtonClicked() {
        let header = tableView.headerView(forSection: 0) as! CreateGroupTableHeaderView
        self.textFieldShouldReturn(header.groupName)

        loader.show()

        let option = NIMCreateTeamOption()
        option.name       = header.groupName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        option.type       = NIMTeamType.advanced
        option.joinMode   = NIMTeamJoinMode.noAuth
        option.postscript = "text_invite_to_group".localized
        option.beInviteMode = NIMTeamBeInviteMode.needAuth

        if let groupImage =  header.groupIcon.image{
//            let imageForAvatarUpload = groupImage.nim_imageForAvatarUpload()
            var fileName = URL(fileURLWithPath: UUID().uuidString.lowercased()).appendingPathExtension("jpg").absoluteString
            fileName = fileName.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
            var filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName).absoluteString
            let filePathTemp = filePath
            filePath = filePath.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
            var data: Data? = nil
//            if let imageForAvatarUpload = imageForAvatarUpload {
//                data = imageForAvatarUpload.jpegData(compressionQuality: 1.0)
//            }
            var success: Bool = (data != nil && data!.bytes.count > 0)
            do {
                try data?.write(to: URL(string: filePathTemp)!, options: .atomic)
            }
            catch {
                success = false
            }

            if success {
                NIMSDK.shared().resourceManager.upload(filePath, scene: NIMNOSSceneTypeAvatar, progress: nil, completion: { [weak self] (urlString, error) in
                    DispatchQueue.main.async {
                        guard let strongSelf = self else { return }
                        if(error == nil) {
                            option.avatarUrl = urlString
                            strongSelf.createTeam(option: option)
                        }
                        else {
                            self?.loader.dismiss()
                            strongSelf.showFail(text: "group_avatar_upload_fail".localized)
                        }
                    }
                })
            } else if let data = data, data.bytes.count == 0 {
                createTeam(option: option)
            } else {
                loader.dismiss()
                self.showFail(text: "error_create_team_failed".localized)
            }
        }
        else {
            createTeam(option: option)
        }
    }

    func createTeam(option: NIMCreateTeamOption) {
        NIMSDK.shared().teamManager.createTeam(option, users: member, completion: { error, teamId, failedUserIds in
            DispatchQueue.main.async {
                self.loader.dismiss()
                if let error = error {
                    let errorDetail = error as NSError
                    if(errorDetail.code == 806) {
                        self.showFail(text: "error_over_team_capacity".localized)
                    } else {
                        self.showFail(text: "error_create_team_failed".localized)
                    }
                } else {
                    
                    if(self.finishBlock != nil) {
                        if let teamId = teamId {
                            self.finishBlock?(teamId as NSString)
                            self.finishBlock = nil
                        }
                    }
                    self.navigationController?.popViewController(animated: false)
                }
            }
        })
    }

    func showFail(text: String) {
        let loadingAlert = TSIndicatorWindowTop(state: .faild, title: text)
        loadingAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }

    //MARK: Table delegate and Data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CreateGroupTableViewCell

        let url = getAvatar(username: member[indexPath.row])
        let name = getName(username: member[indexPath.row])
        cell.configure(name: name, username: member[indexPath.row] ,avatarUrl: url)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return member.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! CreateGroupTableHeaderView
        header.setBottomHeader(count: member.count)
        header.groupIconHandler = {
            self.groupIconDidTapped()
        }
        countLabel.textAlignment = NSTextAlignment.right
        countLabel.textColor = UIColor(hexString: "#9a9a9a")
        countLabel.text = String(Constants.maximumGroupNameLength)
        header.groupName.addSubview(countLabel)
        countLabel.snp_makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        header.groupName.delegate = self
        header.groupName.addTarget(self, action: #selector(textDidChange(textField:)), for: UIControl.Event.editingChanged)

        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }

    func groupIconDidTapped() {
        TSUtil.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
            DispatchQueue.main.async {
                self.openCamera()
            }
        })
    }

}

extension CreateGroupViewController {
    private func openCamera() {
        
        self.showCameraVC(allowEdit: true) { [weak self] (assets, editedImage, _, _, _) in
            
            guard let asset = assets.first else { return }
            
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            PHCachingImageManager.default().requestImageData(for: asset, options: option) { [weak self] (data, type, orientation, info) in
                guard let data = data, let editedImage = editedImage, let type = type, let self = self else { return }
                
                DispatchQueue.main.async {
                    if type == String(kUTTypeGIF) {
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        PHImageManager.default().requestImageData(for: asset, options: option) { [weak self](imageData, type, orientation, info) in
                            guard let data = imageData else { return }
                            guard let self = self else { return }
                            switch type {
                                case String(kUTTypeGIF):
                                    let compressedData = ImageCompress.compressImageData(data, limitDataSize: 500 * 1024) ?? Data()
                               
                                let header = self.tableView.headerView(forSection: 0) as! CreateGroupTableHeaderView
                                header.groupIcon.image = editedImage
                                default:
                                    break
                            }
                        }
                    }else{
                        let lzImage = LZImageCropping()
                        lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
                        lzImage.image = UIImage(data: data)?.fixOrientation()
                        lzImage.isRound = true
                        lzImage.titleLabel.text = "change_head_icon".localized
                        lzImage.mainColor = AppTheme.red
                        lzImage.didFinishPickingImage = { [weak self] (image) -> Void in
                            guard let self = self, let image = image else {
                                return
                            }
                            let header = self.tableView.headerView(forSection: 0) as! CreateGroupTableHeaderView
                            header.groupIcon.image = image
                        }
                        self.navigationController?.present(lzImage, animated: true, completion: nil)
                    }
                   
                    
                }
                
            }
        }
        
    }
}

extension CreateGroupViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(tap:)))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(tap: UIGestureRecognizer?) {
        view.endEditing(true)
        if let tap = tap {
            self.view.removeGestureRecognizer(tap)
        }
    }

    @objc func textDidChange(textField: UITextField) {
        containText = !textField.text!.isEmpty
        self.rightButtonEnable(enable: !textField.text!.isEmpty)

        //获取高亮部分
        let selectedRange = textField.markedTextRange
        var pos: UITextPosition? = nil
        if let start = selectedRange?.start {
            pos = textField.position(from: start, offset: 0)
        }

        //如果在变化中是高亮部分在变，就不要计算字符了
        if selectedRange != nil && pos != nil {
            return
        }

        let textContent = textField.text
        let textNum = textContent?.count ?? 0

        if(textNum > Constants.maximumGroupNameLength) {
            //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
            let s = textContent?.subString(with: NSRange(location: 0, length: 25))

            textField.text = s
        }

        //不让显示负数
        countLabel.text = String(max(0, Constants.maximumGroupNameLength - textNum))
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //获取高亮部分
        let selectedRange = textField.markedTextRange
        //获取高亮部分内容
        var pos: UITextPosition? = nil
        if let start = selectedRange?.start {
            pos = textField.position(from: start, offset: 0)
        }

        //如果有高亮且当前字数开始位置小于最大限制时允许输入
        if selectedRange != nil && pos != nil {
            var startOffset: Int? = nil
            if let start = selectedRange?.start {
                startOffset = textField.offset(from: textField.beginningOfDocument, to: start)
            }
            var endOffset: Int? = nil
            if let end = selectedRange?.end {
                endOffset = textField.offset(from: textField.beginningOfDocument, to: end)
            }

            let offsetRange = NSRange(location: startOffset ?? 0, length: (endOffset ?? 0) - (startOffset ?? 0))

            if offsetRange.location < Constants.maximumGroupNameLength {
                return true
            } else {
                return false
            }
        }

        let comcatstr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        let caninputlen = Constants.maximumGroupNameLength - (comcatstr?.count ?? 0)

        if caninputlen >= 0 {
            return true
        } else {
            let len = string.count + caninputlen
            //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
            let rg = NSRange(location: 0, length: max(len,0))

            checkMarkedTextNumber(rg: rg, string: string, textField: textField, range: range)
            return false
        }
    }

    //Use to check whether the current input string for language other than English is exceed the limit and show only the string within limit of 25
    func checkMarkedTextNumber(rg: NSRange, string: String, textField: UITextField, range: NSRange) {
        var finalTrimString = ""
        if rg.length > 0 {

            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            let asc = string.canBeConverted(to: String.Encoding.ascii)
            if asc {
                finalTrimString = (string as NSString).substring(with: rg) //因为是ascii码直接取就可以了不会错
            } else {
                var idx = 0
                var trimstring = ""//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                (string as NSString).enumerateSubstrings(in: NSRange(location: 0, length: string.count), options: .byComposedCharacterSequences, using: { substring, substringRange, enclosingRange, stop in
                    if idx >= rg.length {
                        stop[0] = true //取出所需要就break，提高效率
                        return
                    }

                    trimstring = trimstring + (substring ?? "")

                    idx += 1
                })

                finalTrimString = trimstring
            }

            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: finalTrimString)
        }
    }
}

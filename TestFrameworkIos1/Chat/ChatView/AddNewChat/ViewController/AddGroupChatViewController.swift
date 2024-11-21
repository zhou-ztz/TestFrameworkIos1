//
//  AddGroupChatViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/12.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import TZImagePickerController
import MobileCoreServices
import NIMSDK

class AddGroupChatViewController: UIViewController {
    
    ///搜索 取消按钮样式
    var cancelType: SearchCancleType = .editingShow
    //人数
    var num: Int = 0
    var leftStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillProportionally
        $0.alignment = .center
    }
    lazy var groupNum: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#86909C")
        lab.font = UIFont.systemRegularFont(ofSize: 12)
        lab.textAlignment = .left
        lab.text = "0/200"
        return lab
    }()
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("next".localized, for: .normal)
        btn.setTitleColor(AppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemRegularFont(ofSize: 17)
        btn.isEnabled = false
        return btn
    }()
    
    lazy var createBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("btn_create".localized, for: .normal)
        btn.setTitleColor(AppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemRegularFont(ofSize: 17)
        btn.isEnabled = false
        return btn
    }()
    
    let bgView = UIView()
    var contactsVC: NewContactsListViewController?
    var settingVC: AddGroupSettingViewController?
    let loader = TSIndicatorWindowTop(state: .loading, title: "loading".localized)
    //是否设置
    var isSetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupUI(){
        self.view.addSubview(bgView)
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 20
        bgView.snp_makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(TSNavigationBarHeight)
        }
        
        let titleView = self.setTitleView()
        bgView.addSubview(titleView)
        titleView.snp_makeConstraints { make in
            make.height.equalTo(84)
            make.left.right.top.equalToSuperview()
        }
        
        contactsVC = NewContactsListViewController(cancelType: self.cancelType)
        contactsVC?.view.backgroundColor = .white
        bgView.addSubview(contactsVC!.view)
        contactsVC!.view.snp_makeConstraints { make in
            make.top.equalTo(80)
            make.left.right.bottom.equalToSuperview()
        }

        self.contactsVC?.searchBar.delegate = self
        self.contactsVC?.searchBar.searchTextFiled.placeholder = "search_name_id".localized
        
        self.contactsVC?.didSelectData = { _ in
            self.numSelectedChange()
        }
    }
    
    func setTitleView() -> UIView{
        
        let titleView = UIView()
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: "#D9D9D9")
        titleView.addSubview(line)
        line.layer.cornerRadius = 2.5
        line.clipsToBounds = true
        line.snp_makeConstraints { make in
            make.height.equalTo(5)
            make.width.equalTo(52)
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
        }
        
        let image = UIImage.set_image(named: "iconsArrowCaretleftBlack")
        let backimage = UIImageView(image: image)
        let lab = UILabel()
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        lab.textAlignment = .left
        lab.text = "new_group".localized
        groupNum.sizeToFit()
        leftStackView.addArrangedSubview(backimage)
        leftStackView.addArrangedSubview(lab)
        leftStackView.addArrangedSubview(groupNum)
        backimage.snp_makeConstraints { make in
            make.height.width.equalTo(24)
        }
        leftStackView.addAction {
            if !self.isSetting {
                self.navigationController?.popViewController(animated: true)
               // self.removeFromParent()
               // self.view.removeFromSuperview()
            }else {
                self.isSetting = false
                self.nextBtn.isHidden = false
                self.createBtn.isHidden = true
                
                self.settingVC?.view.removeFromSuperview()
                self.settingVC = nil
                self.contactsVC?.view.isHidden = false
            }
        }
        titleView.addSubview(leftStackView)
        leftStackView.snp_makeConstraints { make in
            make.left.equalTo(12)
            make.height.equalTo(26)
            make.bottom.equalTo(-5)
        }
        
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextBtnAction), for: .touchUpInside)
        
        titleView.addSubview(nextBtn)
        nextBtn.snp_makeConstraints { make in
            make.right.equalTo(-12)
            make.height.equalTo(26)
            make.bottom.equalTo(-5)
        }
        
        createBtn.isEnabled = false
        createBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        createBtn.addTarget(self, action: #selector(createBtnAction), for: .touchUpInside)
        titleView.addSubview(createBtn)
        createBtn.snp_makeConstraints { make in
            make.right.equalTo(-12)
            make.height.equalTo(26)
            make.bottom.equalTo(-5)
        }
        createBtn.isHidden = true
        return titleView
    }

  
    @objc func nextBtnAction(){
        
        if num == 0 {
            return
        }
        isSetting = true
        settingVC = AddGroupSettingViewController()
        settingVC?.choosedDataSource = self.contactsVC!.choosedDataSource
        
        bgView.addSubview(settingVC!.view)
        settingVC!.view.snp_makeConstraints { make in
            make.top.equalTo(80)
            make.left.right.bottom.equalToSuperview()
        }
        self.contactsVC?.view.isHidden = true
        settingVC?.opneAction = {
            self.showSheet()
        }
        settingVC?.groupNames = { hasName in
            if hasName {
                self.createBtn.isEnabled = true
                self.createBtn.setTitleColor(AppTheme.red, for: .normal)
            }else {
                self.createBtn.isEnabled = false
                self.createBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
            }
            
        }
        nextBtn.isHidden = true
        createBtn.isHidden = false
       
    }
    
    @objc func createBtnAction(){
        settingVC?.nameT.resignFirstResponder()
        if (settingVC?.nameT.text?.count ?? 0) == 0 {
            return
        }
        createGroup()
    }
    
    func numSelectedChange() {
        num = self.contactsVC!.choosedDataSource.count
        nextBtn.isEnabled = num > 1 ? true : false
        if num > 1 {
            nextBtn.setTitleColor(AppTheme.red, for: .normal)
        }else{
            nextBtn.setTitleColor(UIColor(hex: "#D9D9D9"), for: .normal)
        }
        
        groupNum.text = "\(num)" + "/200"
    }
    
    //创建群组
    func createGroup(){
        
        loader.show()
        let option = NIMCreateTeamOption()
        option.name       = settingVC?.nameT.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        option.type       = NIMTeamType.advanced
        option.joinMode   = NIMTeamJoinMode.noAuth
        option.postscript = "text_invite_to_group".localized
        option.beInviteMode = NIMTeamBeInviteMode.needAuth

        if let groupImage =  settingVC?.headImageView.image{
//            let imageForAvatarUpload = groupImage.nim_imageForAvatarUpload()
//            var fileName = URL(fileURLWithPath: UUID().uuidString.lowercased()).appendingPathExtension("jpg").absoluteString
//            fileName = fileName.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
//            var filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName).absoluteString
//            let filePathTemp = filePath
//            filePath = filePath.replacingOccurrences(of: "file:///", with: "", options: NSString.CompareOptions.literal, range: nil)
//            var data: Data? = nil
//            if let imageForAvatarUpload = imageForAvatarUpload {
//                data = imageForAvatarUpload.jpegData(compressionQuality: 1.0)
//            }
//            var success: Bool = (data != nil && data!.bytes.count > 0)
//            do {
//                try data?.write(to: URL(string: filePathTemp)!, options: .atomic)
//            }
//            catch {
//                success = false
//            }
//
//            if success {
//                NIMSDK.shared().resourceManager.upload(filePath, scene: NIMNOSSceneTypeAvatar, progress: nil, completion: { [weak self] (urlString, error) in
//                    DispatchQueue.main.async {
//                        guard let strongSelf = self else { return }
//                        if(error == nil) {
//                            option.avatarUrl = urlString
//                            strongSelf.createTeam(option: option)
//                        }
//                        else {
//                            self?.loader.dismiss()
//                            strongSelf.showFail(text: "group_avatar_upload_fail".localized)
//                        }
//                    }
//                })
//            } else if let data = data, data.bytes.count == 0 {
//                createTeam(option: option)
//            } else {
//                loader.dismiss()
//                self.showFail(text: "error_create_team_failed".localized)
//            }
        }
        else {
            createTeam(option: option)
        }
        
    }
    
    func createTeam(option: NIMCreateTeamOption) {
        NIMSDK.shared().teamManager.createTeam(option, users: settingVC?.members ?? [], completion: { error, teamId, failedUserIds in
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
                    
                    if let teamId = teamId {
                        let session = NIMSession(teamId, type: .team)
                        let vc = IMChatViewController(session: session, unread: 0)
                        do {
                            let message = IMSessionMsgConverter.shared.msgWithTip(tip: String(format: "%@ %@", (option.name ?? "new_group".localized),"created".localized))

                            try NIMSDK.shared().chatManager.send(message!, to: session)

                        } catch {
                            assert(false, "Send group created message failed!")
                        }
                        guard let nav = self.navigationController else {return}
                        var navigationArray = nav.viewControllers
                        for item in navigationArray {
                            if item.isKind(of: AddChatViewController.self){
                                break
                            }else{
                                navigationArray.removeLast()
                            }
                        }
                        navigationArray.append(vc)
                        self.navigationController?.viewControllers = navigationArray
                    }
                }
            }
        })
    }

    func showFail(text: String) {
        let loadingAlert = TSIndicatorWindowTop(state: .faild, title: text)
        loadingAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showSheet(){
        
        var titles: [String] = ["camera".localized, "album".localized]
        if let image = settingVC?.headImageView.image {
            titles = ["camera".localized, "album".localized, "remove_photo".localized]
        }
        let actionsheetView = TSCustomCameraSheetView(titles: titles)
        if titles.count == 3 {
            actionsheetView.setColor(color: TSColor.main.warn, index: 2)
        }
        actionsheetView.delegate = self
        //actionsheetView.tag = 2
        actionsheetView.show()
    }
    
    
    func openAblum(){
        TSUtil.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
            DispatchQueue.main.async {
                let imagePicker: TZImagePickerController = TZImagePickerController(maxImagesCount: 1, delegate: self, mainColor: TSColor.main.theme)
                imagePicker.allowTakePicture = false
                imagePicker.allowPickingMultipleVideo = false
                imagePicker.autoDismiss = true
                imagePicker.naviBgColor = .white
                imagePicker.naviTitleColor = .black
                imagePicker.barItemTextColor = .black
                imagePicker.navigationBar.barStyle = .default
                imagePicker.statusBarStyle = .default
                imagePicker.allowPickingVideo = false
                imagePicker.pickerDelegate = self
                imagePicker.allowPickingGif = true
                imagePicker.photoSelImage =  UIImage.set_image(named: "ic_rl_checkbox_selected")
                imagePicker.previewSelectBtnSelImage = UIImage.set_image(named: "ic_rl_checkbox_selected")
                imagePicker.allowCrop = true
                imagePicker.allowPreview = false
                self.present(imagePicker.fullScreenRepresentation, animated: true, completion: nil)
            }
        })
        
    }
    
    func openCamera() {
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
                
        
        TSUtil.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
            DispatchQueue.main.async {
                let camera = CameraViewController()
                camera.allowPickingVideo = false
                camera.enableMultiplePhoto = false
                camera.allowEdit = true
                camera.onSelectPhoto = { [weak self] (assetss, image, videoPath, isGif, isSelOriImage) in
                    if let path = videoPath {
                        
                    } else {
                        for asset in assetss {
                            let manager = PHImageManager.default()
                            let option = PHImageRequestOptions()
                            option.isSynchronous = false
                            manager.requestImageData(for: asset, options: option) { (imageData, type, orientation, info) in
                                guard let imageData = imageData else {
                                    return
                                }
                                DispatchQueue.main.async {
                                    var image: UIImage!
                                    if type == kUTTypeGIF as String {
                                        image = UIImage.gif(data: imageData)

                                    } else {
                                        image = UIImage.init(data: imageData)

                                    }
                                    
                                    let lzImage = LZImageCropping()
                                    lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
                                    lzImage.image = image
                                    lzImage.isRound = true
                                    lzImage.titleLabel.text = "Move and Scale".localized
                                    lzImage.didFinishPickingImage = { [weak self] image in
                                        guard let self = self, let image = image else {
                                            return
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.settingVC?.headImageView.image = image
                                            self.settingVC?.cameraImageView.isHidden = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                        self?.navigationController?.present(lzImage.fullScreenRepresentation, animated: true, completion: nil)
                                    }

                                  
                                }
                            }
                        }
                    }
                }

                let nav = UINavigationController(rootViewController: camera)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                nav.didMove(toParent: self)
            }
            
           
        })
    }

}

extension AddGroupChatViewController: ContactsSearchViewDelegate{
    func searchDidClickReturn(text: String) {
        self.contactsVC?.searchBar.searchTextFiled.resignFirstResponder()
        self.contactsVC?.keyword = text
        self.contactsVC?.refresh()
    }
    
    func searchDidClickCancel() {
        
    }
    func searchTextDidChange(text: String) {
        if text.count == 0 {
            self.contactsVC?.keyword = ""
            self.contactsVC?.refresh()
        }
    }
    
}

extension AddGroupChatViewController: TSCustomCameraSheetViewDelegate {
    func didSelectedItem(view: TSCustomCameraSheetView, title: String, index: Int) {
        switch index {
        case 0:
            openCamera()
            break
        case 1:
            openAblum()
            break
        case 2:
            self.settingVC?.headImageView.image = nil
            self.settingVC?.cameraImageView.isHidden = false
            break
        default:
            break
        }
    }
}

extension AddGroupChatViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        let lzImage = LZImageCropping()
        lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
        lzImage.image = photos.first
        lzImage.isRound = true
        lzImage.titleLabel.text = "Move and Scale".localized
        lzImage.didFinishPickingImage = { [weak self] image in
            guard let self = self, let image = image else {
                return
            }
            
            DispatchQueue.main.async {
                self.settingVC?.headImageView.image = image
                self.settingVC?.cameraImageView.isHidden = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.navigationController?.present(lzImage.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
}

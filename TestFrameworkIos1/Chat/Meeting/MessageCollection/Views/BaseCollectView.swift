//
//  BaseCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK

protocol BaseCollectViewDelegate: class {
    func baseViewStickerTap(bundleId: String)
    func baseViewContactTap(memberId: String)
    func baseViewMoreEditTap(indexPath: IndexPath)
    func baseViewTextMsgTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?)
    func baseViewImageVideoTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?)
    func baseViewAudioMsgTap(indexPath: IndexPath, favoriteModel: FavoriteMsgModel?)
    func baseViewLocaltionoMsgTap(indexPath: IndexPath, favoriteModel: IMLocationCollectionAttachment?)
    func baseViewFileMsgTap(indexPath: IndexPath, favoriteModel: IMFileCollectionAttachment?)
    func baseViewLinkMsgTap(url: String?)
    func baseViewMiniProgromMsgTap(appId: String?, path: String?)
    func baseViewUnknownTap()
    func baseViewVoucherMsgTap(url: String?)
}

class BaseCollectView: UIView {
    var collectModel: FavoriteMsgModel
    var dictModel: SessionDictModel?
    var imageAttachment: IMImageCollectionAttachment?
    var videoAttachment: IMVideoCollectionAttachment?
    var audioAttachment: IMAudioCollectionAttachment?
    var fileAttachment: IMFileCollectionAttachment?
    var locationAttachment: IMLocationCollectionAttachment?
    var attchDict: [String: Any]?
    weak var delegate: BaseCollectViewDelegate?
    var contentView = UIView()
    var indexPath: IndexPath
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var timeLable: UILabel = {
        let timeL = UILabel()
        timeL.textColor = UIColor(red: 155, green: 155, blue: 155)
        timeL.font = UIFont.systemFont(ofSize: 12)
        timeL.textAlignment = .right
        timeL.text = "04-10".localized
        return timeL
    }()
    
    lazy var moreBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.set_image(named: "buttonsMoreDotGrey"), for: .normal)
        btn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var avatarView: AvatarView = {
        let view = AvatarView(type: .width26(showBorderLine: false))
        view.avatarPlaceholderType = .unknown
        return view
    }()
    
    lazy var nameLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 139, green: 139, blue: 139)
        name.font = UIFont.systemFont(ofSize: 12)
        name.textAlignment = .left
        name.text = "大西瓜大西瓜大西瓜大西瓜".localized
        return name
    }()
    
    lazy var groupView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 7
        return stackView
    }()
    
    lazy var groupImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "groupGreyRound")
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        return image
    }()
    
    lazy var groupNameLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 139, green: 139, blue: 139)
        name.font = UIFont.systemFont(ofSize: 12)
        name.textAlignment = .left
        name.text = "大西瓜大西瓜大西瓜大西瓜".localized
        return name
    }()
    
    init(collectModel: FavoriteMsgModel, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.collectModel = collectModel
        super.init(frame: .zero)
        self.setUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(contentStackView)
        self.addSubview(timeLable)
        //self.addSubview(moreBtn)
        
        timeLable.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(20)
        }
        
        //        moreBtn.snp.makeConstraints { (make) in
        //            make.bottom.equalTo(-14)
        //            make.right.equalTo(-11)
        //            make.height.width.equalTo(18)
        //        }
        
        //        groupView.addArrangedSubview(groupImage)
        //        groupView.addArrangedSubview(groupNameLable)
        //        groupImage.snp.makeConstraints { (make) in
        //            make.top.left.bottom.equalTo(0)
        //            make.height.width.equalTo(20)
        //        }
        //        groupNameLable.snp.makeConstraints { (make) in
        //            make.top.bottom.right.equalTo(0)
        //            make.height.equalTo(20)
        //        }
        
        infoStackView.addArrangedSubview(avatarView)
        infoStackView.addArrangedSubview(nameLable)
        contentStackView.addArrangedSubview(infoStackView)
        
        infoStackView.snp.makeConstraints { (make) in
            make.height.equalTo(26)
        }
        nameLable.snp.makeConstraints { (make) in
            make.height.equalTo(20)
        }
        printIfDebug("self.collectModel.data = \(self.collectModel.data)")
        guard let data = self.collectModel.data.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dataString = formatter.string(from: NSDate(timeIntervalSince1970: self.collectModel.createTime) as Date)
        
        timeLable.text = dataString
        
        if let model = dictModel {
            if model.sessionType == "Team" {
                let team = NIMSDK.shared().teamManager.team(byId: model.sessionId)
                if let team1 = team?.teamName {
                    groupNameLable.text = team1
                }
                //                groupImage.image = UIImage.set_image(named: "groupGreyRound")
                //groupImage.sd_setImage(with: URL(string: team?.avatarUrl ?? ""), completed: nil)
                //contentStackView.addArrangedSubview(groupView)
                //                groupView.snp.makeConstraints { (make) in
                //                    make.left.right.bottom.equalTo(0)
                //                    make.height.equalTo(20)
                //                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(baseCollectTap))
        self.addGestureRecognizer(tap)
        
        //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        //self.addGestureRecognizer(longPress)
    }
    
    //MARK: --- Attachment
    func textForJson(josnStr: String) -> SessionDictModel? {
        var dictModel: SessionDictModel?
        guard let data = josnStr.data(using: .utf8) else {
            return nil
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        return dictModel
    }
    
    func imageAttachmentForJson(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        
        do {
            if self.collectModel.type == .image {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                imageAttachment = attach
            } else {
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                videoAttachment = attach
            }
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
    }
    
    func audioAttachmentForJson(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        
        do {
            let attach = try JSONDecoder().decode(IMAudioCollectionAttachment.self, from: dataAttach)
            audioAttachment = attach
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
    }
    
    func fileAttachmentForJson(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        
        do {
            let attach = try JSONDecoder().decode(IMFileCollectionAttachment.self, from: dataAttach)
            fileAttachment = attach
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
    }
    
    func locationAttachmentForJson(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        
        do {
            let attach = try JSONDecoder().decode(IMLocationCollectionAttachment.self, from: dataAttach)
            locationAttachment = attach
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
    }
    
    func contactAttachmentForJson(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        
        do {
            let dict = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
            attchDict = dict
        } catch {
            printIfDebug("jsonerror = \(error.localizedDescription)")
        }
    }
    
    @objc func moreAction() {
        self.delegate?.baseViewMoreEditTap(indexPath: self.indexPath)
    }
    
    @objc func baseCollectTap() {
        let msgType = self.collectModel.type
        switch msgType {
        case .text:
            self.delegate?.baseViewTextMsgTap(indexPath: indexPath, favoriteModel: collectModel)
            break
        case .image:
            self.delegate?.baseViewImageVideoTap(indexPath: indexPath, favoriteModel: collectModel)
            break
        case .audio:
            self.delegate?.baseViewAudioMsgTap(indexPath: indexPath, favoriteModel: collectModel)
            break
        case .video:
            self.delegate?.baseViewImageVideoTap(indexPath: indexPath, favoriteModel: collectModel)
            break
        case .location:
            self.delegate?.baseViewLocaltionoMsgTap(indexPath: indexPath, favoriteModel: locationAttachment)
            break
        case .file:
            self.delegate?.baseViewFileMsgTap(indexPath: indexPath, favoriteModel: fileAttachment)
            break
        case .nameCard:
            if let dict = self.attchDict![CMData] as? [String: Any] {
                self.delegate?.baseViewContactTap(memberId: dict[CMContactCard] as? String ?? "")
            }
            break
        case .sticker:
            if let dict = self.attchDict![CMData] as? [String: Any] {
                self.delegate?.baseViewStickerTap(bundleId: dict[CMStickerBundleId] as? String ?? "")
            }
            break
        case .link:
            if let dict = self.attchDict![CMData] as? [String: Any] {
                self.delegate?.baseViewLinkMsgTap(url: dict[CMShareURL] as? String)
            }
            break
        case .miniProgram:
            if let dict = self.attchDict![CMData] as? [String: Any] {
                self.delegate?.baseViewMiniProgromMsgTap(appId: dict[CMAppId] as? String , path: dict[CMPath] as? String )
            }
            break
        case .voucher:
            if  let dict = self.attchDict![CMData] as? [String: Any] {
                self.delegate?.baseViewVoucherMsgTap(url: dict[CMShareURL] as? String)
            }
            break
        default:
            self.delegate?.baseViewUnknownTap()
            break
        }
    }
    
    @objc func longPressAction(_ press: UILongPressGestureRecognizer) {
        if press.state == UIGestureRecognizer.State.began {
            self.delegate?.baseViewMoreEditTap(indexPath: self.indexPath)
        }
    }
}

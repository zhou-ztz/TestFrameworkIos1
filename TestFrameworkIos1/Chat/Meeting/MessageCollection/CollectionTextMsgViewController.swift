//
//  CollectionTextMsgViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK


class CollectionTextMsgViewController: TSViewController {

    var favoriteModel: FavoriteMsgModel?
    var collectionMsgCall: deleteCollectionMsgCall?
    
    lazy var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
        return sc
    }()
    
    lazy var bgView: UIView = {
        let bg = UIView()
        bg.backgroundColor = .white
        return bg
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    init(model: FavoriteMsgModel) {
        self.favoriteModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton(backImage: true, titleStr: "title_favourite_msg_details".localized)
        self.setUI()
    }
    
    func setUI(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.set_image(named: "buttonsMoreDotBlack"), style: .plain, target: self, action: #selector(moreAction))
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.width.equalTo(ScreenWidth)
        }
        if let model = self.textForJson(josnStr: self.favoriteModel!.data) {
            contentLabel.text = model.content
        }
        
        bgView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(13)
            make.bottom.equalTo(-13)
            make.width.equalTo(ScreenWidth - 28)
        }
        
        self.view.layer.layoutIfNeeded()
        
        self.scrollView.contentSize = CGSize(width: 0, height: bgView.height + 26)
        
    }

    @objc func moreAction(){

        let items: [IMActionItem] = [.collect_copy, .collect_forward, .collect_delete]

//        if (items.count > 0 ) {
//            let view = IMActionListView(actions: items)
//            view.delegate = self
//            
//        }
    }
    
    //MARK:
    func textForJson(josnStr: String) -> SessionDictModel? {
        var dictModel: SessionDictModel?
        guard let data = josnStr.data(using: .utf8) else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        return dictModel
    }
    

}

extension CollectionTextMsgViewController {
    func copyTextIM() {
        let pasteboard = UIPasteboard.general
        if let model = self.textForJson(josnStr: self.favoriteModel!.data) {
            pasteboard.string = model.content
        }
        
    }
    func copyImageIM() {}
    
    func forwardTextIM() {
        
        let configuration = ContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: Constants.maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = NewContactPickerViewController(configuration: configuration, finishClosure: { [weak self] (contacts) in
            
            for contact in contacts {
                
                let session = NIMSession(contact.userName, type: contact.isTeam ? NIMSessionType.team : NIMSessionType.P2P)
                guard let message = CollectionMsgDataManager().messageModel(model: self?.favoriteModel) else {
                    return
                }
                
                do {
                    try NIMSDK.shared().chatManager.send(message, to: session)
                } catch {
                    print("error---= \(error.localizedDescription)")
                }
                

            }
        })
        self.navigationController?.pushViewController(picker, animated: true)
        
    }
    
    func revokeTextIM() {}
    
    func deleteTextIM() {
        var array = [NIMCollectInfo]()
        let collectInfo = NIMCollectInfo()
        collectInfo.createTime = self.favoriteModel!.createTime
        collectInfo.id = UInt(self.favoriteModel!.Id)
        array.append(collectInfo)
        NIMSDK.shared().chatExtendManager.removeCollect(array) { [weak self] (error, total) in
            if let error = error {
                self?.showError(message: error.localizedDescription)
            }else{
                self?.showError(message: "favourite_msg_delete_success".localized)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8 ) {
                    self?.navigationController?.popViewController(animated: true)
                    if let collectMsgCall = self?.collectionMsgCall{
                        collectMsgCall!(self?.favoriteModel)
                    }
                    
                }
            }
        }
    }
    
    func translateTextIM() {}
    
    func replyTextIM() {}
    
    func handleStickerIM() {}
    
    func cancelUploadIM() {}
    
    func stickerCollectionIM() {}
    
    func voiceToTextIM() {}
    
    func messageCollectionIM() {}
    
    func saveMsgCollectionIM(){}
    
    func forwardAllImageIM() {}
    
    func deleteAllImageIM() {}
}

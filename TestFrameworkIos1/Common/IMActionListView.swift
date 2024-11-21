//
//  IMActionView.swift
//  Yippi
//
//  Created by Khoo on 24/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
//import NIMPrivate

public class GroupIMActionItem {
    let sectionId: Int
    var items: [IMActionItem]
    
    init(sectionId: Int, items: [IMActionItem]) {
        self.sectionId = sectionId
        self.items = items
    }
}

public enum IMActionItem: Equatable {
    case reply
    case copy
    case copyImage
    case forward
    case translate
    case edit
    case delete
    case stickerCollection
    case voiceToText
    case cancelUpload
    case collection //新增收藏
    case save //新增保存
    case forwardAll
    case deleteAll
    case pinned //置顶
    case unPinned //取消置顶
    case collect_copy //
    case collect_delete
    case collect_forward
    // Favourite Message
    case fvCopy
    case fvSave
    case fvForward
    case fvDelete

    var title: String {
        switch self {
        case .stickerCollection:
            return "longclick_msg_collection".localized
        case .reply:
            return "longclick_msg_reply".localized
        case .copy, .collect_copy:
            return "longclick_msg_copy".localized
        case .copyImage:
            return "longclick_msg_copy".localized
        case .forward, .collect_forward:
            return "longclick_msg_forward".localized
        case .translate:
            return "longclick_msg_translate".localized
        case .edit:
            return "longclick_msg_revoke_and_edit".localized
        case .delete, .collect_delete:
            return "longclick_msg_delete".localized
        case .voiceToText:
            return "longclick_msg_voice_to_text".localized
        case .cancelUpload:
            return "longclick_msg_cancel_upload".localized
        case .collection:
            return "longclick_msg_favourite".localized
        case .save:
            return "save".localized
        case .forwardAll:
            return "longclick_msg_forward_all".localized
        case .deleteAll:
            return "longclick_msg_delete_all".localized

        case .pinned:
            return "detail_share_pin".localized
        case .unPinned:
            return "detail_share_unpin".localized
        case .fvCopy:
            return "longclick_msg_copy".localized
        case .fvSave:
            return "save".localized
        case .fvForward:
            return "longclick_msg_forward".localized
        case .fvDelete:
            return "longclick_msg_delete_all".localized

        }
    }
    
    var image: String {
        switch self {
        case .stickerCollection:
            return "ic_collect_sticker"
        case .reply:
            return "ic_reply"
        case .copy:
            return "ic_copy"
        case .copyImage:
            return "ic_copy"
        case .forward:
            return "ic_forward"
        case .translate:
            return "ic_translate"
        case .edit:
            return "ic_MdCreate"
        case .delete:
            return "ic_delete"
        case .voiceToText:
            return "ic_voice_to_text"
        case .cancelUpload:
            return "ic_unUpload"
        case .collection:
            return "ic_im_favourite"
        case .save:
            return "imOptionDownload"
        case .forwardAll:
            return "ic_forward"
        case .deleteAll:
            return "ic_delete"
        case .pinned:
            return "ic_pin_on"
        case .unPinned:
            return "ic_pin_on"
        case .collect_copy:
            return "ic_collect_copy"
        case .collect_delete:
            return "ic_collect_delete"
        case .collect_forward:
            return "ic_collect_forward"
        case .fvCopy:
            return "imOptionCopy"
        case .fvSave:
            return "imOptionDownload"
        case .fvForward:
            return "detail_share_forwarding"
        case .fvDelete:
            return "delete"

        }
    }
}

@objc class IMActionListView: UIView {

//    weak var delegate: ActionListDelegate?
    /// 点击取消的回调
    var dismissAction: (() -> Void)?
    /// 按钮间距
    let buttonSpace: CGFloat = 45.0
    /// 按钮尺寸
    let buttonSize: CGSize = CGSize(width: 33.0, height: 60)
    /// 按钮 tag
    let tagForShareButton = 200
    /// 按钮背景滚动视图
    var scrollow = UIScrollView()
    /// 分享按钮组
    var shareViewArray = [UIView]()
    /// 分享链接
    var shareUrlString: String? = nil
    /// 分享图片
    var shareImage: UIImage? = nil
    /// 分享描述
    var shareDescription: String? = nil
    /// 分享标题
    var shareTitle: String? = nil
    /// 是自己的还是他人的
    var isMine = false
    // 是否是管理员
    var isManager = false
    // 是否是圈主
    var isOwner = false
    // 是否是精华
    var isExcellent = false
    // 是否是置顶
    var isTop = false
    // 是否置顶
    var isCollect = false
    var isCommentDisabled = false
    var cancleButton = UIButton(type: .custom)
    var oneLineheight: CGFloat = 117.0
    var twoLineheight: CGFloat = 333.0 / 2.0
         
    /// Powerful array ever
    var itemArray: [IMActionItem] = []
    
    init(actionArray: [Int]) {
        super.init(frame: UIScreen.main.bounds)
//        for action in actionArray {
//            switch action {
//            case Int(ActionEnum.IM_CANCEL_UPLOAD.rawValue):
//                itemArray.insert(.cancelUpload, at: 0)
//            case Int(ActionEnum.IM_COPY.rawValue):
//                itemArray.append(.copy)
//            case Int(ActionEnum.IM_COPY_IMAGE.rawValue):
//                itemArray.append(.copyImage)
//            case Int(ActionEnum.IM_DELETE.rawValue):
//                itemArray.append(.delete)
//            case Int(ActionEnum.IM_FORWARD.rawValue):
//                itemArray.append(.forward)
//            case Int(ActionEnum.IM_REVOKE_AND_EDIT.rawValue):
//                itemArray.append(.edit)
//            case Int(ActionEnum.IM_REPLY.rawValue):
//                itemArray.append(.reply)
//            case Int(ActionEnum.IM_TRANSLATE.rawValue):
//                itemArray.append(.translate)
//            case Int(ActionEnum.IM_STICKER_COLLECTION.rawValue):
//                itemArray.append(.stickerCollection)
//            case Int(ActionEnum.IM_VOICE_TO_TEXT.rawValue):
//                itemArray.append(.voiceToText)
//            case Int(ActionEnum.IM_FORWARD_ALL.rawValue):
//                itemArray.append(.stickerCollection)
//            case Int(ActionEnum.IM_REVOKE_ALL.rawValue):
//                itemArray.append(.voiceToText)
//            case Int(ActionEnum.IM_PIN.rawValue):
//                itemArray.append(.pinned)
//            case Int(ActionEnum.IM_UNPIN.rawValue):
//                itemArray.append(.pinned)
//            case Int(ActionEnum.IM_COLLECT_COPY.rawValue):
//                itemArray.append(.collect_copy)
//            case Int(ActionEnum.IM_COLLECT_DELETE.rawValue):
//                itemArray.append(.collect_delete)
//            case Int(ActionEnum.IM_COLLECT_FORWARD.rawValue):
//                itemArray.append(.collect_forward)
//            default:
//                break
//            }
//        }
        
        setUI()
        show()
    }
    
    init(actions: [IMActionItem]) {
        super.init(frame: UIScreen.main.bounds)
        itemArray = actions
        setUI()
        show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = UIScreen.main.bounds
    }

    // MARK: - Custom user interface
    func setUI() {
        
        backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        let topOffset = 40 + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight()
        
        //scroll view
        scrollow.backgroundColor = UIColor(hex: 0xf6f6f6)
        addSubview(scrollow)
        scrollow.translatesAutoresizingMaskIntoConstraints = false
        scrollow.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(115 + topOffset)
        })
        
        //stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fill
        scrollow.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints({ (make) in
            make.trailing.top.bottom.equalTo(scrollow)
            make.left.equalTo(scrollow).offset(15)
            make.height.equalTo(scrollow)
        })
        
        
        for index in 0..<itemArray.count {
            //shareview content
            let shareView = UIView()
            shareView.backgroundColor = UIColor(hex: 0xf6f6f6)
            shareView.tag = tagForShareButton + index
            shareView.isUserInteractionEnabled = true
            
            let imageView = UIImageView(image: UIImage.set_image(named: itemArray[index].image))
            imageView.isUserInteractionEnabled = true
            shareView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.top.equalTo(shareView.snp.top).offset(15)
                make.centerX.equalTo(shareView.snp.centerX)
                make.size.equalTo(CGSize(width: 50, height: 50))
            })
            
            let label = UILabel()
            label.text = itemArray[index].title
            label.textColor = TSColor.normal.content
            label.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
            label.textAlignment = .center
            label.numberOfLines = 0
            shareView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(12)
                make.width.equalTo(60)
                make.centerX.equalTo(imageView.snp.centerX)

            })
            
            stackView.addArrangedSubview(shareView)
            shareView.translatesAutoresizingMaskIntoConstraints = false
            shareView.snp.makeConstraints({ (make) in
                make.width.equalTo(70)
            })
            shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTaped(_:))))
        }

        // gesture
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        cancleButton.backgroundColor = UIColor.white
        cancleButton.setTitle("cancel".localized, for: .normal)
        cancleButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        cancleButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        addSubview(cancleButton)
        cancleButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalTo(-TSBottomSafeAreaHeight)
        }
        cancleButton.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        let view = UIView()
        view.backgroundColor = .white
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TSBottomSafeAreaHeight)
        }
    }

    // MARK: - Button click
    @objc internal func buttonTaped(_ sender: UIGestureRecognizer) {
        let view = sender.view
        let index = view!.tag - 200
        let finishBlock = setFinishBlock()
        let shareName = itemArray[index]
        
//        switch shareName {
//        case .stickerCollection:
//            delegate?.stickerCollectionIM()
//        case .cancelUpload:
//            delegate?.cancelUploadIM()
//        case .reply:
//            delegate?.replyTextIM()
//        case .copy, .collect_copy:
//            delegate?.copyTextIM()
//        case .copyImage:
//            delegate?.copyImageIM()
//        case .forward, .collect_forward:
//            delegate?.forwardTextIM()
//        case .edit:
//            delegate?.revokeTextIM()
//        case .delete, .collect_delete:
//            delegate?.deleteTextIM()
//        case .translate:
//            delegate?.translateTextIM()
//        case .voiceToText:
//            delegate?.voiceToTextIM()
//        case .collection:
//            delegate?.messageCollectionIM()
//        case .save:
//            delegate?.saveMsgCollectionIM()
//        case .forwardAll:
//            delegate?.forwardAllImageIM()
//        case .deleteAll:
//            delegate?.deleteAllImageIM()
//        case .pinned:
//            delegate?.pinMessageIM?()
//        case .unPinned:
//            delegate?.unPinMessageIM?()
//        default:
//            break
//        }
//            
        dismiss()
    }
    
    @objc func cancelBtnClick() {
        dismiss()
        dismissAction?()
    }

    func setFinishBlock() -> ((Bool) -> Void) {
        func finishBlock(success: Bool) -> Void {
            if success {
            }
        }
        return finishBlock
    }

    public func show() {

        if self.superview != nil {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
    }

   @objc public func dismiss() {
        if self.superview == nil {
            return
        }
        self.removeFromSuperview()
        dismissAction?()
    }
}

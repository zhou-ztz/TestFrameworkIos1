//
//  CustomPopListViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/11/1.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit


struct LivePinCommentModel: Equatable {
    static func == (lhs: LivePinCommentModel, rhs: LivePinCommentModel) -> Bool {
        return lhs == rhs
    }
    
    var target: Any
    var requiredPinMessage: Bool
    var model: FeedCommentListCellModel
    
    init(target: Any, requiredPinMessage: Bool = true, model: FeedCommentListCellModel) {
        self.target = target
        self.requiredPinMessage = requiredPinMessage
        self.model = model
    }
}

/// 弹出页面类型
public enum TSPopUpType: Int {
    case moreUser = 1
    case moreMe = 2
    case share = 3
    case selfComment = 4
    case normalComment = 5
}

enum TSPopUpItem: Equatable {
    case edit
    case save(isSaved: Bool)
    case message
    case reportPost
    case deletePost
    case pinTop(isPinned: Bool)
    case shareExternal
    case comment(isCommentDisabled: Bool)
    case reportComment(model: LivePinCommentModel)
    case deleteComment(model: LivePinCommentModel)
    case copy(model: LivePinCommentModel)
    case livePinComment(model: LivePinCommentModel)
    case liveUnPinComment(model: LivePinCommentModel)
    
    var title: String {
        switch self {
        case .edit:
            return "edit".localized
        case .save(let isSaved):
            return isSaved ? "save".localized : "unsave".localized
        case .message:
            return "rewardslink_send_to_messager".localized
        case .reportPost:
            return "report".localized
        case .deletePost:
            return "delete".localized
        case .pinTop(let isPinned):
            return isPinned ? "rw_detail_share_unpin".localized : "rw_detail_share_pin".localized
        case .shareExternal:
            return "rewardslink_send_to_other_media".localized
        case .comment(let isCommentDisabled):
            return isCommentDisabled ? "rw_enable_comment".localized : "rw_disable_comment".localized
        case .reportComment:
            return "report".localized
        case .deleteComment:
            return "delete".localized
        case .copy:
            return "longclick_msg_copy".localized
        case .livePinComment:
            return "feed_live_pin_comment".localized
        case .liveUnPinComment:
            return "feed_live_unpin_comment".localized
        }
    }
    
    var image: String {
        switch self {
        case .edit:
            return "ic_rl_tool_edit"
        case .save(let isSaved):
            return isSaved ? "ic_rl_tool_save" : "ic_rl_tool_save"
        case .message:
            return "ic_rl_tool_chat"
        case .reportPost:
            return "ic_rl_tool_report"
        case .deletePost:
            return "ic_rl_tool_delete_black"
        case .pinTop(let isPinned):
            return isPinned ? "ic_rl_tool_unpin" : "ic_rl_tool_pin"
        case .shareExternal:
            return "ic_rl_tool_share"
        case .comment(let isCommentDisabled):
            return isCommentDisabled ? "ic_rl_tool_comment_on" : "ic_rl_tool_comment_off"
        case .reportComment:
            return "ic_rl_tool_report"
        case .deleteComment:
            return "ic_rl_tool_delete_black"
        case .copy:
            return "ic_rl_tool_copy"
        case .livePinComment:
            return "ic_rl_tool_pin"
        case .liveUnPinComment:
            return "ic_rl_tool_unpin"
        }
    }
}

protocol CustomPopListProtocol: class {
    func customPopList(itemType: TSPopUpItem)
}

class CustomPopListViewController: UIViewController {
    
    weak var delegate: CustomPopListProtocol?
    
    private var popUpType: TSPopUpType = .share
    private var itemArray: [TSPopUpItem] = []
    
    private let topV = UIView().configure {
        $0.backgroundColor = .white
    }
    private let lineV = UIView().configure {
        $0.backgroundColor = UIColor(hex: 0xA5A5A5)
        $0.roundCorner(3)
    }
    private let bottomV = UIView().configure {
        $0.backgroundColor = .white
    }
    private let contentView = UIView().configure {
        $0.backgroundColor = .white
    }
    public var feedListModel: FeedListCellModel?
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    init(type: TSPopUpType, items: [TSPopUpItem]) {
        self.popUpType = type
        self.itemArray = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(contentView)
                
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        
        contentStackView.addArrangedSubview(topV)
        topV.addSubview(lineV)
        topV.snp.makeConstraints {
            $0.height.equalTo(35)
        }
        lineV.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(15)
            $0.size.equalTo(CGSizeMake(40, 5))
        }
        
        for (index, item) in (self.itemArray).enumerated() {
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.spacing = 5
            
            let iconStackView = UIStackView()
            iconStackView.axis = .vertical
            iconStackView.distribution = .fill
            iconStackView.alignment = .fill
            iconStackView.spacing = 5
            
            let iconImageView = UIImageView()
            if let img = UIImage.set_image(named: item.image) {
                iconImageView.image = img
            }
            
            let label = UILabel().configure {
                $0.text = item.title
                $0.font = UIFont.systemFont(ofSize: 16)
                $0.textColor = .black
            }
//            if item.title == "delete".localized {
//                label.textColor = AppTheme.red
//            }
            
            let iconPaddingView = UIView()
            
            stackView.addArrangedSubview(iconImageView)
            stackView.addArrangedSubview(iconPaddingView)
            stackView.addArrangedSubview(label)
            
            let paddingView = UIView()
            iconStackView.addArrangedSubview(stackView)
            iconStackView.addArrangedSubview(paddingView)
            contentStackView.addArrangedSubview(iconStackView)
            
            label.addAction {
                self.dismissView()
                self.delegate?.customPopList(itemType: item)
            }
            iconImageView.snp.makeConstraints {
                $0.size.equalTo(CGSizeMake(20, 20))
            }
            iconPaddingView.snp.makeConstraints {
                $0.width.equalTo(5)
            }
            stackView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(15)
            }
            paddingView.snp.makeConstraints {
                $0.height.equalTo(15)
            }
        }
        
        contentStackView.addArrangedSubview(bottomV)
        bottomV.snp.makeConstraints {
            $0.height.equalTo(TSBottomSafeAreaHeight)
        }
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, !self.contentView.frame.contains(touch.location(in: self.view)) {
            self.dismissView()
        }
    }
    
    private func dismissView() {
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .transitionCurlDown, animations: {
            self.contentView.transform = .init(translationX: 0, y: self.contentView.height)
        }) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    private var isLandscape: Bool {
        return Device.isLandscape && self.shouldAutorotate
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

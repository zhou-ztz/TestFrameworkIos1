//
//  FeedCommentDetailBottomView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/31.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

enum FeedCommentDetailBottomViewColorStyle {
    case normal
    case dark
}

class FeedCommentDetailBottomView: UIView {
   
    var onCommentAction: EmptyClosure?
    
    var colorStyle: FeedCommentDetailBottomViewColorStyle = .normal
    
    let toolbar = TSToolbarView(type: .left)
    
    private var lineView: UIView = {
        let lineV = UIView()
        lineV.backgroundColor = InconspicuousColor().disabled
        return lineV
    }()
    private var commentView: UIView = {
        let lineV = UIView()
        return lineV
    }()
    
    private var commentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = InconspicuousColor().disabled
        button.setTitle("rw_placeholder_comment".localized, for: .normal)
        button.setTitleColor(UIColor(hex: 0xB4B4B4), for: .normal)
        button.titleLabel?.font = UIFont.systemRegularFont(ofSize: 14)
        button.roundCorner(17.0)
        return button
    }()
    
    private var contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        
        return stack
    }()
    // callback
    var onToolbarItemTapped: ((Int) -> Void)?
    
    init(frame: CGRect, colorStyle: FeedCommentDetailBottomViewColorStyle = .normal) {
        self.colorStyle = colorStyle
        super.init(frame: frame)
        basicInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.colorStyle = .normal
        basicInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func basicInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.snp.makeConstraints { (m) in
            m.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.backgroundColor = colorStyle == .normal ? .white : .black
        
        addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.height.equalTo(2)
            $0.top.left.right.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)
            $0.bottom.right.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
        
        contentView.addArrangedSubview(commentView)
        commentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.5)
        }
        commentView.addSubview(commentButton)
        commentButton.addAction {
            self.onCommentAction?()
        }
        commentButton.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(10)
            $0.height.equalTo(35)
        }
      
        let toolbarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.48, height: 50)
        
        
        toolbar.set(items: [TSToolbarItemModel(image: colorStyle == .normal ? "IMG_home_ico_love" : "IMG_home_ico_love_white" , title: "", index: 0, titleShouldHide: false), TSToolbarItemModel(image: colorStyle == .normal ? "IMG_home_ico_comment_normal" : "IMG_home_ico_comment_normal_white", title: "", index: 1, titleShouldHide: false), TSToolbarItemModel(image: colorStyle == .normal ? "IMG_home_ico_forward_normal" : "IMG_home_ico_forward_normal_white", title: "", index: 2, titleShouldHide: false) ], frame: toolbarFrame)
       
        if self.colorStyle == .dark {
            commentButton.backgroundColor = UIColor(hex: 0x3A3A3A)
            commentButton.setTitleColor(UIColor(hex: 0xB4B4B4), for: .normal)
            toolbar.setTitleColor(.white, At: 0)
            toolbar.setTitleColor(.white, At: 1)
            toolbar.setTitleColor(.white, At: 2)
            lineView.isHidden = true
        }
      
        contentView.addArrangedSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.48)
        }
    }
    
    public func loadToolbar(model: FeedListToolModel?, canAcceptReward: Bool, reactionType: ReactionTypes?) {
        guard let model = model else { return }
        toolbar.backgroundColor = colorStyle == .normal ? .white : .black
        if let reaction = reactionType {
            toolbar.setImage(reaction.imageName, At: 0)
            toolbar.setTitle(reaction.title, At: 0)
        } else {
            toolbar.setImage(colorStyle == .normal ? "IMG_home_ico_love" : "IMG_home_ico_love_white" , At: 0)
            toolbar.setTitle("love_reaction".localized, At: 0)
        }
        
        // 设置点赞数量
        toolbar.setTitle(model.diggCount.abbreviated, At: 0)
        // 设置评论按钮
        toolbar.setTitle(model.commentCount.abbreviated, At: 1)
        // 设置转发按钮
        toolbar.setTitle(model.forwardCount.abbreviated, At: 2)
        
        if model.isCommentDisabled == true {
            toolbar.item(isHidden: true, at: 1)
            commentView.isHidden = true
        } else {
            toolbar.item(isHidden: false, at: 1)
            commentView.isHidden = false
        }
        toolbar.delegate = self
    }
}
extension FeedCommentDetailBottomView: TSToolbarViewDelegate {
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        self.onToolbarItemTapped?(index)
    }
}

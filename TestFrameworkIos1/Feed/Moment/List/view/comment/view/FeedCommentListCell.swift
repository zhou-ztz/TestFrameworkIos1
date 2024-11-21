//
//  FeedCommentListCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/11/2.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol FeedCommentListCellDelegate: class {
    /// 点击了评论中的名字
    func feedCommentListCell(_ cell: FeedCommentListCell, didSelectedUser userId: Int)
    /// 长按了评论
    func feedCommentListCellDidLongPress(_ cell: FeedCommentListCell)
    /// 点击了评论
    func feedCommentListCellDidPress(_ cell: FeedCommentListCell)
}

class FeedCommentListCell: UITableViewCell {

    static let identifier = "FeedCommentListCell"

    ///代理
    weak var delegate: FeedCommentListCellDelegate?

    /// 发送失败按钮
    let errorButton = UIButton(type: .custom)
    /// 评论 label
    let commentLabel = FeedCommentLabel()
    let userAvatar = AvatarView(type: .width20(showBorderLine: false))
    /// 数据源
    var model = FeedCommentListCellModel()

    // MARK: - 生命周期

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    internal func setUI() {
        commentLabel.feedCommentDelegate = self
        contentView.addSubview(errorButton)
        contentView.addSubview(commentLabel)
        contentView.addSubview(userAvatar)
    }

    func set(model: inout FeedCommentListCellModel) {
        self.model = model
        let leading = model.contentInset.left
        let tralling = model.contentInset.right
        let top = model.contentInset.top
        let bottom = model.contentInset.bottom
        
        // 0.人头像
        userAvatar.isHidden = model.userInfo == nil
        userAvatar.avatarPlaceholderType = AvatarView.PlaceholderType.unknown
        
        if let avatarInfo = model.userInfo {
            userAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: avatarInfo.sex)
            userAvatar.avatarInfo = avatarInfo.avatarInfo()
            userAvatar.frame = CGRect(origin: CGPoint(x: leading, y: top), size: userAvatar.size)
        }
        
        // 1.评论 label
        let labelWidth = UIScreen.main.bounds.width - leading - tralling - userAvatar.width - 8 - 16
        commentLabel.model = model
        commentLabel.isUserInteractionEnabled = true
        let labelSize = commentLabel.getSizeWithWidth(labelWidth)
        commentLabel.frame = CGRect(origin: CGPoint(x: leading + userAvatar.width + 8, y: top), size: labelSize)
        
        // 2.计算 cell 高度
        model.cellHeight = max(labelSize.height, 20) + top + bottom

        // 3.发送失败按钮
        errorButton.frame = .zero
    }
}

extension FeedCommentListCell: FeedCommentLabelDelegate {
    /// 增加了 label 上用户名的点击事件
    func feedCommentLabel(_ label: FeedCommentLabel, didSelectedUser userId: Int) {
        delegate?.feedCommentListCell(self, didSelectedUser: userId)
    }
    /// 长按了 cell
    func feedCommentLabelDidLongpress(_ label: FeedCommentLabel) {
        delegate?.feedCommentListCellDidLongPress(self)
    }
    /// 点击了label
    func feedCommentListCellDidPress(_ cell: FeedCommentLabel) {
        delegate?.feedCommentListCellDidPress(self)
    }
}

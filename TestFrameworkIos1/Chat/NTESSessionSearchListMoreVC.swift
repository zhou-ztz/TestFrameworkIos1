//
//  NTESSessionSearchListMoreVC.swift
//  Yippi
//
//  Created by Kit Foong on 17/10/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

@objc class NTESSessionSearchListMoreVC: TSViewController {
    
    var members: [UserAvatarUI] = []
    var keyword: String = ""
    
    lazy var tableView = TSTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .plain).configure {
        $0.tableFooterView = UIView()
        $0.backgroundColor = .white
        $0.rowHeight = 60
        $0.register(NTESSessionSearchListCell.self, forCellReuseIdentifier: NTESSessionSearchListCell.identifier)
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
    }
    
    var bottomEmptyView = UIView()
    var endListLabel = UILabel()
    
    func setupRightNavItem() {
        let doneItem = UIButton(type: .custom)
        doneItem.addTarget(self, action: #selector(rightNavButtonTapped), for: .touchUpInside)
        doneItem.setTitle("done".localized, for: .normal)
        doneItem.setTitleColor(AppTheme.dodgerBlue, for: .normal)
        doneItem.titleLabel?.font = .systemFont(ofSize: 14)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneItem)
    }
    
    @objc func rightNavButtonTapped(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func loadMore() {
        let offset = self.members.count
        TSUserNetworkingManager().user(identity: -1, fansOrFollowList: .friends, offset: offset, keyword: keyword) { [weak self] (userModels, networkError) in
            if networkError == nil {
                if let userModels = userModels {
                    if userModels.isEmpty {
                        self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self?.tableView.mj_footer.isHidden = true
                        self?.bottomEmptyView.makeVisible()
                        self?.bottomEmptyView.snp.makeConstraints { make in
                            make.height.equalTo(60)
                        }
                        return
                    }
                    if let weakSelf = self {
                        var newUserIdList = userModels.map { UserAvatarUI(username: $0.username, avatarUrl: $0.avatarUrl, displayname: $0.displayName, verificationIcon: $0.verificationIcon, verificationType: $0.verificationType) }
                        weakSelf.members = weakSelf.members + newUserIdList
                        DispatchQueue.main.async {
                            weakSelf.tableView.reloadData()
                            self?.tableView.mj_footer.endRefreshing()
                        }
                    }
                } else {
                    self?.tableView.mj_footer.endRefreshing()
                }
            } else {
                self?.tableView.mj_footer.endRefreshingWithWeakNetwork()
            }
        }
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        guard let text = endListLabel.attributedText?.string else {
            return
        }
        
        if let range = text.range(of: "text_back_to_search_result".localized),
           recognizer.didTapAttributedTextInLabel(label: endListLabel, inRange: NSRange(range, in: text)) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupUI() {
        self.view.addSubview(tableView)
        
        bottomEmptyView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
        bottomEmptyView.backgroundColor = UIColor(hex: 0xe1e1e1)
        
        self.view.addSubview(bottomEmptyView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalTo(bottomEmptyView.snp.top).offset(-10)
        }
        
        bottomEmptyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bottomEmptyView.makeHidden()
        
        endListLabel = UILabel()
        endListLabel.textColor = UIColor(red: 128, green: 128, blue: 128)
        endListLabel.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.verySmall)
        endListLabel.textAlignment = .center
        endListLabel.isUserInteractionEnabled = true
        endListLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
        
        let attrs1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: YPCustomizer.FontSize.small), NSAttributedString.Key.foregroundColor: UIColor(red: 128, green: 128, blue: 128)]
        let attrs2 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: YPCustomizer.FontSize.small), NSAttributedString.Key.foregroundColor: UIColor(red: 59, green: 179, blue: 255)]
        
        let attributedString1 = NSMutableAttributedString(string:"text_end_of_the_list".localized, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"text_back_to_search_result".localized, attributes:attrs2)
        let range = NSMakeRange(0, attributedString2.length)
        attributedString2.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value:  NSUnderlineStyle.single.rawValue), range: range)
        
        attributedString1.append(attributedString2)
        endListLabel.attributedText = attributedString1
        
        bottomEmptyView.addSubview(endListLabel)
        
        endListLabel.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(bottomEmptyView)
        }
        
        tableView.mj_header = nil
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.mj_footer.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.setTitleName("more_friends".localized)
        
        setupRightNavItem()
        setupUI()
    }
}

extension NTESSessionSearchListMoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NTESSessionSearchListCell.cellIdentifier) as! NTESSessionSearchListCell
        if cell == nil {
            cell = NTESSessionSearchListCell(style: .default, reuseIdentifier: NTESSessionSearchListCell.cellIdentifier)
        }
        cell.refreshUser(withUser: members[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let session = NIMSession(members[indexPath.row].username, type: .P2P)
        let vc = DependencyContainer.shared.resolveViewControllerFactory().makeIMChatViewController(sessionId: session.sessionId, type: 0, unread: 0, searchMessageId: "")
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class NTESSessionSearchListCell: UITableViewCell, BaseCellProtocol {
    
    static let identifier = "NTESSessionSearchListCell"
    
    lazy var headerAvatarView: AvatarView = {
        let view = AvatarView(type: .width48(showBorderLine: false))
        return view
    }()
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.black
        label.font = UIFont.systemFont(ofSize: FontSize.chatroomMsgFontSize)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        contentView.addSubview(headerAvatarView)
        contentView.addSubview(headerTitle)
        
        headerAvatarView.snp.makeConstraints({make in
            make.top.equalTo(5)
            make.left.equalTo(10)
        })
        
        headerTitle.snp.makeConstraints { make in
            make.left.equalTo(headerAvatarView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.top.equalTo(20)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func refreshUser(withUser user: UserAvatarUI) {
        let avatarInfo = AvatarInfo()
        
        avatarInfo.avatarURL = user.avatarUrl ?? ""
        avatarInfo.verifiedIcon = user.verificationIcon ?? ""
        avatarInfo.verifiedType = user.verificationType ?? ""
        avatarInfo.avatarPlaceholderType = .unknown
        
        headerAvatarView.avatarInfo = avatarInfo
        headerTitle.text = user.displayname
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attrString = label.attributedText else {
            return false
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attrString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

//
//  SessionViewController.swift
//  Yippi
//
//  Created by Tinnolab on 24/03/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import NIMSDK
import Combine
//import NIMPrivate

class ChatViewController: TSViewController, UITableViewDelegate {
    
    lazy var tableview: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(BaseMessageCell.nib(), forCellReuseIdentifier: BaseMessageCell.cellIdentifier)
        table.register(TipsTableViewCell.nib(), forCellReuseIdentifier: TipsTableViewCell.cellIdentifier)
        table.register(MeetNewUserInfoTipsCell.nib(), forCellReuseIdentifier: MeetNewUserInfoTipsCell.cellIdentifier)
        table.register(TipMessageCell.nib(), forCellReuseIdentifier: TipMessageCell.cellIdentifier)
        table.showsVerticalScrollIndicator = false
        table.delegate = self
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        table.backgroundColor = AppTheme.inputContainerGrey
        table.allowsSelection = false
        table.estimatedSectionHeaderHeight = 0
        table.estimatedSectionFooterHeight = 0
        return table
    }()
    
    lazy var chatInputView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 50)))
        view.backgroundColor = .darkGray
        return view
    }()
    
    lazy var bottomInfoView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 20)))
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    lazy var infoLabel: UILabel = {
        let infoLbl = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 14)))
        infoLbl.font = UIFont.boldSystemFont(ofSize: 10.0)
        infoLbl.textColor = .red
        infoLbl.text = "secret_chat_input_bar_info".localized
        infoLbl.textAlignment = .center
        infoLbl.numberOfLines = 2
        return infoLbl
    }()
    
    lazy var loadingIndicator = UIActivityIndicatorView(style: .medium).configure {
        $0.hidesWhenStopped = true
    }
    
    var hideKeyboardGesture: UITapGestureRecognizer!
//    var sessionInputView: NTESInputView!
    private var currentInputHeight: CGFloat = 0.0
    private let inputConfig = ChatInputConfig()
    var isAutoScrollEnabled = true
    var autoReadEnabled = true
    
    var session: NIMSession
    var unreadCount: Int = 0
    lazy var messageManager = IMChatViewDataManager(session: session, unreadCount: unreadCount)
    lazy var dataSource = makeDataSource()
    var messageStatusObserver: NSKeyValueObservation?
    
    // speech model
    var locale: Locale = .current
    var recognizedText = ""
    var isRecognitionInProgress = false
    init(session: NIMSession, unread: Int) {
        self.session = session
        self.unreadCount = unread
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        addObserver()
        self.autoReadEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver()
        self.autoReadEnabled = false
    }
    
    func setupUI() {
        
        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 0
            stack.distribution = .fill
            stack.alignment = .fill
        }
        bottomInfoView.addSubview(infoLabel)
        stackView.addArrangedSubview(tableview)
        stackView.addArrangedSubview(bottomInfoView)
        stackView.addArrangedSubview(chatInputView)
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {(make) in
            make.top.bottom.equalTo(self.view)
            make.left.right.equalTo(self.view)
        }
        infoLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(4)
        }
        bottomInfoView.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
        chatInputView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view).inset(0)
            make.height.equalTo(52)
        }
        self.setUpInputView()
    }
    
    func setUpInputView() {
//        if self.sessionInputView == nil {
//            self.sessionInputView = NTESInputView(frame:CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), config: self.inputConfig)
//            self.sessionInputView.setInputDelegate(self)
//            self.sessionInputView.setInputActionDelegate(self)
//            self.sessionInputView.refreshStatus(NIMInputStatus.text)
//            self.chatInputView.addSubview(self.sessionInputView)
//            self.sessionInputView.snp.makeConstraints {(make) in
//                make.edges.equalToSuperview()
//            }
//        }
    }
    
    func fetchLatestMessage(message: MessageData) {
        
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //app 进入后台通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageReadState(notice:)), name: NSNotification.Name(rawValue: "updateMessageReadState"), object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateMessageReadState"), object: nil)
        
    }
    
    //
    @objc func updateMessageReadState(notice: NSNotification) {
        guard let flag = notice.userInfo?["background"] as? Bool else { return }
        autoReadEnabled = !flag
        
    }
    
    //MARK: - keyboard
    @objc func hideKeyboard() {
//        self.sessionInputView.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = 52 + keyboardSize.height
            self.chatInputView.snp.updateConstraints {
                $0.bottom.equalTo(self.view).inset(0)
                $0.height.equalTo(height)
            }
            currentInputHeight = height
            self.view.layoutIfNeeded()
            self.scrollToBottom(animate: true)
        }
        self.view.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.view.removeGestureRecognizer(hideKeyboardGesture)
    }
    
    private func scrollToBottom(animate: Bool) {
        let row = (self.tableview.numberOfRows(inSection: 0) - 1)
        
        if row > 0 {
            let indexPath:IndexPath = IndexPath(row: row, section: 0)
            self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: animate)
        }
    }
    
    func makeDataSource() -> ChatDataSource {
        return ChatDataSource(tableView: tableview) { _, _, _ in
            return UITableViewCell()
        }
    }
    
    func scrollToBottom(_ animation: Bool? = true) {
        self.isAutoScrollEnabled = true
        let lastRow = self.dataSource.snapshot().numberOfItems
        guard lastRow > 0 else {
            return
        }
        let lastIndexPath = IndexPath(row: lastRow - 1, section: 0)
        self.tableview.scrollToRow(at: lastIndexPath, at: .bottom, animated: animation ?? false)
    }
    
    func setTopContentInset() -> CGFloat {
        self.tableview.contentInset.top = self.tableview.contentSize.height > self.view.height ? 30 : 0
        return self.tableview.contentInset.top
    }
}

//extension ChatViewController: NIMInputActionDelegate {
//    func onSendText(_ text: String?, atUsers: [Any]?) -> Void {
//    }
//}
//
//extension ChatViewController: NIMInputDelegate {
//    func didChangeInputHeight(_ inputHeight: CGFloat) -> Void {
//        if currentInputHeight != inputHeight {
//            
//            self.chatInputView.snp.updateConstraints {
//                $0.bottom.equalTo(self.view).inset(TSBottomSafeAreaHeight)
//                $0.height.equalTo(inputHeight)
//            }
//            
//            self.view.layoutIfNeeded()
//            
//            if inputHeight > currentInputHeight {
//                self.scrollToBottom(animate: true)
//            }
//            currentInputHeight = inputHeight
//        }
//    }
//}

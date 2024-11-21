//
//  MeetingListViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/2.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD

class MeetingListViewController: TSViewController {
    
    var newMeeting: UIButton!
    var joinMeeting: UIButton!
    var offset: Int = 1
    let allStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fill
    }
    
    let stackView: UIView = UIView().configure {
        $0.backgroundColor = .white
       
    }
    
    //空白填充view
    let fillView: UIView = UIView().configure {
        $0.backgroundColor = .white
    }
    
    lazy var tableView: TSTableView = {
        let tb = TSTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0), style: .plain)
        tb.rowHeight = 74
        tb.register(MeetingListViewCell.self, forCellReuseIdentifier: MeetingListViewCell.cellIdentifier)
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.backgroundColor = .white
        return tb
    }()
    
    var dataSouce: [QuertMeetingListDetailModel]?
    var payInfo:PayInfo?
    
    var payInfoVC: MeetingVarietyViewController?
    
    var infoVC: MeetingPayinfoView?
    
    var isFrist = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let nav = self.navigationController as? TSNavigationController {
            nav.setCloseButton(backImage: true, titleStr: "meeting_kit".localized)
        }
        setUI()
        //initData()
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMeetingPayInfo()
    }
    
    @objc func initData(){
        offset = 1
        TSIMNetworkManager.quertMeetingList(page: "\(offset)") { resultModel, error in
            self.tableView.mj_header.endRefreshing()
            if let error = error {
                self.showError(message: error.localizedDescription)
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = resultModel?.data {
                    //self.data = resultModel?.data
                    self.dataSouce = datas.data
                    self.tableView.removePlaceholderViews()
                    if (datas.data?.count ?? 0) < 15 {
                        if (datas.data?.count ?? 0) == 0{
                            self.tableView.show(placeholderView: .empty)
                        }
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.makeVisible()
                        self.tableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func loadMoreFriends(){
        offset = offset + 1
        self.tableView.mj_footer.makeVisible()
        TSIMNetworkManager.quertMeetingList(page: "\(offset)") { resultModel, error in
            self.tableView.mj_header.endRefreshing()
            if let error = error {
                self.tableView.mj_footer.endRefreshing()
                self.tableView.show(placeholderView: .network)
            }else {
                if let datas = resultModel?.data {
                    //self.data = resultModel?.data
                    self.dataSouce = (self.dataSouce ?? []) + (datas.data ?? [])
                    if (datas.data?.count ?? 0) < 15 {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }else{
                    self.tableView.mj_footer.endRefreshing()
                }
            }
        }
        
    }
    
    func getMeetingPayInfo(){
        
        TSIMNetworkManager.quertMeetingPayInfo(complete: { [weak self] model, error in
            DispatchQueue.main.async {

                if let error = error {
                    
                }else {
                    if let model = model {
                        self?.payInfo = model.data
                        if self?.payInfo?.level == 1 {
                            self?.showPayInfoView()
                            self?.isFrist = false
                        }
                    }
                }
            }
        })
    }

    func setUI(){
        self.view.addSubview(allStackView)
        allStackView.bindToEdges()
        allStackView.addArrangedSubview(fillView)
        fillView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
//        let space = UIView()
//        allStackView.addArrangedSubview(space)
//        space.snp.makeConstraints { make in
//            make.height.equalTo(20)
//        }
        
        var myMeeting = UILabel()
        myMeeting.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.129, alpha: 1)
        myMeeting.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        myMeeting.text = "meeting_my_meeting".localized
        allStackView.addArrangedSubview(myMeeting)
        myMeeting.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.left.equalTo(16)
        }
        allStackView.addArrangedSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
        }
        
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(initData))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreFriends))
        tableView.mj_footer.makeHidden()
        
        allStackView.addArrangedSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.height.equalTo(47)
        }
        
        newMeeting = self.createMeetingButton(backColor: AppTheme.red, title: "new_meeting".localized)
        joinMeeting = self.createMeetingButton(backColor: UIColor(hex: "#EDEDED"), title: "join_meeting".localized, titleColor: .black)
        stackView.addSubview(newMeeting)
        stackView.addSubview(joinMeeting)
        newMeeting.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.width.equalTo((ScreenWidth - 56) / 2)
            make.height.equalTo(47)
        }
        joinMeeting.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.width.equalTo((ScreenWidth - 56) / 2)
            make.height.equalTo(47)
        }
        newMeeting.addTarget(self, action: #selector(createMeetingAction), for: .touchUpInside)
        joinMeeting.addTarget(self, action: #selector(joinMeetingAction), for: .touchUpInside)
    }
    
    func showPayInfoView(){
        if let info = self.payInfo {
            if isFrist {
                fillView.snp.makeConstraints { make in
                    make.height.equalTo(10)
                }
                infoVC = MeetingPayinfoView(frame: .zero, payInfo: info)
                allStackView.insertArrangedSubview(infoVC!, at: 0)
            }else {
                infoVC?.setTitleInfo(payInfo: info)
            }
            
        }
    }
    
    //创建会议
    @objc func createMeetingAction(){
        guard let payInfo = self.payInfo else {
            if !(TSReachability.share.isReachable()) {
                showError(message: "network_is_not_available".localized)
            }else{
                getMeetingPayInfo()
            }
            return
        }

        if payInfo.level == 1 {
            let vc = CreateMeetingViewController()
            vc.meetingLevel = payInfo.level
            vc.meetingNumlimit =  (payInfo.vipMeetingMemberLimit ?? "120").toInt()
            vc.duration =  0
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        guard let rootVC = UIApplication.topViewController() else {
            return
        }
        
        let vc = MeetingVarietyViewController()
        vc.payInfo = payInfo
        vc.view.frame = rootVC.view.bounds
        rootVC.view.addSubview(vc.view)
        rootVC.addChild(vc)
        vc.didMove(toParent: rootVC)
        payInfoVC = vc
        vc.starBackCall = { tag in
            if tag == 100 {
                self.payInfoVC?.dismiss()
                self.payInfoVC = nil
                let vc1 = CreateMeetingViewController()
                vc1.meetingLevel = 0
                vc1.meetingNumlimit = (payInfo.freeMemberLimit ?? "50").toInt()
                vc1.duration = (payInfo.freeTimeLimit ?? "45").toInt()
                self.navigationController?.pushViewController(vc1, animated: true)
                
            }else{
                FeedIMSDKManager.shared.delegate?.didShowPin(type: .purchase, completion: {[weak self] pin in
                    self?.meetingPay(pin: pin)
                }, cancel: {
                    
                }, needDisplayError: true)
//                self.showPin(type: .purchase, { [weak self] pin in
//                    self?.meetingPay(pin: pin)
//                    
//                }, cancel: nil)
            }
        }
    }
    
    //加入会议
    @objc func joinMeetingAction(){
        let vc = JoinMeetingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createMeetingButton(backColor: UIColor, title: String, titleColor: UIColor = .white) -> UIButton{
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.backgroundColor = backColor
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.clipsToBounds = true
        return btn
    }
    
    func meetingPay(pin: String) {
        TSIMNetworkManager.payMeetingFee(pin: pin) { [weak self] model, error in
            guard let self = self, let rootVC = UIApplication.topViewController() else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.payInfoVC?.dismiss()
                    self.payInfoVC = nil
                    TSUtil.dismissPin()
                    rootVC.showError(message: error.localizedDescription)
                } else {
                    guard let model = model else { return }
                    switch model.code {
                    case 1007:
                        TSUtil.dismissPin()
                        let lView = MeetingPayView(frame:CGRect(x: 0, y: 0, width: 0, height: 0), isSucceed: true, time: model.data?.expiredAt ?? "")
                        let popup = TSAlertController(style: .popup(customview: lView), hideCloseButton: true, allowBackgroundDismiss: false)
                        
                        lView.okBtnClosure = {
                            self.payInfoVC?.dismiss()
                            self.payInfoVC = nil
                            self.getMeetingPayInfo()
                            popup.dismiss()
                        }
                        popup.modalPresentationStyle = .overFullScreen
                        rootVC.present(popup, animated: false)
                    case 1008, 1005, 1006, 1003:
//                        self?.payInfoVC?.dismiss()
//                        self?.payInfoVC = nil
                        TSUtil.dismissPin()
                        let lView = MeetingPayView(frame:CGRect(x: 0, y: 0, width: 0, height: 0), isSucceed: false, time: "")
                        let popup = TSAlertController(style: .popup(customview: lView), hideCloseButton: true, allowBackgroundDismiss: false)
                        
                        lView.okBtnClosure = {
                            popup.dismiss()
                        }
                        popup.modalPresentationStyle = .overFullScreen
                        rootVC.present(popup, animated: false)
                    default:
//                        if UserDefaults.biometricEnabled && (TSUtil.share().pinVC == nil) {
//                            rootVC.showTopIndicator(status: .faild, model.message)
//                        } else {
//                            TSUtil.showPinError(model.message)
//                        }
                        break
                    }
                }
            }
        }
    }
}

extension MeetingListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSouce?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MeetingListViewCell.cellIdentifier, for: indexPath) as! MeetingListViewCell
        cell.setData(model: self.dataSouce?[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}

//
//  YippsTransferSuccessViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/7/5.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

private class DetailView: UIStackView {
    
    private let titleLabel = UILabel().build {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor(hex: 737373)
        $0.textAlignment = .left
    }
    
    private let valueLabel = UILabel().build {
        $0.font = UIFont.systemMediumFont(ofSize: 16)
        $0.textColor = UIColor(hex: 0x242424)
        $0.textAlignment = .left
    }
    
    init(title: String, value: String) {
        super.init(frame: .zero)
        commonInit()
        
        titleLabel.text = title
        valueLabel.text = value
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addArrangedSubview(titleLabel)
        addArrangedSubview(valueLabel)
        
        axis = .vertical
        spacing = 3
        distribution = .fill
        alignment = .fill
    }
    
}

class YippsTransferSuccessViewController: TSViewController {
    //private var data: TransactionModel?
    
    private let headView : UIView = UIView().configure {
        $0.backgroundColor = .white
    }
    
    private let contentView = UIView().configure {
        $0.backgroundColor = .white
    }
    
    private let stackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 20
        $0.distribution = .fill
        $0.alignment = .top
        $0.backgroundColor = .white
    }
    
    private let successIcon = UIImageView().configure {
        $0.image = UIImage.set_image(named: "ic_rl_srs_success_big")
    }
    
    private let moneyLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.text = "Yipps 140"
        $0.textColor = UIColor(hex: 0x242424)
    }
    
    private let successLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor(hex: 0x808080)
        $0.text = "Transfer Successful".localized
    }
    
    private let doneButton = UIButton().configure {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        $0.setTitle("done".localized, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = TSColor.main.theme
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
//    init(data: TransactionModel?) {
//        self.data = data
//        super.init(nibName: nil, bundle: nil)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        setCloseButton(completion: {
            self.doneAction()
        }, needPop: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setUI() {
        self.view.addSubview(headView)
        self.view.addSubview(contentView)
        self.view.addSubview(doneButton)
        
        headView.snp.makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(230)
        }
        headView.addSubview(successIcon)
        headView.addSubview(moneyLabel)
        headView.addSubview(successLabel)
        contentView.addSubview(stackView)
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(15)
            make.bottom.lessThanOrEqualToSuperview().inset(15)
        }
        
        successIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
            make.width.height.equalTo(64)
        }
        
        moneyLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(successIcon.snp.bottom).offset(38)
            make.height.equalTo(40)
        }
        
        successLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(moneyLabel.snp.bottom).offset(12)
            make.height.equalTo(16)
        }
        
        doneButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(25)
            make.height.equalTo(42)
        }
        
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        setDetails()
    }
    
    @objc private func doneAction() {
        self.navigationController?.popViewController(animated: true)
        let presentingVC = self.presentingViewController
        self.navigationController?.dismiss(animated: true, completion: {
            presentingVC?.navigationController?.popToRootViewController(animated: true)
        })
        TSRootViewController.share.presentHome()
    }
    
    private func setDetails() {
       // guard let data = data else { return }
        
//        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 36), NSAttributedString.Key.foregroundColor : UIColor.black]
//        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 36), NSAttributedString.Key.foregroundColor : UIColor.black]
//        let attributedString1 = NSMutableAttributedString(string: String(format: "%@", data.amount), attributes:attrs1)
//        let attributedString2 = NSMutableAttributedString(string:" \("rewards_link_point_short".localized)", attributes:attrs2)
//        attributedString1.append(attributedString2)
//        moneyLabel.attributedText = attributedString1
//        
//        stackView.addArrangedSubview(DetailView(title: "time_to".localized, value: data.targetUser.name))
//        stackView.addArrangedSubview(DetailView(title: "yipps_wanted_transaction_datetime".localized, value: data.createdAt.toDate(from: "yyyy-MM-dd'T'HH:mm:ss.ssssssZ", to: "yyyy-MM-dd HH:mm:ss")))
//        stackView.addArrangedSubview(DetailView(title: "rw_yipps_wanted_transaction_transactionId".localized, value: data.id.stringValue))
    }
}

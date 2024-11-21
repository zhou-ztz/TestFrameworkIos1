//
//  FeedDetailMerchantNamesView.swift
//  RewardsLink
//
//  Created by 深圳壹艺科技有限公司 on 2024/4/7.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class FeedDetailMerchantNamesView: UIView {
    
    var list: [TSRewardsLinkMerchantUserModel] = []
    
    var momentMerchantDidClick: ((_ merchantData: TSRewardsLinkMerchantUserModel) -> Void)?
    
    private let merchantNamesListView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(merchantNamesListView)
        merchantNamesListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setData(merchantList: [TSRewardsLinkMerchantUserModel]) {
        
        merchantNamesListView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        self.list = merchantList
        
        for merchant in merchantList {
            let merchantView = FeedMerchantNamesListView()
            merchantView.setData(merchant: merchant)
            merchantView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(merchantTapped(_:)))
            merchantView.addGestureRecognizer(tap)
            merchantNamesListView.addArrangedSubview(merchantView)
        }
    }
    
    @objc private func merchantTapped(_ sender: UITapGestureRecognizer) {
        if let merchantView = sender.view as? FeedMerchantNamesListView,
           let index = merchantNamesListView.arrangedSubviews.firstIndex(of: merchantView) {
            let merchant = list[index]
            momentMerchantDidClick?(merchant)
        }
    }
}

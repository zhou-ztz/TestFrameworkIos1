//
//  HashtagSectionView.swift
//  Yippi
//
//  Created by Jerry Ng on 22/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class HashtagSectionView: UIScrollView {
    private var hashtagListModel: HashtagListModel?
    private var hashtagStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 8
    }
    
    public var onHashtagSelected: ((HashtagModel?)->())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.addSubview(hashtagStackView)
        hashtagStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(8)
        }
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refresh(contryCode: String, onComplete: @escaping (Bool) -> Void) {
        HashtagRequest().getHashtagList(countryCode: contryCode, onSuccess: { [weak self] (response) in
            guard let model = response, model.data.count > 0 else {
                onComplete(false)
                return
            }
            self?.hashtagListModel = model
            HashTagStoreManager().removeAll()
            HashTagStoreManager().add(list: model.data)
            self?.setupHashtagScrollView()
            onComplete(!model.data.isEmpty)
        }, onFailure: { [weak self] (errorMessage) in
            guard HashTagStoreManager().fetch().count > 0 else {
                onComplete(false)
                return
            }
            self?.hashtagListModel = HashtagListModel()
            self?.hashtagListModel?.data = HashTagStoreManager().fetch()
            self?.setupHashtagScrollView()
            onComplete(true)
        })
    }
    
    private func setupHashtagScrollView() {
        hashtagStackView.removeAllArrangedSubviews()
        guard let hashtags = self.hashtagListModel, hashtags.data.count > 0 else {
            self.isHidden = true
            return
        }
        self.isHidden = false
        
        for hashtag in hashtags.data {
            let label = TSLabel()
            label.text = hashtag.name?.first == "#" ? hashtag.name : String(format: "%@%@", "#", hashtag.name ?? "")
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textColor = UIColor(red: 198.0/255.0, green: 198.0/255.0, blue: 200.0/255.0, alpha: 1.0)
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor(red: 198.0/255.0, green: 198.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
            label.roundCorner(12)
            label.textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            label.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            label.addAction { [weak self] in
                self?.onHashtagSelected?(hashtag)
            }
            hashtagStackView.addArrangedSubview(label)
        }
    }
}

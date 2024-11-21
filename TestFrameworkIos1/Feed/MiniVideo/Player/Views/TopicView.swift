//
//  TopicView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 09/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

extension UIResponder {
    func getParentViewController() -> UIViewController? {
        if self.next is UIViewController {
            return self.next as? UIViewController
        } else {
            if self.next != nil {
                return (self.next!).getParentViewController()
            }
            else {
                return nil
            }
        }
    }
}

class TopicListView: UIView {
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView().configure {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 10
            $0.alignment = .leading
        }
        return stackview
    }()
    
    init() {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.backgroundColor = .clear
        addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
    }
    
    func setTopics(_ topics: [TopicListModel]) {
        stackview.removeAllArrangedSubviews()
        
        topics.forEach { (topic) in
            let view = TopicView(title: topic.topicTitle)
            // By Kit Foong (Add gesture for topic)
            view.addTap { [weak self] (_) in
                //                guard let self = self, let feedListCell = self.parentFeedListCell, let feedListCellDelegate = self.feedListCellDelegate else { return }
                //                feedListCellDelegate.feedCellDidClickTopic?(feedListCell, topicId: topic.topicId)
                let topicVC = TopicPostListVC(groupId: topic.topicId)
                if #available(iOS 11, *) {
                    self?.getParentViewController()?.navigation(navigateType: .pushView(viewController: topicVC))
                } else {
                    let nav = TSNavigationController(rootViewController: topicVC).fullScreenRepresentation
                    self?.getParentViewController()?.navigation(navigateType: .presentView(viewController: nav))
                }
            }
            stackview.addArrangedSubview(view)
        }
        
        self.layoutIfNeeded()
    }

}

class TopicView: UIView {
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.applyStyle(.regular(size: 12, color: TSColor.main.theme))
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        self.backgroundColor = TSColor.main.theme.withAlphaComponent(0.2)
        self.roundCorner(3)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(5)
            $0.top.bottom.equalToSuperview().inset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

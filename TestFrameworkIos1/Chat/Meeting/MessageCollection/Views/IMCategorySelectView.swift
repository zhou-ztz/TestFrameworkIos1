//
//  IMCategorySelectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/15.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMCategorySelectView: UIView {

    private let scrollView = UIScrollView()
    private let content: UIStackView = UIStackView()
    private var animatable: Bool = false
    var selectedType: MessageCollectionType = .text
    var selectionHandler: ((MessageCollectionType, String) -> Void)?
    var notifyComplete: EmptyClosure?
    
    init(selectedType: MessageCollectionType, animatable: Bool) {
        super.init(frame: .zero)
        self.selectedType = selectedType
        self.animatable = animatable
        prepareViews()
    }
    
    private func prepareViews()  {
        addSubview(scrollView)
        scrollView.addSubview(content)

        content.alignment = .fill
        content.axis = .vertical
        content.spacing = 0
        content.distribution = .fill

        scrollView.snp.makeConstraints { (v) in
            v.top.left.bottom.right.equalToSuperview()
        }

        content.snp.makeConstraints { (v) in
            v.top.left.right.equalToSuperview()
            v.bottom.lessThanOrEqualToSuperview()
            v.width.equalTo(UIScreen.main.bounds.width)
        }

        scrollView.addTap { [weak self] (v) in
            guard v.superview != nil else { return }
            self?.hide()
        }
        var categotyList = [CategoryMsgModel]()
        let types: [MessageCollectionType] = [.text, .image, .audio, .video, .location, .file, .nameCard, .sticker, .link, .miniProgram]
        let names: [String] = ["filter_favourite_chats".localized, "filter_favourite_photos".localized, "filter_favourite_audios".localized, "filter_favourite_videos".localized, "filter_favourite_locations".localized, "filter_favourite_files".localized, "filter_favourite_contacts".localized, "filter_favourite_stickers".localized, "filter_favourite_links".localized, "filter_favourite_mini_programs".localized]
        let images: [UIImage] = []
        
        for i in 0..<types.count {
            let model = CategoryMsgModel(type: types[i], name: names[i], image: images[i])
            categotyList.append(model)
            
        }
        setupcategoryViewOptions(categotyList: categotyList, selectedType: selectedType, onSelected: self.selectionHandler)
//        setupcategoryViewOptions(categotyList: categotyList, selectedType: selectedType) {[weak self] (type, name) in
//            self?.selectionHandler!(type, name)
//            self?.hide()
//        }
    }
    
    private func setupcategoryViewOptions(categotyList: [CategoryMsgModel], selectedType: MessageCollectionType, onSelected: ((MessageCollectionType, String) -> Void)?) {
        let categoryView = IMMessageSelectorView(categotyList: categotyList, selectedType: selectedType) {[weak self] (type, name) in
            self?.selectionHandler!(type, name)
            self?.hide()
        }
        content.addArrangedSubview(categoryView)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        show()
    }
    
    private func show() {
        guard animatable == true else { return }
        self.layoutIfNeeded()
        content.transform = CGAffineTransform(translationX: 0, y: -self.content.height)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.content.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }, completion: nil)
            
    }
    
    func hide() {
        guard animatable == true else { return }
        //        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.15, delay: 0.2, options: [.curveEaseOut]) {
            self.content.transform = CGAffineTransform(translationX: 0, y: -self.content.height)
            self.backgroundColor = .clear
            self.layoutIfNeeded()
        } completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.removeFromSuperview()
                self.notifyComplete?()
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}

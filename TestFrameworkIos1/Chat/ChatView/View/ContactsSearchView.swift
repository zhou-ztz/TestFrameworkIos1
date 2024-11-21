//
//  ContactsSearchView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

enum SearchCancleType: Int {
    case editingShow = 0 // 编辑时显示 cancel
    case allwayShow = 1
    case allwayNoShow = 2
}

protocol ContactsSearchViewDelegate: class {
    func searchDidClickReturn(text: String)
    func searchDidClickCancel()
    func searchTextDidChange(text: String)
}

class ContactsSearchView: UIView {

    weak var delegate: ContactsSearchViewDelegate?
    public let searchTextFiled = UITextField()
    let searchIcon = UIImageView()
    let leftView = UIView()
    var cancelType: SearchCancleType = .editingShow
    lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        //btn.isHidden = true
        return btn
    }()
    
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fill
        $0.alignment = .center
    }

    init(frame: CGRect, cancelType: SearchCancleType = .editingShow) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.main.white
        self.cancelType = cancelType
        setUI()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = TSColor.main.white
        setUI()
    }

    private func setUI() {
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16.5)
            make.top.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(searchTextFiled)
        stackView.addArrangedSubview(rightButton)
        searchTextFiled.snp.makeConstraints { (make) in
            make.height.equalTo(36)
        }
        searchTextFiled.delegate = self
        searchTextFiled.font = UIFont.systemFont(ofSize: 14)
        searchTextFiled.textColor = TSColor.main.content
        searchTextFiled.placeholder = "placeholder_search_message".localized
        searchTextFiled.backgroundColor = .white
        searchTextFiled.layer.cornerRadius = 18
        searchTextFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextFiled.returnKeyType = .search
        searchIcon.image = UIImage.set_image(named: "IMG_search_icon_search")
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(x: 0, y: 0, width: 35, height: 27)
        leftView.frame = CGRect(x: 0, y: 0, width: 15, height: 27)
        searchTextFiled.leftView = searchIcon
        searchTextFiled.leftViewMode = .always
        searchTextFiled.clearButtonMode = .whileEditing
        rightButton.setTitle("cancel".localized, for: .normal)
        rightButton.setTitleColor(AppTheme.red, for: .normal)
        rightButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        searchIcon.snp.makeConstraints {
            $0.height.equalTo(27)
            $0.width.equalTo(35)
        }
        
        rightButton.snp.makeConstraints { (make) in
            make.height.equalTo(36)
        }
    
        searchTextFiled.layer.shadowColor = UIColor.black.cgColor
        searchTextFiled.layer.shadowOpacity = 0.2
        searchTextFiled.layer.shadowRadius = 4
        searchTextFiled.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        switch cancelType {
        case .editingShow:
            rightButton.isHidden = true
        case .allwayShow:
            rightButton.isHidden = false
        case .allwayNoShow:
            rightButton.isHidden = true
        }
        
        
    }
    
    @objc func cancelAction(){
        self.delegate?.searchDidClickCancel()
    }


}

extension ContactsSearchView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if cancelType == .editingShow {
            rightButton.isHidden = false
        }
        textField.leftView = leftView
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if cancelType == .editingShow {
            rightButton.isHidden = true
        }
        textField.leftView = searchIcon
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.searchDidClickReturn(text: textField.text ?? "")
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.searchTextDidChange(text: textField.text ?? "")
        
    }
    
    
    
}

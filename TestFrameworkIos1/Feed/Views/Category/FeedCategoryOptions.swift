//
//  FeedCategorySelectorView.swift
//  Yippi
//
//  Created by Francis Yeap on 29/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit


enum CategorySelectorType {
    case country
    case language(code: String?)
    
    var code: String? {
        switch self {
        case .language(let code):
            return code
        default:
            return nil
        }
    }
}

class FeedCategorySelectorView: UIView {

    var onTapOpen: EmptyClosure? {
        didSet {
            self.removeGestures()
            self.addTap(action: { [weak self] _ in
                self?.onTapOpen?()
            })
        }
    }
    var optionText: String {
        switch self.selectorType {
            case .country:
                if TSCurrentUserInfo.share.isLogin {
                    return (CountryCategorySelector().options.first(where: { $0.code == (userConfiguration?.feedcontentCountry).orEmpty })?.name) ?? "text_international".localized
                } else {
                    return (CountryCategorySelector().options.first(where: { $0.code == (UserDefaults.standard.string(forKey: "FEEDCOUNTRYCODE")).orEmpty })?.name) ?? "text_international".localized
                }

            case .language:
                if TSCurrentUserInfo.share.isLogin {
                    return (LanguageCategorySelector().options.first(where: { $0.code == selectorType.code.orEmpty })?.name).orEmpty
                } else {
                    return (LanguageCategorySelector().options.first(where: { $0.code == (UserDefaults.standard.string(forKey: "SEARCHLANGUAGECODE")).orEmpty })?.name).orEmpty
                }
        }
    }
    let optionView = FeedCategoryOptions()
    private(set) var expanded: Bool = false
    public var content: UIStackView = UIStackView().configure {
        $0.distribution = .fill
        $0.alignment = .leading
        $0.axis = .horizontal
        $0.spacing = 12
    }
    private var selectorType: CategorySelectorType = .country
    
    init(type: CategorySelectorType = .country) {
        super.init(frame: .zero)
        self.selectorType = type
        addSubview(content)
        content.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.equalToSuperview().inset(12)
            make.right.lessThanOrEqualToSuperview().inset(12)
        }

        NotificationCenter.default.observe(Notification.Name.Setting.configUpdated) { [weak self] in
            self?.updateText()
        }
        content.addArrangedSubview(optionView)
        updateText()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func updateText() {
        optionView.label.text = optionText
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
 
    func show() {
        guard isHidden == true else { return }
        expanded = true
        self.isHidden = false
        self.alpha = 1
    }
    
    func hide() {
        guard isHidden == false else { return }
        expanded = false
        self.isHidden = true
        self.alpha = 0
    }
    
}


class FeedCategoryOptions: UIView {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet var view: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        UINib(nibName: "FeedCategoryOptions", bundle: nil).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
        borderView.roundCorner(25.0/2)
        borderView.backgroundColor = .white
        borderView.layer.borderColor = UIColor(hex: 0xD1D1D1).cgColor
        borderView.layer.borderWidth = 1.0

        label.textColor = AppTheme.brownGrey
    }
  
}



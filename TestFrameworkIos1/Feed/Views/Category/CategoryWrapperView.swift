//
//  CategoryWrapperView.swift
//  Yippi
//
//  Created by Francis Yeap on 02/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

class CategoryWrapperView: UIView {
    
    private let scrollView = UIScrollView()
    private let content: UIStackView = UIStackView()
    private var animatable: Bool = false  
    var notifyComplete: EmptyClosure?

    init(options: [FeedCategoryOptionsType], animatable: Bool = true) {
        super.init(frame: .zero)

        self.animatable = animatable
        prepareViews()
        // set options
        for option in options {
            switch option {
            case let .country(selections, country, onSelect):
                setupCountryOptions(for: "text_select_country".localized, preselect: country, countries: selections, onSelected: { [weak self] code in
                    onSelect?(code)
                    self?.hide()
                })

            case let .language(selections, language, onSelect):
                setupLanguageOptions(for: "text_select_language".localized, preselect: language, languages: selections) { [weak self] code in
                    onSelect?(code)
                    self?.hide()
                }
                
            }
        }
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
    }
    // MARK: - 重置用户的选择
    func resetChoose() {
        
        for selectorView in content.subviews {
            if let langSelectorView = selectorView as? LanguageSelectorView {
                langSelectorView.selectedLanguage = langSelectorView.languages.first
                langSelectorView.updateUI()
            }
            if let countrySelectorView = selectorView as? CountrySelectorView {
                countrySelectorView.selectedCountry = countrySelectorView.countries.first
                countrySelectorView.updateUI()
            }
        }

        
    }
    private func setupLanguageOptions(for title: String?, preselect: String, languages: [LanguageEntity], onSelected: ((LanguageCode) -> Void)?) {
        let languageView = LanguageSelectorView(title: title.orEmpty,
                languages: languages,
                selected: preselect,
                selectionHandler: onSelected)
        content.addArrangedSubview(languageView)
    }
    
    private func setupCountryOptions(for title: String?, preselect: String, countries: [CountryEntity], onSelected: ((CountryCode) -> Void)?) {
        let countryView = CountrySelectorView(title: title.orEmpty,
                countries: countries,
                selected: preselect,
                selectionHandler: onSelected)
        content.addArrangedSubview(countryView)
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

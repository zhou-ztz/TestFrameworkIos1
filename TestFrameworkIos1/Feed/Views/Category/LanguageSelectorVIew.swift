//
// Created by Francis Yeap on 09/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit


private struct SelectorStyle {
    let labelColor = UIColor.lightGray
    let selectedLabelColor = AppTheme.aquaBlue

    let titleColor = UIColor.darkGray
    let titleFont = UIFont.boldSystemFont(ofSize: 12)

    let itemsPerGrid = 4
}

class LanguageSelectorView: UIView {

    private let styles = SelectorStyle()
    private let contentView = UIView()
    private let languageGridView = UIStackView().configure { (v) in
        v.axis = .vertical
        v.distribution = .fillEqually
        v.alignment = .fill
        v.spacing = 0

    }
    var selectedLanguage: LanguageEntity?
    var languages: [LanguageEntity] = [LanguageEntity]()
    private var selectionViews: [SelectionView] = []
    private var heading: String?
    private var selectionHandler: ((LanguageCode) -> Void)?

    init(title: String?, languages: [LanguageEntity], selected: LanguageCode, selectionHandler: ((LanguageCode) -> Void)?) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white

        self.languages = languages
        self.heading = title
        self.selectedLanguage = self.languages.first(where: { $0.code == selected })
        self.selectionHandler = selectionHandler
        prepareUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError("view not supported")
    }

    private func setTitle(_ value: String?) {
        guard let value = value, value.isEmpty == false else { return }

        let title: UILabel = UILabel().configure { (_label) in
            _label.font = self.styles.titleFont
            _label.textColor = self.styles.titleColor
            _label.textAlignment = .left
            _label.text = value
        }
        languageGridView.addArrangedSubview(title)
    }

    private func prepareUI() {
        addSubview(contentView)
        contentView.bindToEdges(inset: 12)
        contentView.addSubview(languageGridView)
        languageGridView.bindToEdges()
    }

    func updateUI() {
        selectionViews = []
        languageGridView.removeAllSubviews()
        setTitle(heading)
        var pointerGrid: UIStackView?

        for (i, language) in languages.enumerated() {
            let (qoutient, remainder) = i.quotientAndRemainder(dividingBy: self.styles.itemsPerGrid)
            let activeView = SelectionView(with: language.name)

            if remainder == 0 { // start new grid
                let horizontalGrid = UIStackView().configure { (v) in
                    v.axis = .horizontal
                    v.spacing = 5
                    v.distribution = .fillEqually
                    v.alignment = .fill
                }
                pointerGrid = horizontalGrid
                horizontalGrid.addArrangedSubview(activeView)

                languageGridView.addArrangedSubview(horizontalGrid)
            } else {
                pointerGrid?.addArrangedSubview(activeView)
            }

            selectionViews.append(activeView)

            if i == (languages.count - 1) && pointerGrid != nil {
                languageGridView.addArrangedSubview(pointerGrid!)

                for i in remainder..<(self.styles.itemsPerGrid - 1) {
                    pointerGrid!.addArrangedSubview(UIView())
                }
            }
            activeView.selected = language.code == (selectedLanguage?.code).orEmpty

            activeView.onTap = { [weak self] currentView in
                guard let self = self else { return }
                currentView.selected = true
                self.selectionViews.forEach({ (v) in
                    guard v != currentView else { return }
                    v.selected = false
                })
                self.selectionHandler?(language.code)
            }
        }
    }
}


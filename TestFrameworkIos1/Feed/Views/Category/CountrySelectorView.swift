//
//  CountrySelectorView.swift
//  Yippi
//
//  Created by Francis Yeap on 02/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit


private struct SelectorStyle {
    let labelColor = UIColor.lightGray
    let selectedLabelColor = AppTheme.aquaBlue
    
    let titleColor = AppTheme.brownGrey
    let titleFont = UIFont.boldSystemFont(ofSize: 12)
    
    let itemsPerGrid = 4
}

class CountrySelectorView: UIView {
    
    private let styles = SelectorStyle()
    private let contentView = UIView()
    private let countryGridView = UIStackView().configure { (v) in
        v.axis = .vertical
        v.distribution = .fillEqually
        v.alignment = .fill
        v.spacing = 0
    }
    var selectedCountry: CountryEntity?
    var countries: [CountryEntity] = [CountryEntity]()
    private var selectionViews: [SelectionView] = []
    private var heading: String?
    private var selectionHandler: ((CountryCode) -> Void)?
    
    init(title: String?, countries: [CountryEntity], selected: CountryCode, selectionHandler: ((CountryCode) -> Void)?) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white
        
        self.countries = countries
        self.heading = title
        self.selectedCountry = self.countries.first(where: { $0.code == selected })
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
        countryGridView.addArrangedSubview(title)
    }

    private func prepareUI() {
        addSubview(contentView)
        contentView.bindToEdges(inset: 12)
        contentView.addSubview(countryGridView)
        countryGridView.bindToEdges()
    }
    
    func updateUI() {
        selectionViews = []
        countryGridView.removeAllSubviews()
        setTitle(heading)
        var pointerGrid: UIStackView?
        
        for (i, country) in countries.enumerated() {
            let (qoutient, remainder) = i.quotientAndRemainder(dividingBy: self.styles.itemsPerGrid)
            let activeView = SelectionView(with: country.name)
            
            if remainder == 0 { // start new grid
                let horizontalGrid = UIStackView().configure { (v) in
                    v.axis = .horizontal
                    v.spacing = 5
                    v.distribution = .fillEqually
                    v.alignment = .fill
                }
                pointerGrid = horizontalGrid
                horizontalGrid.addArrangedSubview(activeView)
                
                countryGridView.addArrangedSubview(horizontalGrid)
            } else {
                pointerGrid?.addArrangedSubview(activeView)
            }
            
            selectionViews.append(activeView)
            
            if i == (countries.count - 1) && pointerGrid != nil {
                countryGridView.addArrangedSubview(pointerGrid!)
                
                for i in remainder..<(self.styles.itemsPerGrid - 1) {
                    pointerGrid!.addArrangedSubview(UIView())
                }
            }
            activeView.selected = country.code == (selectedCountry?.code).orEmpty
            
            activeView.onTap = { [weak self] currentView in
                guard let self = self else { return }
                currentView.selected = true
                self.selectionViews.forEach({ (v) in
                    guard v != currentView else { return }
                    v.selected = false
                })
                self.selectionHandler?(country.code)
            }
        }
    }
}


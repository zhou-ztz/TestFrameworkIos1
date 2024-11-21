//
//  IMMessageSelectorView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/15.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

private struct IMSelectorStyle {
    let labelColor = UIColor.lightGray
    let selectedLabelColor = AppTheme.aquaBlue
    
    let titleColor = AppTheme.brownGrey
    let titleFont = UIFont.boldSystemFont(ofSize: 12)
    
    let itemsPerGrid = 3
}

class IMMessageSelectorView: UIView {

    private let contentView = UIView()
    private let countryGridView = UIStackView().configure { (v) in
        v.axis = .vertical
        v.distribution = .fillEqually
        v.alignment = .fill
        v.spacing = 0
    }
    private let styles = IMSelectorStyle()
    var categotyList = [CategoryMsgModel]()
    var selectedType: MessageCollectionType?
    var selectionHandler: ((MessageCollectionType, String) -> Void)?
    private var selectionViews: [SelectionView] = []
    
    init(categotyList: [CategoryMsgModel], selectedType: MessageCollectionType, selectionHandler: ((MessageCollectionType, String) -> Void)?) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white
        self.categotyList = categotyList
        self.selectedType = selectedType
        self.selectionHandler = selectionHandler
        prepareUI()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("view not supported")
    }
    
    private func prepareUI() {
        addSubview(contentView)
        contentView.bindToEdges(inset: 12)
        contentView.addSubview(countryGridView)
        countryGridView.bindToEdges()
    }
    
    private func updateUI() {
        selectionViews = []
        countryGridView.removeAllSubviews()
        var pointerGrid: UIStackView?
        
        for (i, categoty) in categotyList.enumerated() {
            let (qoutient, remainder) = i.quotientAndRemainder(dividingBy: self.styles.itemsPerGrid)
            let activeView = SelectionView(with: categoty.name)
            
            if remainder == 0 { // start new grid
                let horizontalGrid = UIStackView().configure { (v) in
                    v.axis = .horizontal
                    v.spacing = 10
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
            
            if i == (categotyList.count - 1) && pointerGrid != nil {
                countryGridView.addArrangedSubview(pointerGrid!)
                
                for i in remainder..<(self.styles.itemsPerGrid - 1) {
                    pointerGrid!.addArrangedSubview(UIView())
                }
            }
            activeView.selected = categoty.type == selectedType
            
            activeView.onTap = { [weak self] currentView in
                guard let self = self else { return }
                currentView.selected = true
                self.selectionViews.forEach({ (v) in
                    guard v != currentView else { return }
                    v.selected = false
                })
                self.selectionHandler?(categoty.type, categoty.name)
            }
        }
    }
    
    
    

}

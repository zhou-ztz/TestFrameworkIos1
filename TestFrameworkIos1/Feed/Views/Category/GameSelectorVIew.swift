//
//  GameSelectorVIew.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/5/12.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import Foundation
import SnapKit


private struct SelectorStyle {
    let labelColor = UIColor.lightGray
    let selectedLabelColor = AppTheme.aquaBlue

    let titleColor = UIColor.darkGray
    let titleFont = UIFont.boldSystemFont(ofSize: 12)

    let itemsPerGrid = 4
}

class GameSelectorView: UIView {

//    private let styles = SelectorStyle()
//    private let contentView = UIView()
//    private let gameGridView = UIStackView().configure { (v) in
//        v.axis = .vertical
//        v.distribution = .fillEqually
//        v.alignment = .fill
//        v.spacing = 0
//
//    }
//    var selectedGame: LiveSubCategoryList?
//    var games: [LiveSubCategoryList] = [LiveSubCategoryList]()
//    private var selectionViews: [SelectionView] = []
//    private var heading: String?
//    private var selectionHandler: ((GameCode) -> Void)?
//
//    init(title: String?, games: [LiveSubCategoryList], selected: GameCode, selectionHandler: ((GameCode) -> Void)?) {
//        super.init(frame: .zero)
//        backgroundColor = UIColor.white
//
//        self.games = games
//        self.heading = title
//        
//        self.selectedGame = self.games.first(where: { $0.code == selected.toInt() })
//        self.selectionHandler = selectionHandler
//        prepareUI()
//        updateUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("view not supported")
//    }
//
//    private func setTitle(_ value: String?) {
//        guard let value = value, value.isEmpty == false else { return }
//
//        let title: UILabel = UILabel().configure { (_label) in
//            _label.font = self.styles.titleFont
//            _label.textColor = self.styles.titleColor
//            _label.textAlignment = .left
//            _label.text = value
//        }
//        gameGridView.addArrangedSubview(title)
//    }
//
//    private func prepareUI() {
//        addSubview(contentView)
//        contentView.bindToEdges(inset: 12)
//        contentView.addSubview(gameGridView)
//        gameGridView.bindToEdges()
//    }
//
//    func updateUI() {
//        selectionViews = []
//        gameGridView.removeAllSubviews()
//        setTitle(heading)
//        var pointerGrid: UIStackView?
//
//        for (i, game) in games.enumerated() {
//            let (qoutient, remainder) = i.quotientAndRemainder(dividingBy: self.styles.itemsPerGrid)
//            let activeView = SelectionView(with: game.name)
//
//            if remainder == 0 { // start new grid
//                let horizontalGrid = UIStackView().configure { (v) in
//                    v.axis = .horizontal
//                    v.spacing = 5
//                    v.distribution = .fillProportionally
//                    v.alignment = .fill
//                }
//                pointerGrid = horizontalGrid
//                horizontalGrid.addArrangedSubview(activeView)
//
//                gameGridView.addArrangedSubview(horizontalGrid)
//            } else {
//                pointerGrid?.addArrangedSubview(activeView)
//            }
//
//            selectionViews.append(activeView)
//
//            if i == (games.count - 1) && pointerGrid != nil {
//                gameGridView.addArrangedSubview(pointerGrid!)
//
//                for i in remainder..<(self.styles.itemsPerGrid - 1) {
//                    pointerGrid!.addArrangedSubview(UIView())
//                }
//            }
//            
//            activeView.selected = game.code == (selectedGame?.code)
//
//            activeView.onTap = { [weak self] currentView in
//                guard let self = self else { return }
//                currentView.selected = true
//                self.selectionViews.forEach({ (v) in
//                    guard v != currentView else { return }
//                    v.selected = false
//                })
//                self.selectionHandler?("\(game.code)")
//            }
//        }
//    }
}


//
//  CustomCollectionViewFlowLayout.swift
//  Yippi
//
//  Created by CC Teoh on 08/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    enum GridStyle {
        case fullWidth
        case fiftyFifty
    }

    enum FlowLayoutType: Equatable {
        case singleRow(direction: UICollectionView.ScrollDirection)
        case mosaic(style: GridStyle, direction: UICollectionView.ScrollDirection)
    }
    
    
    private let rowSpacing: CGFloat = 15
    private let pageCountPerLoad: Int = 2
    private var cellCount = 2
    private var cellSpacing: CGFloat = 10
    private var cellHeight: CGFloat = 70.0
    private var cellWidth: CGFloat = 300.0
    private var totalSpacingWidth: CGFloat = 20.0
    
    private var layoutType: FlowLayoutType = .singleRow(direction: .vertical)
    
    private var deletingIndexPaths = [IndexPath]()
    private var insertingIndexPaths = [IndexPath]()
    
    public init(type: FlowLayoutType, cHeight: CGFloat, cWidth: CGFloat) {
        super.init()
        cellHeight = cHeight
        cellWidth = cWidth
        layoutType = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        
        switch layoutType {
        case .singleRow(let direction):
            let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
            let maxNumColumns = Int(availableWidth / cellWidth)
            let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
            
            self.itemSize = CGSize(width: cellWidth, height: cellHeight)
            self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
            if #available(iOS 11.0, *) {
                self.sectionInsetReference = .fromSafeArea
            } else {
                // Fallback on earlier versions
            }
            self.scrollDirection = direction
            
        case .mosaic(let style, let direction):
//            let totalSpacingWidth = (self.cellSpacing * (cellCount - 1))
//            cellWidth = (collectionView.width / cellCount) - totalSpacingWidth
//            cellHeight = cellWidth * 0.8
//                        
//            let totalCellWidth = cellWidth * cellCount
//            let leftInset = (self.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//            let rightInset = leftInset

//            let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
//            let maxNumColumns = Int(availableWidth / cellWidth)
//            let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
            
            self.itemSize = CGSize(width: cellWidth, height: cellHeight)
            if #available(iOS 11.0, *) {
                self.sectionInsetReference = .fromSafeArea
            } else {
                // Fallback on earlier versions
            }
            self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
            self.scrollDirection = direction
        default: break
        }
        
    }
    
    private func calculateInteritemSpacing() {
    }
    
    private func calculateSetupValue() {
//        switch self.layoutType {
//        case .mosaic(let style, let direction):
//            if style == .fullWidth {
//                let totalSpacingWidth = 20
//                cellWidth = self.width - totalSpacingWidth
//                cellHeight = cellWidth * 0.5
//
//
//            } else {
//
//            }
//        }
    }


}

//
//  IMContactViewLayout.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/1/10.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class IMContactViewLayout: UICollectionViewFlowLayout {
    
    let ITEM_SIZE = CGSize(width: 90, height: 90)
    let STACK_OVERLAP = 45
    
    override init(){
        super.init()
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        self.itemSize = ITEM_SIZE
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = 0
        
    }
    
    // MARK: 重写collectionViewContentSize属性
    override var collectionViewContentSize: CGSize {
        let xSize = Double(self.collectionView?.numberOfItems(inSection: 0) ?? 0) * self.itemSize.width
        let ySize = Double(self.collectionView?.numberOfSections ?? 0) * self.itemSize.height
        
        var contentSize = CGSize(width: xSize, height: ySize)
        
        if self.collectionView?.bounds.size.width ?? 0 > contentSize.width {
            contentSize.width = self.collectionView?.bounds.size.width ?? 0
        }
        
        if self.collectionView?.bounds.size.height ?? 0 > contentSize.height {
            contentSize.height = self.collectionView?.bounds.size.height ?? 0
        }
        
        return contentSize
    }
    
    // MARK: 设置Cell的位置
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        return attributes
    }
    
    
    // MARK: 返回样式
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesArray = super.layoutAttributesForElements(in: rect)
        
        let numberOfItems = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        guard let attributesArray = attributesArray  else {
            return nil
        }
        let count = attributesArray.count
        let width = self.collectionView?.bounds.size.width ?? 0.0
        let spaceWidth = CGFloat(count) * self.itemSize.width - CGFloat(STACK_OVERLAP * (count - 1))
        var i: Int = 0
        var xPosition = (width - spaceWidth) / 2.0 + CGFloat(STACK_OVERLAP)
        for  attributes in attributesArray {
            //var xPosition = attributes.center.x
            var yPosition = attributes.center.y
            
            if (attributes.indexPath.row == 0) {
                attributes.zIndex = Int(INT_MAX); // Put the first cell on top of the stack
            } else {
                xPosition = xPosition + CGFloat(STACK_OVERLAP)
                attributes.zIndex = numberOfItems - attributes.indexPath.row //Other cells below the first one
            }
            
            attributes.center = CGPointMake(xPosition, yPosition)
        }
        
        return attributesArray;
    }
}

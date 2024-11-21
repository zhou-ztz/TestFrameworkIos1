//
//  SectionBgCollectionView.swift
//  Yippi
//
//  Created by ChuenWai on 17/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//
//  Referrence: https://www.hangge.com/blog/cache/detail_1844.html

import UIKit

//表示我们自定义的分区背景（装饰视图）
private let SectionBg = "SectionBgCollectionReusableView"

//增加自己的协议方法，使其可以像cell那样根据数据源来设置section背景色
protocol SectionBgCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor
}

//定义一个UICollectionViewLayoutAttributes子类作为section背景的布局属性，
//（在这里定义一个backgroundColor属性表示Section背景色）
private class SectionBgCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    //背景色
    var backgroundColor = UIColor.white

    //所定义属性的类型需要遵从 NSCopying 协议
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SectionBgCollectionViewLayoutAttributes
        copy.backgroundColor = self.backgroundColor
        return copy
    }

    //所定义属性的类型还要实现相等判断方法（isEqual）
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? SectionBgCollectionViewLayoutAttributes else {
            return false
        }

        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }
        return super.isEqual(object)
    }
}

//继承UICollectionReusableView来自定义一个装饰视图（Decoration 视图）,用来作为Section背景
private class SectionBgCollectionReusableView: UICollectionReusableView {
    //通过apply方法让自定义属性生效
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let attr = layoutAttributes as? SectionBgCollectionViewLayoutAttributes else {
                return
        }

        self.backgroundColor = attr.backgroundColor
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }
}

//自定义布局（继承系统内置的 Flow 布局）
class SectionBgCollectionViewLayout: UICollectionViewFlowLayout {

    //保存所有自定义的section背景的布局属性
    private var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    //初始化时进行一些注册操作
    func setup() {
        //注册我们自定义用来作为Section背景的 Decoration 视图
        self.register(SectionBgCollectionReusableView.classForCoder(), forDecorationViewOfKind: SectionBg)
    }

    //对一些布局的准备操作放在这里
    override func prepare() {
        super.prepare()
        //如果collectionView当前没有分区，或者未实现相关的代理则直接退出
        guard let numberOfSections = self.collectionView?.numberOfSections, let delegate = self.collectionView?.delegate as? SectionBgCollectionViewDelegate else {
            return
        }

        //先删除原来的section背景的布局属性
        self.decorationViewAttrs.removeAll()

        //分别计算每个section背景的布局属性
        for section in 0..<numberOfSections {
            //获取该section下第一个，以及最后一个item的布局属性
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection: section), numberOfItems > 0, let firstItem = self.layoutAttributesForItem(at: IndexPath(item: 0, section: section)), let lastItem = self.layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                continue
        }

        //获取该section的内边距
        var sectionInset = self.sectionInset
        if let inset = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: section) {
            sectionInset = inset
        }
        //计算得到该section实际的位置
        var sectionFrame = firstItem.frame.union(lastItem.frame)
        sectionFrame.origin.x = 0
        sectionFrame.origin.y -= sectionInset.top

        //计算得到该section实际的尺寸
        if self.scrollDirection == .horizontal {
            sectionFrame.size.width += sectionInset.left + sectionInset.right
            sectionFrame.size.height = self.collectionView!.frame.height
        } else {
            sectionFrame.size.width = self.collectionView!.frame.width
            sectionFrame.size.height += sectionInset.top + sectionInset.bottom
        }

        //更具上面的结果计算section背景的布局属性
        let attr = SectionBgCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBg, with: IndexPath(item: 0, section: section))
        attr.frame = sectionFrame
        attr.zIndex = -1
        //通过代理方法获取该section背景使用的颜色
        attr.backgroundColor = delegate.collectionView(self.collectionView!, layout: self, backgroundColorForSectionAt: section)

        //将该section背景的布局属性保存起来
        self.decorationViewAttrs.append(attr)
    }
}

    //返回rect范围下所有元素的布局属性（这里我们将自定义的section背景视图的布局属性也一起返回）
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            var attrs = super.layoutAttributesForElements(in: rect)
            attrs?.append(contentsOf: self.decorationViewAttrs.filter {
                return rect.intersects($0.frame)
            })
            return attrs
    }

    //返回对应于indexPath的位置的Decoration视图的布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //如果是我们自定义的Decoration视图（section背景），则返回它的布局属性
        if elementKind == SectionBg {
            return self.decorationViewAttrs[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind,
                                                       at: indexPath)
    }
}

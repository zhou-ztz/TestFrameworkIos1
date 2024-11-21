//
//  StickerCollectionCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit


protocol StickerCollectionCellDelegate: class {
    func stickerCellDidSelect(sticker: Sticker)
}

class StickerCollectionCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var collectionView: UICollectionView!
    private var stickers: [Sticker] = []
    private var row: Int = 1
    private weak var delegate: StickerCollectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(StickerCollectionItemCell.nib(), forCellWithReuseIdentifier: StickerCollectionItemCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        collectionView.setCollectionViewLayout(layout, animated: true)
        

    }
    
    func configure(stickers: [Sticker], delegate: StickerCollectionCellDelegate?, row: Int) {
        self.stickers = stickers
        self.row = row
        self.delegate = delegate
        collectionView.reloadData()
    }
}

extension StickerCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionItemCell.cellIdentifier, for: indexPath) as! StickerCollectionItemCell
        cell.configure(stickers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.stickerCellDidSelect(sticker: stickers[indexPath.row])
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lay = collectionViewLayout as! UICollectionViewFlowLayout

        let heightPerItem = collectionView.frame.height / CGFloat(self.row) - lay.minimumInteritemSpacing
        
        return CGSize(width: 80, height: heightPerItem)
    }
}

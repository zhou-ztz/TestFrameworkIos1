//
//  StickerCreatorFootView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit


protocol StickerCreatorFooterDelegate: class {
    func showArtistInfoDidTapped()
}

class StickerCreatorFootView: UICollectionReusableView {

    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var indicator: UILabel!
    private weak var delegate: StickerCreatorFooterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicator.text = "Click to view Artist >"
        indicator.applyStyle(.regular(size: 12, color: AppTheme.lightGrey))
        artistName.applyStyle(.regular(size: 16, color: AppTheme.black))
        artistImage.roundCorner(artistImage.bounds.width / 2)
        artistImage.applyBorder(color: AppTheme.lightGrey, width: 1)
        artistImage.clipsToBounds = true
    }
    
    func configure(_ artist: Artist, delegate: StickerCreatorFooterDelegate) {
        self.delegate = delegate
        self.artistImage.sd_setImage(with: URL(string: artist.icon.orEmpty), completed: nil)
        self.artistName.text = artist.artistName
    }
    
    @IBAction func footerDidTapped(_ sender: Any) {
        self.delegate?.showArtistInfoDidTapped()
    }
}

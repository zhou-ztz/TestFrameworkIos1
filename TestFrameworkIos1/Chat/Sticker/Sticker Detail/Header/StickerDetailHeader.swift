//
//  StickerDetailHeader.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit


protocol StickerDetailHeaderDelegate: class {
    func downloadDidTapped()
    func removeDidTapped()
    func voteDidTapped()
    func rewardButtonDidTapped()
    func shareButtonDidTapped()
    func expandStickDescDidTapped()
    func showArtistInfoDidTapped()
    func openContestWeb(_ url: String)
}

class StickerDetailHeader: UICollectionReusableView, BaseCellProtocol {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var stickerName: UILabel!
    @IBOutlet weak var stickerDescription: UILabel!
    private var stickerDetail: StickerQuery.Data!
    private weak var delegate: StickerDetailHeaderDelegate?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gifIconView: UIImageView!
    @IBOutlet var clickExpandButton: UIButton!
    @IBOutlet var lblHeight: NSLayoutConstraint!
    @IBOutlet var userProfileLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    
    @IBOutlet var expandButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var tipsToExpandButtonConstraint: NSLayoutConstraint!

    private var totalTips = 0
    private var totalDownloads = 0
        
    override func awakeFromNib() {
        super.awakeFromNib()
        stickerName.applyStyle(.semibold(size: 16, color: .black))
        stickerName.adjustsFontSizeToFitWidth = true
        bannerImageView.contentMode = .scaleAspectFill
        stickerDescription.numberOfLines = 0
        stickerDescription.lineBreakMode = .byWordWrapping
        stickerDescription.applyStyle(.regular(size: 14, color: AppTheme.black))
        clickExpandButton.addTarget(self, action: #selector(clickExpandAction), for: .touchUpInside)
        clickExpandButton.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha:0.5)
        clickExpandButton.isHidden = true
        
        userProfileLabel.applyStyle(.regular(size: 14, color: AppTheme.aquaBlue))
        downloadLabel.applyStyle(.regular(size: 14, color: .black))
        tipsLabel.applyStyle(.regular(size: 14, color: .black))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(StickerDetailHeader.artistDidTapped))
        userProfileLabel.addGestureRecognizer(tap)
        userProfileLabel.isUserInteractionEnabled = true

    }

    func configure(stickerDetail: StickerQuery.Data, delegate: StickerDetailHeaderDelegate, isExpanded: Bool) {
        self.stickerDetail = stickerDetail
        self.delegate = delegate
        
        let sticker = stickerDetail.sticker
        let artistFragment = sticker?.artist?.fragments.artistInfo
        let bundleFragment = stickerDetail.sticker?.fragments.bundleInfo
        
        bannerImageView.sd_setImage(with: URL(string: (bundleFragment?.bannerUrl).orEmpty), placeholderImage: UIImage.set_image(named: "feed_placeholder"))
        stickerName.text = bundleFragment?.bundleName.orEmpty
        userProfileLabel.text = artistFragment?.artistName
        stickerDescription.text = bundleFragment?.description
        
        if let iconImage = sticker?.contest?.pageIcon, let url = sticker?.contest?.pageUrl {
            gifIconView.isHidden = false
            gifIconView.sd_setImage(with: URL(string: iconImage), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
            gifIconView.isUserInteractionEnabled = true
            gifIconView.addAction { [weak self] in
                self?.delegate?.openContestWeb(url)
            }
        } else {
            gifIconView.isHidden = true
        }
        lblHeight.constant = 90
        
        let height = getLabelHeight(text: (bundleFragment?.description).orEmpty, width: stickerDescription.frame.size.width, font: stickerDescription.font)
        if height > lblHeight.constant  {
            clickExpandButton.isHidden = false
            expandButtonTopConstraint.constant = 12.5
        } else {
            lblHeight.constant = height
            expandButtonTopConstraint.constant = -34.5
            clickExpandButton.isHidden = true
        }
        
        if !self.clickExpandButton.isHidden {
             if isExpanded {
                self.clickExpandButton.setImage(UIImage.set_image(named: "ic_arrow_up") , for: UIControl.State.normal)
                
                self.expandButtonTopConstraint.constant = 5
                self.lblHeight.constant = self.getLabelHeight(text: (bundleFragment?.description).orEmpty, width:  self.stickerDescription.frame.size.width, font: self.stickerDescription.font)
            }
            else {
                self.clickExpandButton.setImage(UIImage.set_image(named: "ic_arrow_down") , for: UIControl.State.normal)
                self.expandButtonTopConstraint.constant = 0 - self.clickExpandButton.height
                self.lblHeight.constant = 90
            }
        }
        
        
        self.clickExpandButton.layoutIfNeeded()
        self.tipsLabel.layoutIfNeeded()
        self.stickerDescription.layoutIfNeeded()
        requestNumberOfDownloadsAndYipps()
    }
    
    func getLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let stickerDescription = UILabel(frame: .zero)
        stickerDescription.frame.size.width = width
        stickerDescription.font = font
        stickerDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
        stickerDescription.numberOfLines = 0
        stickerDescription.text = text
        stickerDescription.sizeToFit()
        
        return stickerDescription.frame.size.height
    }
    
    func requestNumberOfDownloadsAndYipps () {
        let request = StickerRequestType(bundleId: (stickerDetail.sticker?.fragments.bundleInfo.bundleId).orEmpty)
        request.execute(
            onSuccess: { [weak self] (response) in
                guard let self = self , let items = response?.data else { return }

                self.totalTips = items.total_tips
                self.totalDownloads = items.total_downloads
                self.downloadLabel.text =
                    String(format: "sticker_gallery_total_downloads".localized, items.total_downloads.abbreviated)
                self.tipsLabel.text = String(format: "sticker_gallery_total_tips".localized, items.total_tips.abbreviated)
                
        }) { [weak self] (error) in
            guard let self = self else { return }
            self.downloadLabel.text =
                String(format: "sticker_gallery_total_downloads".localized, 0.abbreviated)
            self.tipsLabel.text = String(format: "sticker_gallery_total_tips".localized, 0.abbreviated)
        }
    }

    func updateTipsLabel() {
        self.totalTips += 1
        self.tipsLabel.text = String(format: "sticker_gallery_total_tips".localized, self.totalTips.abbreviated)
    }

    func updateDownloadLabel() {
        self.totalDownloads += 1
        self.downloadLabel.text = String(format: "sticker_gallery_total_downloads".localized, self.totalDownloads.abbreviated)
    }
    
    @IBAction func clickExpandAction(_ sender: Any) {
        self.delegate?.expandStickDescDidTapped()
    }

    @IBAction func rewardButtonDidTapped(_ sender: Any) {
        self.delegate?.rewardButtonDidTapped()
    }

    @IBAction func shareButtonDidTapped(_ sender: Any) {
        self.delegate?.shareButtonDidTapped()
    }
    
    @IBAction func actionButtonDidTapped(_ sender: Any) {
        if StickerManager.shared.isBundleDownloaded((stickerDetail.sticker?.fragments.bundleInfo.bundleId).orEmpty) {
            self.delegate?.removeDidTapped()
        } else {
            self.delegate?.downloadDidTapped()
        }
    }
    
    func voteDidTapped(_ sender: Any) {
        self.delegate?.voteDidTapped()
    }
    
    @objc func artistDidTapped(sender:UITapGestureRecognizer) {
        self.delegate?.showArtistInfoDidTapped()
    }
}

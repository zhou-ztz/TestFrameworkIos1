//
//  StickerTableCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 05/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit

import SDWebImage

protocol StickerTableCellDelegate: class {
    func stickerDidRemoved(id: String, sender: UIButton)
    func stickerDidDownload(id: String, sender: UIButton)
    func stickerDidPurchased(id: String, sender: UIButton)
}
class StickerTableCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var numberOfDownloads: UILabel!
    @IBOutlet weak var stickerImage: UIImageView!
    @IBOutlet weak var stickerName: UILabel!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var SOTDRightStackView: UIStackView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsIcon: UIImageView!
    @IBOutlet weak var separatorLine: UIView!
    
    private var sticker: Sticker?
    private var section: Int?
    private var bundleId: String?
    weak var delegate: StickerTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        numberLabel.makeHidden()
        stickerName.applyStyle(.bold(size: 14, color: .black))
        stickerImage.contentMode = .scaleAspectFit
    }

    func configureSticker(forSearch bundleId: String?, bundleIcon: String?, bundleName: String?, description: String?, delegate: StickerTableCellDelegate?) {
        self.delegate = delegate
        self.bundleId = bundleId

        stickerImage.sd_setImage(with: URL(string: bundleIcon.orEmpty), completed: nil)
        stickerName.text = bundleName
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = description

        if StickerManager.shared.isBundleDownloaded(bundleId.orEmpty) {
            actionButton.isHidden = true
            actionButton.applyStyle(.downloadSticker(image: nil))
        } else {
            actionButton.isHidden = false
            actionButton.applyStyle(.downloadSticker(image: UIImage.set_image(named: "ic_download")))
        }
    }
 
    func configureSticker(_ sticker: Sticker, delegate: StickerTableCellDelegate?) {
        self.sticker = sticker
        self.bundleId = sticker.bundleID?.stringValue
        self.delegate = delegate
        
        stickerImage.sd_setImage(with: URL(string: sticker.bundleIcon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        stickerName.text = sticker.bundleName
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = sticker.description
        
        if StickerManager.shared.isBundleDownloaded(sticker.bundleID.stringValue) {
            actionButton.isHidden = true
            actionButton.applyStyle(.downloadSticker(image: nil))
        } else {
            actionButton.isHidden = false
            actionButton.applyStyle(.downloadSticker(image: UIImage.set_image(named: "ic_download")))
        }
    }
    
    func configureStickerbyArtist(_ sticker: Sticker, delegate: StickerTableCellDelegate?) {
        self.sticker = sticker
        self.bundleId = sticker.bundleID?.stringValue
        self.delegate = delegate
        
        stickerImage.sd_setImage(with: URL(string: sticker.bundleIcon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        stickerName.text = sticker.bundleName
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = sticker.description
        
        if StickerManager.shared.isBundleDownloaded(sticker.bundleID.stringValue) {
            actionButton.isHidden = true
            actionButton.applyStyle(.downloadSticker(image: nil))
        } else {
            actionButton.isHidden = false
            actionButton.applyStyle(.downloadSticker(image: UIImage.set_image(named: "ic_download")))
        }
    }
    
    func configureArtist(_ sticker: Sticker, delegate: StickerTableCellDelegate?) {
        self.sticker = sticker
        self.bundleId = sticker.bundleID?.stringValue
        self.delegate = delegate
        
        stickerImage.sd_setImage(with: URL(string: sticker.icon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        stickerName.text = sticker.artistName
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = String(format: "text_total_sticker_set".localized, (sticker.stickerSet ?? sticker.stickers?.count ?? 0).stringValue)
        
        actionButton.setImage(UIImage.set_image(named: "ic_arrow_next"), for: .normal)
        actionButton.tintColor = .black
    }

    func configureArtist(forSearch icon: String?, artistName: String?, stickerCount: Int?, delegate: StickerTableCellDelegate?) {
        self.delegate = delegate

        stickerImage.sd_setImage(with: URL(string: icon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        stickerName.text = artistName
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = String(format: "text_total_sticker_set".localized, stickerCount.orZero.stringValue)
        actionButton.setImage(UIImage.set_image(named: "ic_arrow_next"), for: .normal)
        actionButton.tintColor = .black
    }
    
    
    func configureCategory(_ sticker: Sticker, delegate: StickerTableCellDelegate?) {
        self.sticker = sticker
        self.bundleId = sticker.bundleID?.stringValue
        self.delegate = delegate
        
        stickerImage.makeHidden()
        stickerName.text = sticker.name
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = String(format: "text_total_sticker_set".localized, (sticker.stickerSet ?? 0).stringValue)
        
        actionButton.setImage(UIImage.set_image(named: "ic_arrow_next"), for: .normal)
        actionButton.tintColor = .black
    }
    
    func configureSOTD(_ sticker: Sticker, row: Int, delegate: StickerTableCellDelegate?) {
        self.sticker = sticker
        self.bundleId = sticker.bundleID?.stringValue
        self.delegate = delegate
        
        stickerImage.sd_setImage(with: URL(string: sticker.bundleIcon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        stickerName.text = sticker.bundleName
        numberOfDownloads.makeVisible()
        numberOfDownloads.text = String(format: "text_sticker_total_download".localized, sticker.downloadCount.orZero.stringValue)
        
        if let totalPoints = sticker.todayStats?.totalPoints {
            downloadView.makeHidden()
            SOTDRightStackView.makeVisible()
            pointsLabel.text = "\(totalPoints)"
            pointsIcon.image = UIImage.set_image(named: "icStickerPoint")
        }
        
        numberLabel.makeVisible()
        numberLabel.text = "\(row + 1)"
    }
    
   
    func configureStickerArtist(sticker: Sticker, section: Int? = nil, row: Int? = nil, delegate: StickerTableCellDelegate?) {
        //self.sticker = sticker
        self.bundleId = sticker.bundleID?.stringValue
        self.section = section
        self.delegate = delegate
        
        stickerImage.sd_setImage(with: URL(string: sticker.bundleIcon.orEmpty), placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        stickerName.text = sticker.bundleName

        if let row = row {
            numberLabel.text = "\(row + 1)"
            numberLabel.textColor = row < 3 ? AppTheme.red : AppTheme.black
            numberLabel.makeVisible()
        }

        if StickerManager.shared.isBundleDownloaded(self.bundleId ?? "") {
            actionButton.isHidden = true
            actionButton.applyStyle(.downloadSticker(image: nil))
        } else {
            actionButton.isHidden = false
            actionButton.applyStyle(.downloadSticker(image: UIImage.set_image(named: "ic_download")))
        }
        // UIImage.set_image(named: "ic_delete_sticker")

        if let section = section {
            actionButton.tag = section
        }
        
        numberOfDownloads.isHidden = false
    }
    
    func configureCustomSticker() {
        stickerImage.image = UIImage.set_image(named: "ic_sticker_custom")
        stickerImage.contentMode = .center
        stickerName.text = "text_custom_sticker".localized
        actionButton.setImage(UIImage.set_image(named: "ic_arrow_next"), for: .normal)
        actionButton.tintColor = .black
        separatorLine.makeHidden()
    }
    
    func configureMySticker(sticker: GrphSticker, delegate: StickerTableCellDelegate?) {
        self.delegate = delegate
        bundleId = sticker.bundleId
        stickerImage.contentMode = .scaleAspectFit
        if let icon = URL(string: sticker.bundleIcon.orEmpty) {
            stickerImage.sd_setImage(with: icon, placeholderImage: UIImage.set_image(named: "rl_placeholder_icon"), completed: nil)
        } else {
            stickerImage.image = UIImage.set_image(named: "rl_placeholder_icon")
        }
        stickerName.text = sticker.bundleName
        actionButton.applyStyle(.deleteSticker(image: UIImage.set_image(named: "ic_delete_sticker")))
        actionButton.addTarget(self, action: #selector(removeStickerDidTapped(_:)), for: .touchUpInside)
        actionButton.tintColor = .black
        separatorLine.makeVisible()
    }
    
    @objc private func removeStickerDidTapped(_ sender: UIButton) {
        if let id = bundleId {
            self.delegate?.stickerDidRemoved(id: id, sender: sender)
        }
    }
    
    @IBAction func actionButtonDidTapped(_ sender: UIButton) {
        self.actionButton.isHidden = true
        self.activityIndicator.startAnimating()
        if let bundleId = bundleId {
            if StickerManager.shared.isBundleDownloaded(bundleId) {
                self.delegate?.stickerDidRemoved(id: bundleId, sender: sender)
            } else {
                self.delegate?.stickerDidDownload(id: bundleId, sender: sender)
            }
        }
    }
}

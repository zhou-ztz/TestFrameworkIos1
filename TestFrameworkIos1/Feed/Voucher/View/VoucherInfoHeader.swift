//
//  VoucherInfoHeader.swift
//  RewardsLink
//
//  Created by Eric Low on 30/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import FSPagerView
import AVFoundation

protocol VoucherInfoHeaderDelegate: AnyObject {
    func onTapAction(_ videoUrl: String?)
}

class VoucherInfoHeader: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var reminderTag: UIView!
    @IBOutlet weak var carouselIndexView: UIView!
    @IBOutlet weak var imgIndexLabel: UILabel!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rebateOuterView: UIView!
    @IBOutlet weak var rebateOffsetView: OffsetRebateView!
    @IBOutlet weak var voucherName: UILabel!
    @IBOutlet weak var voucherDescription: UILabel! {
        didSet {
            voucherDescription.textColor = UIColor(hex: "#737373")
        }
    }
    @IBOutlet weak var expiringView: UIView!
    @IBOutlet weak var expiringLabel: UILabel!
    
    var banners: [VoucherBannerContent] = []
    var delegate: VoucherInfoHeaderDelegate?
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var voucherButtonType: VoucherButtonType = .getVoucher {
        didSet {
            if voucherButtonType == .isExpiring || voucherButtonType == .expired {
                expiringView.isHidden = false
                stackViewTopConstraint.constant = 30
            } else {
                expiringView.isHidden = true
                stackViewTopConstraint.constant = 10
            }
            
            if voucherButtonType == .isExpiring {
                expiringView.backgroundColor = UIColor(hex: 0xFFB516)
                expiringLabel.text = "rw_expiring_soon".localized
                expiringLabel.textColor = UIColor(hex: 0x242424)
            } else if voucherButtonType == .expired {
                expiringView.backgroundColor = UIColor(hex: 0x8B8B8B)
                expiringLabel.text = "rw_expired".localized
                expiringLabel.textColor = .white
            } else {
                expiringLabel.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        voucherDescription.sizeToFit()
        layoutIfNeeded()
    }
    
    func setupUI() {
        Bundle.main.loadNibNamed(String(describing: VoucherInfoHeader.self), owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        reminderTag.layer.cornerRadius = reminderTag.bounds.height/2
        reminderTag.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        reminderTag.backgroundColor = UIColor(hex: 0xFFB516)
        
        carouselIndexView.layer.cornerRadius = carouselIndexView.bounds.height/2
        carouselIndexView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        carouselIndexView.backgroundColor = UIColor(hex: "#242424").withAlphaComponent(0.8)
        
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.removesInfiniteLoopForSingleItem = true
        pagerView.register(BannerCollectionViewCell.nib(), forCellWithReuseIdentifier: BannerCollectionViewCell.cellIdentifier)
    }
    
    func setVoucherDetail(_ detail: VoucherDetailsResponse) {        
        voucherName.text = detail.name ?? ""
        
        if let descriptionLong = detail.descriptionLong, !descriptionLong.isEmpty {
            voucherDescription.text = descriptionLong
        } else if let descriptionShort = detail.description, !descriptionShort.isEmpty {
            voucherDescription.text = descriptionShort
        }
        
        voucherDescription.sizeToFit()
        
        banners.removeAll()
        if let images = detail.imageURL, !images.isEmpty {
            banners.append(contentsOf: images.map({VoucherBannerContent(url: $0)}))
        } else {
            banners.append(VoucherBannerContent(url: detail.logoURL?.first))
        }
        
        /// Testing 
        //banners.insert(VoucherBannerContent(type: .video, url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"), at: 0)
        
        if let video = detail.videoURL {
            banners.insert(VoucherBannerContent(type: .video, url: video), at: 0)
        }
        
        if banners.count <= 1 {
            carouselIndexView.isHidden = true
            imgIndexLabel.text = ""
        } else {
            carouselIndexView.isHidden = false
            imgIndexLabel.text = "1/\(banners.count)"
        }
        
        if !banners.contains(where: { $0.type == .video }) {
            pagerView.automaticSlidingInterval = 3.0
            pagerView.isInfinite = true
        } else {
            pagerView.isInfinite = false
        }
        
        if let packages = detail.packages, !packages.isEmpty {
            rebateOuterView.isHidden = false
            rebateOffsetView.rebate = packages.first?.rebatePercentage
            rebateOffsetView.offset = packages.first?.offsetPercentage
        } else {
            rebateOuterView.isHidden = true
        }
        
        layoutIfNeeded()
        pagerView.reloadData()
    }
    
    func pauseVideo() {
        player.pause()
    }
    
    func resumeVideo(isBackToStart: Bool = false) {
        if isBackToStart {
            player.seek(to: CMTime.zero)
        }
        
        if pagerView.currentIndex == 0 && !player.isPlaying {
            player.play()
        }
    }
}

extension VoucherInfoHeader: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        imgIndexLabel.text = "\(index + 1)/\(banners.count)"
        
        if let cell = pagerView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.cellIdentifier, at: index) as? BannerCollectionViewCell, banners.count > 0 {
            if let banner = banners[safe: index] {
                if banner.type == .image {
                    player.pause()
                    
                    cell.setupImage(imageUrl: banner.url, isShared: false)
                    cell.backgroundColor = .clear
                } else {
                    if player.currentItem == nil {
                        if let videoUrl = banner.url, let url = URL(string: videoUrl) {
                            player = AVPlayer(url: url)
                            playerLayer = AVPlayerLayer(player: player)
                            let playerFrame = CGRect(x: 0, y: 30, width: cell.frame.width, height: cell.frame.height - 50)
                            playerLayer.frame = playerFrame
                            playerLayer.videoGravity = .resizeAspect
                            cell.layer.addSublayer(playerLayer)
                            player.play()
                        }
                    } else {
                        player.play()
                    }
                    
                    cell.backgroundColor = .black
                }
            }
            
            cell.imageView?.contentMode = .scaleAspectFit
            cell.layer.cornerRadius = 0
            cell.contentView.layer.shadowRadius = 0.0
            
            return cell
        }
        
        return FSPagerViewCell()
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        if let banner = banners[safe: index], banner.type == .video {
            self.delegate?.onTapAction(banner.url)
        }
    }
}


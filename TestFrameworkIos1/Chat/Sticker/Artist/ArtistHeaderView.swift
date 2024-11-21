//
//  ArtistHeaderView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 10/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit

import SDWebImage

public protocol ArtistHeaderViewDelegate : class {
    func viewMyMoments (uid:String)
    func updateHeader ()
}

class ArtistHeaderView: UITableViewHeaderFooterView, BaseCellProtocol {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistDescription: UILabel!
    @IBOutlet weak var sectionTitle: UILabel!
    
    @IBOutlet weak var artistImageView: AvatarView!
    
    @IBOutlet weak var viewMymomentsBtn: UIButton!
    
    @IBOutlet weak var tipsButton: UIButton!
    
    @IBOutlet weak var dropDownBtn: UIButton!
    
    weak var delegate : ArtistHeaderViewDelegate?
    
    var uid : String?
    
    var onTippingTap: EmptyClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artistImageView.backgroundColor = .clear

        sectionTitle.text = "sticker_collections_title".localized.uppercased()
        artistNameLabel.applyStyle(.bold(size: 15, color: AppTheme.black))
        artistDescription.applyStyle(.regular(size: 14, color: AppTheme.lightGrey))
        
        viewMymomentsBtn.setTitle("profile_view_my_moment".localized, for: .normal)
        
        tipsButton.layer.cornerRadius = tipsButton.width/2
        dropDownBtn.layer.cornerRadius = dropDownBtn.width/2
    }
    
    func configure(_ info: Artist) {
        configure(banner: info.banner.orEmpty, artistName: info.artistName.orEmpty, description: info.description.orEmpty, hideMoment: false, uid: "")
    }
    
    func configure(banner: String, artistName: String, description: String, hideMoment: Bool, uid: String) {
        let placeholderImage = UIImage.set_image(named:"feed_placeholder")
        imageView.sd_setImage(with: URL(string: banner), placeholderImage: placeholderImage, context: [.storeCacheType : SDImageCacheType.memory.rawValue])
        
        let trimmedArtistDescription = description.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        artistNameLabel.text = artistName
        artistDescription.text = trimmedArtistDescription
        self.viewMymomentsBtn.isHidden = hideMoment
        
        self.uid = uid
        
        TSUserNetworkingManager().getUserInfo([Int(uid)!]) { (info, model, error) in
            guard let artist = model?.first else {
                return
            }
            
            self.artistImageView.avatarInfo = artist.avatarInfo()
            self.dropDownBtn.isHidden = (self.countLabelLines(label: self.artistDescription ) == 1)
        }
    }
    
    func countLabelLines(label: UILabel) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = label.text! as NSString
        
        let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    
    @IBAction func expandBtn(_ sender: Any) {
        dropDownBtn.setImage(artistDescription.numberOfLines == 0 ? UIImage.set_image(named: "IMG_ico_detail_arrowdown") : UIImage.set_image(named: "IMG_ico_detail_arrowup"), for: .normal)
        artistDescription.numberOfLines =  artistDescription.numberOfLines == 0 ? 1 : 0
        delegate?.updateHeader()
        //self.layoutIfNeeded()
    }
    
    @IBAction func viewMyMoment(_ sender: Any) {
        guard let uid = uid else { return }
        delegate?.viewMyMoments(uid : uid)
    }
    @IBAction func tippingBtn(_ sender: Any) {
        self.onTippingTap?()
    }
}


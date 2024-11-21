//
//  StickerRowSectionView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class StickerNewStickerView: StickerSectionBaseView<StickerNewStickerCell> {
    
    override var flowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: 64)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return layout
    }
    
    override var collectionHeight: CGFloat {
        return 216
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

class StickerNewStickerCell: StickerSectionBaseCell {
    
    private let avatarImage: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private let stackview: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 4
    }
    
    private let nameLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 16, color: .black))
    }
    
    private let descLabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .darkGray))
    }
    
    private let mainStackview: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 12
    }

    private let downloadView: UIView = UIView()
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray).configure {
        $0.hidesWhenStopped = true
    }
    
    private let downloadButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "ic_download"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(mainStackview)
        mainStackview.addArrangedSubview(avatarImage)
        mainStackview.addArrangedSubview(stackview)
        mainStackview.addArrangedSubview(downloadView)
        downloadView.addSubViews([downloadButton, activityIndicator])
        downloadView.contentMode = .center
        
        mainStackview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.bottom.top.equalToSuperview()
        }
        
        avatarImage.snp.makeConstraints {
            $0.width.height.equalTo(56)
        }

        downloadView.snp.makeConstraints {
            $0.width.height.equalTo(31)
        }
        
        downloadButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }

        activityIndicator.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        stackview.addArrangedSubview(nameLabel)
        stackview.addArrangedSubview(descLabel)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setData(_ data: Sticker) {
        avatarImage.sd_setImage(with: URL(string: data.bundleIcon.orEmpty), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"), completed: nil)
        nameLabel.text = data.bundleName
        descLabel.text = data.description
        
        guard let bundleId = data.bundleID else {
            downloadButton.makeHidden()
            return
        }
        downloadButton.isHidden = StickerManager.shared.isBundleDownloaded(bundleId.stringValue)
        
        downloadButton.addAction { [weak self] in
            self?.downloadButton.makeHidden()
            self?.activityIndicator.startAnimating()
            self?.downloadView.isUserInteractionEnabled = false

            StickerManager.shared.downloadSticker(for: bundleId.stringValue) { [weak self] in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.downloadView.isUserInteractionEnabled = true
                }
            } onError: { [weak self] error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.downloadButton.makeVisible()
                    self?.downloadView.isUserInteractionEnabled = true
                }
            }
        }
        
    }
}

class StickerDownloadButton: UIButton {
    
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoading() {
        indicator.startAnimating()
        self.isUserInteractionEnabled = false
        self.alpha = 0.7
    }
    
    func hideLoading() {
        indicator.stopAnimating()
        self.isUserInteractionEnabled = true
        self.alpha = 1.0
    }
}

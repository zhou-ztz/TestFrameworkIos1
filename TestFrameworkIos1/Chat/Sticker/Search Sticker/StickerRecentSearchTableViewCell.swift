//
//  StickerRecentSearchTableViewCell.swift
//  Yippi
//
//  Created by ChuenWai on 23/02/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class StickerRecentSearchTableViewCell: UITableViewCell, BaseCellProtocol {

    private let mainStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
    }
    private let historyIconImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel().configure {
        $0.setFontSize(with: 15, weight: .norm)
    }
    let removeHistoryImageView: UIImageView = UIImageView()
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    var onDataReload: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        historyIconImageView.image = UIImage.set_image(named: "icHistory")
        historyIconImageView.contentMode = .center
        removeHistoryImageView.image = UIImage.set_image(named: "IMG_ico_search_delete")
        removeHistoryImageView.contentMode = .center

        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(historyIconImageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(removeHistoryImageView)

        mainStackView.bindToEdges()
        historyIconImageView.snp.makeConstraints {
            $0.width.equalTo(historyIconImageView.snp.height)
        }
        removeHistoryImageView.snp.makeConstraints {
            $0.width.equalTo(historyIconImageView.snp.height)
        }

        removeHistoryImageView.addAction { [weak self] in
            guard let self = self else { return }
            self.onDataReload?(self.title.orEmpty)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ keyword: String) {
        title = keyword
    }
}

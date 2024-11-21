//
//  LiveScoreResultView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 10/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

enum LiveType {
    case starOfTheDay
    case event
    
    var pusherEventName: String {
        switch self {
        case .starOfTheDay: return "score-update"
        case .event: return "sq-score-update"
        }
    }
    
    var pusherChannel: String {
        switch self {
        case .starOfTheDay: return "score-update"
        case .event: return "sq-score-update"
        }
    }
}

enum ScoreResultViewType {
    case live
    case sticker
}

enum LiveScoreResultType {
    case ranked
    case notRanked
    case noResult
}

class LiveScoreResultView: UIView {

    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultStackview: UIStackView!
    @IBOutlet weak var goToLiveButton: UIButton!
    @IBOutlet weak var unrankedMessageLabel: UILabel!
    lazy var audienceView: LiveScoreResultRowView = {
        if self.from == .sticker {
            return LiveScoreResultRowView(image: UIImage.set_image(named: "ic_star_result_audience"), title: "text_downloader".localized, desc: "text_sticker_downloader_info".localized, amount: (0).abbStartFrom5Digit)
        }
        return LiveScoreResultRowView(image: UIImage.set_image(named: "ic_star_result_audience"), title: "text_unique_audience".localized, desc: "text_unique_audience_info".localized,
        amount: (0).abbStartFrom5Digit)
    }()
    lazy var totalTipsView: LiveScoreResultRowView = {
        if self.from == .sticker {
            return LiveScoreResultRowView(image: UIImage.set_image(named: "ic_total_tips"), title: "text_total_tips".localized, desc: "text_sotd_total_tips_info".localized, amount: Int(0).abbStartFrom5Digit)
        }
        return LiveScoreResultRowView(image: UIImage.set_image(named: "ic_total_tips"), title: "text_total_tips".localized, desc: "text_total_tips_info".localized,
        amount: Int(0).abbStartFrom5Digit)
    }()
    lazy var starPointView: LiveScoreResultRowView = {
        var liveRow = LiveScoreResultRowView(image: UIImage.set_image(named: "ic_pk"), title: "text_total_star".localized, desc: nil,
        amount: Int(0).abbStartFrom5Digit)

        liveRow.iconView.snp.remakeConstraints { (make) in
            make.width.equalTo(18)
            make.height.equalTo(19)
        }
        
        if self.from == .sticker {
            liveRow = LiveScoreResultRowView(image: UIImage.set_image(named: "icStickerPoint"), title: "text_total_points".localized, desc: nil, amount: Int(0).abbStartFrom5Digit)
            return liveRow
        }
        return liveRow
    }()
    private var from: ScoreResultViewType = .live
    
    init(from: ScoreResultViewType, type: LiveScoreResultType, views: Int = 0, tips: Int = 0, score: Int = 0, isButtonHidden: Bool = true, liveType: LiveType = .starOfTheDay, iconUrlString: String = "") {
        self.from = from

        super.init(frame: .zero)
        commonInit()

        audienceView.updateAmount(views)
        totalTipsView.updateAmount(tips)
        starPointView.updateAmount(score)
        
        switch liveType {
        case .event:
            starPointView.updateIcon(iconUrlString)
        default: break
        }
        
        goToLiveButton.isHidden = isButtonHidden

        switch type {
        case .ranked:
            unrankedMessageLabel.isHidden = true
        case .notRanked:
            unrankedMessageLabel.isHidden = true
        case .noResult:
            titleLabel.text = "live_slot_unrank_status_title".localized
            unrankedMessageLabel.isHidden = false
            resultStackview.isHidden = true
            resultView.backgroundColor = .clear
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("LiveScoreResultView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        unrankedMessageLabel.applyStyle(.bold(size: 12, color: .gray))
        unrankedMessageLabel.text = "live_slot_unrank_status_label".localized
        unrankedMessageLabel.sizeToFit()
                
        resultStackview.addArrangedSubview(audienceView)
        resultStackview.addArrangedSubview(totalTipsView)
        resultStackview.addArrangedSubview(starPointView)

        titleLabel.applyStyle(.bold(size: 14, color: .black))
        titleLabel.text = "text_result".localized
        
        resultView.roundCorner(8)
        resultView.backgroundColor = AppTheme.primaryLightGreyColor
        
        goToLiveButton.applyStyle(.custom(text: "text_go_streamer_room".localized, textColor: .white, backgroundColor: TSColor.main.theme, cornerRadius: 18))
        goToLiveButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        
    }
}

class LiveScoreResultRowView: UIView {
    
    private let stackview: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .top
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    let iconView: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    private let titleLabel: UILabel = UILabel().configure {
        $0.applyStyle(.bold(size: 12, color: .black))
    }
    private let descLabel: UILabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 10, color: UIColor(hex: 0x888888)))
    }
    var amountLabel: UILabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 12, color: .black))
        $0.textAlignment = .right
    }
    
    init(image: UIImage?, title: String, desc: String? = nil, amount: String) {
        super.init(frame: .zero)
        
        self.addSubview(stackview)
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(iconView)
        iconView.snp.makeConstraints {
            $0.width.equalTo(20)
        }
        let titleStackview = UIStackView().configure {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .fill
            $0.spacing = 5
        }
        titleStackview.addArrangedSubview(titleLabel)
        titleStackview.addArrangedSubview(descLabel)

        stackview.addArrangedSubview(titleStackview)
        stackview.addArrangedSubview(amountLabel)

        amountLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(40)
        }
        amountLabel.horizontalCompressionResistancePriority = .defaultHigh
        
        iconView.image = image
        titleLabel.text = title
        descLabel.text = desc
        amountLabel.text = amount
    }
    
    func updateAmount(_ amount: Int) {
        amountLabel.text = Int(amount).abbStartFrom5Digit
    }
    
    func updateIcon(_ urlString: String) {
        let url = URL(string: urlString)
        iconView.sd_setImage(with: url, completed: nil)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

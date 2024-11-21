//
//  HallofFameDetailVC.swift
//  Yippi
//
//  Created by ChuenWai on 17/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import SDWebImage
import SnapKit

class HallofFameDetailVC: TSViewController {
    let backgroundView: UIImageView = UIImageView()
    private let iconImageView: UIImageView = UIImageView()
    private let achievementLabel: UILabel = UILabel()
    private let titleLabel: UILabel = UILabel()
    private let descLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()
    private let backBtn: UIButton = UIButton(type: .custom)
    private let progressLabel: UILabel = UILabel()
    private let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())

    private var info: BadgeDetail
    
    private let cellWidthForArrow = 16
    private let cellWidthForMedal = 28
    
    private var scrollBar = UIView()
    private var scrollIndicator = UIView()

    init(info: BadgeDetail) {
        self.info = info

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(MedalRankCell.self, forCellWithReuseIdentifier: MedalRankCell.identifier)
        self.collectionView.delegate = self
        addSubViews()
        configureViews()
        setViewsData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fadeInImage()
        checkToHideScrollBar()
    }
        
    private func fadeInImage() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.achievementLabel.alpha = 1.0
            self.iconImageView.alpha = 1.0
            self.titleLabel.alpha = 1.0
            self.descLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            
            self.progressLabel.alpha = 1.0
            self.collectionView.alpha = 1.0
            self.scrollBar.alpha = 1.0
            self.scrollIndicator.alpha = 1.0
        }, completion: nil)
    }
    
    private func checkToHideScrollBar () {
        if info.multirank == 1 {
            let cellCount: CGFloat = CGFloat(info.medalrank.count) * CGFloat(2)
            
            let cellWidth1: CGFloat = CGFloat(cellWidthForArrow) * ((cellCount / CGFloat(2) + CGFloat(1)))
            let cellWidth2: CGFloat = CGFloat(cellWidthForMedal) * cellCount / CGFloat(2)
            
            let totalCellWidth: CGFloat = cellWidth1 + cellWidth2
            let totalSpacingWidth = (cellCount - CGFloat(1))
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            
            scrollBar.isHidden = collectionView.contentSize.width-leftInset*2 < self.view.width
            scrollIndicator.isHidden = collectionView.contentSize.width-leftInset*2 < self.view.width
            
            for (row,medal) in info.medalrank.enumerated() {
                if medal.achieved == 0 {
                    self.collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .left, animated: false)
                    return
                }
            }
        }
    }
    
    private func addSubViews() {
        self.view.addSubview(backgroundView)
        self.backgroundView.addSubview(achievementLabel)
        self.backgroundView.addSubview(iconImageView)
        self.backgroundView.addSubview(titleLabel)
        self.backgroundView.addSubview(descLabel)
        self.backgroundView.addSubview(infoLabel)
        self.backgroundView.addSubview(backBtn)
        self.backgroundView.addSubview(collectionView)
        self.backgroundView.addSubview(progressLabel)
        self.backgroundView.addSubview(scrollBar)
        self.scrollBar.addSubview(scrollIndicator)
    }

    private func configureViews() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        achievementLabel.snp.makeConstraints {
            $0.centerX.equalTo(backgroundView.snp.centerX)
            $0.bottom.equalToSuperview().offset(-(self.view.height * 0.85))
        }
         
        achievementLabel.alpha = 0.0
        
        iconImageView.snp.makeConstraints {
            $0.centerX.equalTo(backgroundView.snp.centerX)
            $0.width.height.equalTo(self.view.width * 0.4)
            $0.top.equalTo(achievementLabel.snp.bottom).multipliedBy(1.5)
        }
        iconImageView.alpha = 0.0

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).multipliedBy(1.15)
            $0.left.right.equalToSuperview().inset(50)
        }
        titleLabel.alpha = 0.0

        descLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(50)
            $0.top.equalTo(titleLabel.snp.bottom).multipliedBy(1.1)
        }
        descLabel.alpha = 0.0

        infoLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(50)
            $0.bottom.equalToSuperview().inset(50)
        }
        infoLabel.alpha = 0.0
        
        backBtn.snp.makeConstraints {
            $0.left.equalToSuperview().inset(7)
            if #available(iOS 11.0, *) {
                $0.top.equalTo(self.view.safeAreaInsets.top).inset(25)
            } else {
                $0.top.equalToSuperview().inset(10)
            }
            $0.width.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(45)
            $0.bottom.equalTo(infoLabel.snp.top).offset(-42)
            $0.left.right.equalToSuperview().inset(0)
        }
        
        collectionView.alpha = 0.0
        
        scrollBar.snp.makeConstraints {
            $0.centerX.equalTo(backgroundView.snp.centerX)
            $0.height.equalTo(2.5)
            $0.width.equalTo(26)
            $0.top.equalTo(collectionView.snp.bottom).offset(8)
        }
        
        scrollBar.alpha = 0.0
        
        scrollIndicator.snp.makeConstraints {
            $0.width.equalTo(13)
            $0.height.equalTo(2.5)
            $0.top.bottom.equalToSuperview()
        }
        
        scrollIndicator.alpha = 0.0
        
        progressLabel.snp.makeConstraints {
            $0.bottom.equalTo(collectionView.snp.top).offset(-20)
            $0.left.right.equalToSuperview().inset(50)
        }

        progressLabel.alpha = 0.0
        
    }
    
    private func setViewsData() {
        self.view.isUserInteractionEnabled = true
        self.backgroundView.isUserInteractionEnabled = true
        backgroundView.contentMode = .scaleAspectFill

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.sd_setImage(with: URL(string: info.detailBadgeIconUrl ?? ""), placeholderImage: UIImage.set_image(named: "ic__badge_comin_soon_big"), completed: nil)

        
        titleLabel.applyStyle(.bold(size: 17, color: AppTheme.white))
        titleLabel.text = info.badgeTitle
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.center
        
        configureLabel(label: descLabel, size: TSFont.SubText.subContent.rawValue, text: info.badgeDesc)
        configureLabel(label: infoLabel, size: TSFont.SubInfo.mini.rawValue, text: info.detailBadgeInfo)

        if info.multirank == 1 && info.medalrank.count > 1 {
            let maximumCount = info.medalrank[0].maximumCount
            let currentCount = info.medalrank[0].currentCount
            let achieved = info.medalrank[0].achieved
            var achievedDate = info.medalrank[0].achievedDate
            
            achievedDate = convertDate(dateString: achievedDate)
            
            configureLabel(label: progressLabel, size: TSFont.SubInfo.statisticsNumberOfWords.rawValue, text: achieved == 1 ? String(format: "achievement_achieved_date".localized, achievedDate) : String(format: "achievement_current_progress".localized, String(currentCount ?? 0) ,String(maximumCount ?? 0)))
        }
        
        achievementLabel.textAlignment = NSTextAlignment.center
        achievementLabel.numberOfLines = 0
        achievementLabel.applyStyle(.bold(size: 17, color: AppTheme.white))
        achievementLabel.text = info.medalrank[0].achieved == 1 ? "achievement_complete".localized : "next_achievement".localized
        
        
        backBtn.contentMode = .scaleAspectFill
        backBtn.setImage(UIImage.set_image(named: "ic_close_shadow"), for: .normal)
        backBtn.addTap { [weak self] (_) in
            guard let self = self else { return }
            self.dismiss()
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.indicatorStyle = .white
        collectionView.showsHorizontalScrollIndicator = false

        scrollBar.backgroundColor = .darkGray
        scrollBar.roundCorner(2)
        scrollIndicator.backgroundColor = AppTheme.red
                
        checkMultiRank()

    }

    private func configureLabel(label: UILabel, size: CGFloat, text: String) {
        label.applyStyle(.regular(size: size, color: AppTheme.white))
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text = text
    }
    
    private func checkMultiRank () {
        if info.multirank != 1 {
            collectionView.isHidden = true
            progressLabel.isHidden = true
            scrollBar.isHidden = true
            scrollIndicator.isHidden = true
        }
    }
    
    private func onClickMedalRank (row: Int) {
        if info.medalrank.count > row {
            if let badgeIcon = info.medalrank[row].badgeIcon {
                iconImageView.sd_setImage(with: URL(string: badgeIcon), placeholderImage: UIImage.set_image(named: "ic__badge_comin_soon_big"), completed: nil)
            }
            titleLabel.text = info.medalrank[row].title
            configureLabel(label: descLabel, size: TSFont.SubText.subContent.rawValue, text: info.medalrank[row].medalRankDescription)
            achievementLabel.applyStyle(.bold(size: 17, color: AppTheme.white))
            achievementLabel.text = info.medalrank[row].achieved == 1 ? "achievement_complete".localized : "next_achievement".localized
            
            let minimumCount = info.medalrank[row].minimumCount
            let currentCount = info.medalrank[row].currentCount
            let achieved = info.medalrank[row].achieved
            var achievedDate = info.medalrank[row].achievedDate
           
            achievedDate = convertDate(dateString: achievedDate)

            configureLabel(label: progressLabel, size: TSFont.SubInfo.statisticsNumberOfWords.rawValue, text: achieved == 1 ? String(format: "achievement_achieved_date".localized, achievedDate) : String(format: "achievement_current_progress".localized, String(currentCount ?? 0) ,String(minimumCount ?? 0)))
        }
    }
    
    func convertDate (dateString: String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatterGet.date(from: dateString) {
            return dateFormatterPrint.string(from: date)
        }
        
        return ""
    }
    
    @objc func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollIndicator.left = (scrollView.contentOffset.x*100)/(scrollView.contentSize.width-scrollView.frame.size.width)/100*self.scrollBar.width/2
    }
}

extension HallofFameDetailVC : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (info.medalrank.count*2)-1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MedalRankCell.identifier, for: indexPath) as! MedalRankCell
        indexPath.row % 2 == 1 ? cell.makeArrow() : cell.loadMedal(icon: info.medalrank[indexPath.row/2].badgeIconSmall ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 { return }
        onClickMedalRank(row: indexPath.row/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row % 2 == 1 {
            return CGSize(width: cellWidthForArrow, height: cellWidthForMedal)
        }
        return CGSize(width: cellWidthForMedal, height: cellWidthForMedal)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let CellCount = (info.medalrank.count*2)
        let totalCellWidth = (cellWidthForArrow * ((CellCount/2)+1)) + (cellWidthForMedal * CellCount/2)
        let totalSpacingWidth = (CellCount - 1)
        
        if CGFloat(totalCellWidth) > collectionView.width {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}

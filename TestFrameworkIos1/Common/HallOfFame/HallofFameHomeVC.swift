//
//  HallofFameHomeVC.swift
//  Yippi
//
//  Created by ChuenWai on 13/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit


class HallofFameHomeVC: TSViewController {
    private var collectionView: UICollectionView!
    private var fameArray: [BadgeItem] = []
    private var userID: Int = 0
    private var fromLive: Bool = false
    private var eventItemIsEmpty = true

    init(userID: Int, fromLive: Bool) {
        self.userID = userID
        self.fromLive = fromLive

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if(self.fromLive == true) {
            setCloseButton(backImage: true)
        }
        configureCollectionView()
        fetchBadgeDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setCloseButton(backImage: true, titleStr: "achievement_list_page_title".localized)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func configureCollectionView() {
        self.view.backgroundColor = AppTheme.backgroundColor
        let flowlayout = SectionBgCollectionViewLayout()
        collectionView = TSCollectionView(frame: .zero, collectionViewLayout: flowlayout)
        collectionView.alpha = 0.0
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HallofFameCell.self, forCellWithReuseIdentifier: HallofFameCell.badgeIdentifier)
        collectionView.register(UINib(nibName: "HallofFameSectionHeaderView", bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HallofFameSectionHeaderView.sectionIdentifier)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints{
            if #available(iOS 11.0, *) {
                $0.right.left.equalTo(self.view.safeAreaInsets).inset(10)
                $0.bottom.greaterThanOrEqualTo(self.view.safeAreaInsets).inset(10)
                $0.top.equalTo(self.view.safeAreaInsets)
            } else {
                $0.right.left.equalToSuperview().inset(10)
                $0.bottom.greaterThanOrEqualTo(self.view).inset(10)
                $0.top.equalToSuperview()
            }
        }
    }

    private func fetchBadgeDetail() {
        let request = UserBadgeRequest(ID: userID)
        request.execute(onSuccess: { [weak self] (response) in
            guard let wself = self, let badges = response else {
                self?.show(placeholder: .network)
                return
            }
            wself.setFameData(data: badges)
        }) { (error) in
            if case let YPErrorType.carriesMessage(reason, _, _) = error {
                self.showError(message: reason)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func setFameData(data: UserBadgeResponse) {
        defer {
            self.collectionView.reloadData()
            self.fadeInFameView()
        }
        let eventItem = data.eventBadges
        let achievementItem = data.dailyBadges
        if eventItem.badgeDetail.count > 0 {
            eventItemIsEmpty = true
            fameArray.insert(eventItem, at: 0)
        }
        fameArray.append(achievementItem)
    }

    private func fadeInFameView() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.collectionView.alpha = 1.0
        }, completion: nil)
    }
}

extension HallofFameHomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SectionBgCollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fameArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 22, left: 8, bottom: 22, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fameArray[section].badgeDetail.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let iconSize = (self.collectionView.width - 20) / 4
        return CGSize(width: iconSize , height: iconSize + 25) //25 is reserved for label's height
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HallofFameCell.badgeIdentifier, for: indexPath) as! HallofFameCell
        let currentBadge = fameArray[indexPath.section].badgeDetail[indexPath.row]

        cell.setData(title: currentBadge.badgeTitle, icon: currentBadge.badgeIconUrl ?? "")

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentBadge = fameArray[indexPath.section].badgeDetail[indexPath.row]
        if(currentBadge.badgeStatus == .active) {
            navigateView(info: currentBadge)
        }
    }

    private func navigateView(info: BadgeDetail) {
        let vc = HallofFameDetailVC(info: info)
        vc.backgroundView.sd_setImage(with: URL(string: info.detailBadgeBackgroundUrl ?? ""), placeholderImage: nil, options: .highPriority) { (_, error, _, _) in
            if(error == nil) {
                self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HallofFameSectionHeaderView.sectionIdentifier, for: indexPath) as! HallofFameSectionHeaderView
        let currentBadge = fameArray[indexPath.section]

        sectionHeaderView.setTitle(title: String(format: currentBadge.lokaliseKey.localized, currentBadge.totalBadgeGet, currentBadge.totalBadgeCount))

        return sectionHeaderView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.width, height: 55)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return (section == 0 || section == 1) ? AppTheme.white : UIColor.clear
    }
}

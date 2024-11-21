//
//  TSLocationDetailVC.swift
//  Yippi
//
//  Created by Khoo on 01/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


class TSLocationDetailVC: TSViewController {
    let locationID: String
    let locationName: String

//    var locationResultList: TSLocationVC!
    var table = BaseFeedController()

    init(locationID: String, locationName:String) {
        self.locationID = locationID
        self.locationName = locationName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        locationResultList = TSLocationVC(frame: view.bounds, tableIdentifier: "location")
//        locationResultList.locationID = locationID
//
//        self.view.addSubview(locationResultList)
//
//        locationResultList.snp.makeConstraints { (make) in
//            make.topMargin.equalToSuperview()
//            make.leftMargin.equalToSuperview()
//            make.width.equalToSuperview()
//            make.height.equalToSuperview()
//        }
        addChild(table)
        table.parentVC = self
        table.didMove(toParent: self)
        self.view.addSubview(table.view)
        table.table.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        table.table.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.table.table.mj_header.beginRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createNavigationBarWithIcon()
    }

    @objc func refresh() {
        FeedListNetworkManager.getLocationFeeds(locationID: locationID, after: nil) { [weak self] (model: FeedListResultsModel?, message: String?, status: Bool) in
            guard let self = self else { return }
            let cellModels = (model?.feeds.compactMap { FeedListCellModel(feedListModel: $0) }) ?? []
            self.table.datasource = cellModels
            self.table.lastItemID = self.table.datasource.last?.idindex ?? 0
            self.table.table.reloadData()
            self.table.table.mj_header.endRefreshing()
            self.table.table.mj_footer.makeVisible()
            // By Kit Foong (Dismiss footer)
            self.table.table.mj_footer.endRefreshingWithNoMoreData()
        }
    }

    @objc func loadMore() {
        FeedListNetworkManager.getLocationFeeds(locationID: locationID, after: table.lastItemID) { [weak self] (model: FeedListResultsModel?, message: String?, status: Bool) in
            guard let self = self else { return }
            if model?.feeds.count == 0 {
                self.table.table.mj_footer.endRefreshingWithNoMoreData()
            } else {
                let cellModels = (model?.feeds.compactMap { FeedListCellModel(feedListModel: $0) }) ?? []
                self.table.datasource += cellModels
                self.table.lastItemID = self.table.datasource.last?.idindex ?? 0
                self.table.table.reloadData()
                self.table.table.mj_footer.endRefreshing()
            }
        }
    }

    func createNavigationBarWithIcon () {

        if self.navigationController == nil {
            return
        }

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(.white), for: .default)

        let navView = UIView()

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        label.text = locationName
        label.textAlignment = NSTextAlignment.center
        label.sizeToFit()

        if label.width > 150 {
            label.width = 150
        }

        label.height = 40
        label.center = navView.center

        let image = UIImageView()
        image.image = UIImage.set_image(named: "ic_location")
        let imageAspect = image.image!.size.width/image.image!.size.height
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: 25)
        image.center.y = label.center.y
        image.contentMode = UIView.ContentMode.scaleAspectFit

        navView.addSubview(label)
        navView.addSubview(image)

        navigationItem.titleView = navView

        navView.sizeToFit()

    }
}

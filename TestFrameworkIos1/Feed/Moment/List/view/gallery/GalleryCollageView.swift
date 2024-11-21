//
//  GalleryCollageView.swift
//  Yippi
//
//  Created by CC Teoh on 24/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Hero
import Foundation
import SDWebImage
import RealmSwift
import UIKit

class GalleryCollageViewController: TSViewController {
    
    weak var _navigator: UINavigationController?
    override var navigationController: UINavigationController? {
        if super.navigationController == nil {
            return _navigator
        }
        return super.navigationController
    }
    
    private var collectionView: GalleryCollageView = GalleryCollageView(spacing: 5.0, backgroundColor: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(10)
        }
        collectionView.loadData()
        
        collectionView.onShowError = { [weak self] error in
            self?.showError(message: error)
        }
        setSearchView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setSearchView(){
        let titleView = UIView()
        titleView.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
        titleView.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 72, height: 40)
        titleView.layer.masksToBounds = true
        titleView.layer.cornerRadius = 20
        
        let icon = UIImageView()
        icon.image = UIImage.set_image(named: "glyphsSearch")
        icon.isUserInteractionEnabled = true
        titleView.addSubview(icon)
        icon.frame = CGRect(x: 12, y: 12, width: 16, height: 16)
        
        let lab = UILabel().configure {
            $0.text = "search_placeholder".localized
            $0.textColor = UIColor(red: 157, green: 157, blue: 157)
            $0.font = UIFont.systemFont(ofSize: 14)
        }
        titleView.addSubview(lab)
        lab.frame = CGRect(x: 35, y: 10, width: 160, height: 20)
        self.navigationItem.titleView = titleView
        titleView.addAction {
//            let nav = TSNavigationController(rootViewController: GlobalSearchLandingViewController())
//            nav.setCloseButton(backImage: true)
//            self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//            self.navigationController?.pushViewController(GlobalSearchLandingViewController(), animated: true)
        }
    }
    
}

class GalleryCollageView: TSCollectionView {
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout().build { layout in
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
    }
    var trendingPhotos: [FeedListCellModel] = []
    let placeHolderView: UIView = UIView(bgColor: TSColor.inconspicuous.background)

    private var spacing: CGFloat = 1.0
    private var bgColor: UIColor = .black
    
    enum CellType {
        case normal
        case expanded
    }
    
    var onShowError: ((String) -> Void)?
    
    convenience init(spacing: CGFloat, backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.spacing = spacing
        self.bgColor = backgroundColor
    
        self.backgroundColor = bgColor
        self.layout.minimumLineSpacing = spacing
        self.layout.minimumInteritemSpacing = spacing
    }

    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        createCollectionView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createCollectionView() {
        mj_header = TSRefreshHeader(refreshingBlock: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.loadDataSource()
        })

        mj_footer = TSRefreshFooter(refreshingBlock: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.loadMoreDataSource()
        })
        backgroundColor = .white
        isUserInteractionEnabled = true
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        dataSource = self
        delegate = self
        register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    }
    
    func loadData() {
        //loadDataSource()
        mj_footer.isHidden = true
        self.mj_header.beginRefreshing()
    }
    
    public func loadDataSource() {
        
        FeedListNetworkManager.getTrendingPhotos(limit: 30, after: nil, completion: { [weak self] (data, status) in
            guard let weakSelf = self else {
                return
            }
            
            guard status == true else {
                weakSelf.mj_header.endRefreshing()
                weakSelf.onShowError?("network_is_not_available".localized)
                return
            }
            
            if data.isEmpty {
                weakSelf.show(placeholderView: .empty)
                weakSelf.trendingPhotos = []
            } else {
                weakSelf.removePlaceholderView()
                weakSelf.trendingPhotos = data
            }
            weakSelf.mj_footer.isHidden = false
            weakSelf.reloadData()
            weakSelf.mj_header.endRefreshing()
        })
    }

    private func loadMoreDataSource() {
        let after = self.trendingPhotos.last?.id["feedId"]
        mj_footer.isHidden = false

        FeedListNetworkManager.getTrendingPhotos(limit: 30, after: after, completion: { [weak self] (data, status) in

            guard let weakSelf = self else {
                return
            }

            guard status == true else {
                weakSelf.mj_footer.endRefreshingWithWeakNetwork()
                return
            }
            
            if data.isEmpty {
                weakSelf.mj_footer.endRefreshingWithNoMoreData()
            } else {
                weakSelf.removePlaceholderView()
                weakSelf.trendingPhotos.append(contentsOf: data)
                weakSelf.reloadData()
                weakSelf.mj_footer.endRefreshing()
            }
        })
    }

    func url(at index: Int) -> URL? {
        return URL(string: self.trendingPhotos[index].pictures.first?.url ?? "")
    }
}

extension GalleryCollageView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = trendingPhotos[indexPath.row]
        guard let feedId = data.id["feedId"] else { return }
        if data.feedType == .video {
            let detailVC = FeedInfoDetailViewController(feedId: feedId, isTapMore: false, onToolbarUpdated: nil)

            if #available(iOS 11, *) {
                parentViewController?.navigationController?.pushViewController(detailVC, animated: true)
            } else {
                parentViewController?.navigationController?.present(TSNavigationController(rootViewController: detailVC).fullScreenRepresentation, animated: true, completion: nil)
            }
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }

            parentViewController?.navigationController?.navigation(navigateType: .innerFeedSingle(feedId: feedId, placeholderImage: cell.imageView.image, transitionId: cell.transitionId, imageId: (data.pictures.first?.file).orZero))
        }

    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.trendingPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.imageView.sd_setImage(with: url(at: indexPath.row), placeholderImage: nil, options: [SDWebImageOptions.lowPriority,.decodeFirstFrameOnly], completed: nil)
        cell.playPlaceholderImageView.isHidden = self.trendingPhotos[indexPath.row].feedType == .video ? false : true
        switch self.trendingPhotos[indexPath.row].feedType {
        case .miniVideo:
            cell.typeIcon.isHidden = false
            cell.typeIcon.image = UIImage.set_image(named: "ic_feed_video_icon")
        case .picture:
            if self.trendingPhotos[indexPath.row].pictures.count > 1 {
                cell.typeIcon.isHidden = false
                cell.typeIcon.image = UIImage.set_image(named: "icGalleryMultiPhoto")
            } else {
                cell.typeIcon.isHidden = true
            }
        default:
            cell.typeIcon.isHidden = true
        }
        cell.imageView.hero.id = cell.transitionId
        return cell
    }
         
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         
         let noOfCellsInRow = 3

         let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
         let totalSpace = flowLayout.sectionInset.left
             + flowLayout.sectionInset.right
             + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

         let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

         return CGSize(width: size, height: size)
     }
    
}

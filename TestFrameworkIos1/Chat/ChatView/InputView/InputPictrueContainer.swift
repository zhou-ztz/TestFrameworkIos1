//
//  InputPictrueContainer.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/9.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import Photos

class InputPictrueContainer: UIView {
    
    let maxSelectCount = 9
    var photoArr: [PHAsset] = []
    var selectAssetArr: [PHAsset] = []
    lazy var collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout.init()
        let rect = CGRect(x: 0, y: 0, width: self.width, height: self.height - 44 - TSBottomSafeAreaHeight)
        collectionLayout.itemSize = CGSize(width: (self.width - 28) / 4.0, height: (self.width - 28) / 4.0)
        let col = UICollectionView(frame: rect, collectionViewLayout: collectionLayout)
        col.delegate = self
        col.dataSource = self
        col.backgroundColor = .white
        col.showsVerticalScrollIndicator = false
        col.register(UINib(nibName: InputPictrueContainerCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: InputPictrueContainerCell.cellIdentifier)
        return col
    }()

    var bottomView = UIView()
    var picBtn = UIButton()
    var sendBtn = UIButton()
    
    public typealias compliteHandler = (_ isSend: Bool,  _ isCamera: Bool, _ assets: [PHAsset]?, _ isFullImage: Bool) -> Void
    var callBackHandler: compliteHandler?
    init(frame: CGRect , callBackHandler: compliteHandler?) {
        super.init(frame: frame)
        self.callBackHandler = callBackHandler
        self.backgroundColor = .white
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPhotoAlbumAssets() {
        DispatchQueue.main.async {
            self.photoArr = self.getAllAlbumAndPHAsset()
            self.collectionView.reloadData()
        }
    }
    
    func setUpUI(){
        self.addSubview(self.collectionView)
        self.bottomView.backgroundColor = .white
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(44)
            make.bottom.equalTo(-TSBottomSafeAreaHeight)
        }
        
        bottomView.addSubview(picBtn)
        picBtn.setTitle("album".localized, for: .normal)
        picBtn.setTitleColor(UIColor(red: 59, green: 179, blue: 255), for: .normal)
        picBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        picBtn.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
            make.width.equalTo(60)
            make.height.equalToSuperview()
        }
        
        bottomView.addSubview(sendBtn)
        sendBtn.setTitle("send".localized, for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sendBtn.roundCorner(14)
        sendBtn.backgroundColor = UIColor(red: 59, green: 179, blue: 255)
        sendBtn.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.width.equalTo(53)
            make.height.equalTo(28)
            make.right.equalTo(-12)
        }
        sendBtn.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        picBtn.addTarget(self, action: #selector(picAction), for: .touchUpInside)
        sendBtn.isEnabled = false
        sendBtn.backgroundColor = .lightGray
    }
    
    @objc func picAction(){
        self.callBackHandler!(false, false, self.selectAssetArr, false)
    }
    
    //send
    @objc func sendAction(){
        if self.selectAssetArr.isEmpty {
            return
        }
 
        var arrIndex = [IndexPath]()
        for asset in selectAssetArr {
            if let index = self.photoArr.index(of: asset) {
                arrIndex.append(IndexPath(row: index + 1, section: 0))
            }
        }
        let arrs = self.selectAssetArr
        self.selectAssetArr.removeAll()
        self.collectionView.reloadItems(at: arrIndex)
        
        self.callBackHandler!(true, false, arrs, true)
    }
    
    func getAllPHAssetFromSysytem()->([PHAsset]){
        var arr:[PHAsset] = []
        let options = PHFetchOptions.init()
        let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(with: options)
        // 遍历，得到每一个图片资源asset，然后放到集合中
        assetsFetchResults.enumerateObjects { (asset, index, stop) in
            arr.append(asset)
        }
        
        print("\(arr.count)")
        return arr
    }
    
    
    func getAllAlbumAndPHAsset()->([PHAsset]){
        
        var arr: [PHAsset] = []
        let options = PHFetchOptions.init()
        
        let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: .smartAlbumUserLibrary, options: options)
        
        for i in 0 ..< smartAlbums.count {
            // 是否按创建时间排序
            let options = PHFetchOptions.init()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]//时间排序
            options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)//˙只选照片
            
            let collection:PHCollection  = smartAlbums[i];//得到一个相册,一个集合就是一个相册
            /**
             相册标题英文：
             Portrait、Long Exposure、Panoramas、Hidden、Recently Deleted、Live Photos、Videos、Animated、Recently Added、Slo-mo、Time-lapse、Bursts、Camera Roll、Screenshots、Favorites、Selfies
             */
            print("相册标题---%@",collection.localizedTitle as Any);
            
            //遍历获取相册
            
            if collection is PHAssetCollection {
                let assetCollection = collection as! PHAssetCollection
                //collection中的资源都统一使用PHFetchResult 对象封装起来。
                //得到PHFetchResult封装的图片资源集合
                let fetchResult:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)

                var assetArr: [PHAsset] = []
                if fetchResult.count > 0 {
                    //某个相册里面的所有PHAsset对象（PHAsset对象对应的是图片，需要通过方法请求到图片）
                    assetArr  = getAllPHAssetFromOneAlbum(assetCollection: assetCollection)
                    
                    arr.append(contentsOf: assetArr)
                }
//                if collection.localizedTitle == "相机胶卷" || collection.localizedTitle == "Camera Roll"{//相册的名字是相机交卷，这里面包含了所有的资源，包括照片、视频、gif。 注意相册名字中英文
//
//                }
            }
            
        }
        
        return arr
    }
    
    
    
    //获取一个相册里的所有图片的PHAsset对象
    func getAllPHAssetFromOneAlbum(assetCollection: PHAssetCollection)->([PHAsset]){
        // 存放所有图片对象
        var arr: [PHAsset] = []
        // 是否按创建时间排序
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                    ascending: false)]//时间排序
        options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)//˙只选照片
        // 获取所有图片资源对象
        let results: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        
        // 遍历，得到每一个图片资源asset，然后放到集合中
        results.enumerateObjects { (asset, index, stop) in
            print("\(asset)")
            arr.append(asset)
        }
        
        return arr
    }


}

extension InputPictrueContainer: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArr.count > 19 ? 20 : self.photoArr.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: InputPictrueContainerCell.cellIdentifier, for: indexPath) as! InputPictrueContainerCell
        cell.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
        cell.delegate = self
        if indexPath.item > 0 {
            let asset = self.photoArr[indexPath.row - 1]
            cell.setData(asset: asset, indexPath: indexPath)
            if self.selectAssetArr.index(of: asset) != nil{
                cell.selectBtn.isSelected = true
                
            }else{
                cell.selectBtn.isSelected = false
                //cell.selectBtn.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .normal)
            }
        }
        
        cell.camera.isHidden = indexPath.item > 0
        cell.icon.isHidden = indexPath.item == 0
        cell.selectBtn.isHidden = indexPath.item == 0
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //点击相机
        if indexPath.item == 0 {
            self.callBackHandler!(false, true, self.selectAssetArr, false)
        }else
        {
            let asset = self.photoArr[indexPath.row - 1]
            
            if let index = self.selectAssetArr.index(of: asset){
                if index < self.selectAssetArr.count  {
                    self.selectAssetArr.remove(at: index)
                }
                
            }else{
                if self.selectAssetArr.count < maxSelectCount{
                    self.selectAssetArr.append(asset)
                }
            }
            sendBtn.isEnabled = self.selectAssetArr.count > 0
            sendBtn.backgroundColor = self.selectAssetArr.count > 0 ? UIColor(red: 59, green: 179, blue: 255) : .lightGray
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    //    MARK: - 行最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    //    MARK: - 列最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension InputPictrueContainer: InputPictrueContainerCellDelegate {
    
    func didSelectItem(indexPath: IndexPath, isSelect: Bool) {
        let asset = self.photoArr[indexPath.row - 1]
        
        if let index = self.selectAssetArr.index(of: asset){
            if index < self.selectAssetArr.count  {
                self.selectAssetArr.remove(at: index)
            }
            
        }else{
            if self.selectAssetArr.count < maxSelectCount{
                self.selectAssetArr.append(asset)
            }
        }
        sendBtn.isEnabled = self.selectAssetArr.count > 0
        sendBtn.backgroundColor = self.selectAssetArr.count > 0 ? UIColor(red: 59, green: 179, blue: 255) : .lightGray
        self.collectionView.reloadItems(at: [indexPath])
    }
}

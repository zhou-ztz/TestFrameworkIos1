//
//  MediaPreviewController.swift
//  Yippi
//
//  Created by Khoo on 12/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import NIMSDK
enum MediaPreviewType : Int {
    case image
    case video
}

class MediaPreviewObject: NSObject {
    var objectId: String?
    var type: MediaPreviewType?
    var path: String?
    var thumbPath: String?
    var url: String?
    var thumbUrl: String?
    var displayName: String?
    var timestamp: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    var imageSize = CGSize.zero
    
    func isEqual(_ object: Any) -> Bool {
        let obj = object as? MediaPreviewObject
        return objectId == obj?.objectId
    }
}

class MediaPreviewViewHeader: UICollectionReusableView {
    let titleLabel: UILabel
    
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh(title: String) {
        self.titleLabel.text = title
        self.titleLabel.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.left = 10
        self.titleLabel.centerY = self.height * 0.5
    }
}

class MediaPreviewViewCell: UICollectionViewCell {
    let imageView: UIImageView?
    let durationLabel: UILabel?
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        durationLabel = UILabel(frame: .zero)
        durationLabel?.font = UIFont.systemFont(ofSize: 13)
        durationLabel?.textColor = UIColor(hexString: "#ffffff")
        durationLabel?.shadowColor = UIColor(hexString: "#000000")
        durationLabel?.shadowOffset = CGSize(width: 0.5, height: 0.5)
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView!)
        self.contentView.addSubview(durationLabel!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView!.frame = self.contentView.bounds
        let right:CGFloat = 5
        let bottom:CGFloat = 5
        self.durationLabel?.right = self.width - right
        self.durationLabel?.bottom = self.height - bottom
    }
    
    func refresh(object: MediaPreviewObject) {
        let previewImageCache = NSCache<AnyObject, AnyObject>()
        let placeHolderImage = UIImage.imageWithColor(.gray, cornerRadius: 0)
        let durationCache = NSCache<AnyObject, AnyObject>()
        
        
        self.imageView!.image = nil
        var image: UIImage? = previewImageCache.object(forKey: object.thumbPath as AnyObject) as? UIImage
        if image == nil && FileManager.default.fileExists(atPath: object.thumbPath!) {
            
            image = UIImage(contentsOfFile: object.thumbPath!)
            image = UIImage.sd_decodedImage(with: image)
            
            let cost = cacheCostForImage(image)
            previewImageCache.setObject(image as AnyObject, forKey: object.thumbPath! as AnyObject, cost: cost)
        }
        
        if image == nil && (object.thumbUrl != nil) {
            self.imageView?.sd_setImage(with: URL(string: object.thumbUrl!), placeholderImage: placeHolderImage, completed: nil)
        } else {
            self.imageView!.image = image
        }
        
        let originFrame = self.durationLabel!.frame
        if object.duration > 0 {
            if let duration = durationCache.object(forKey: object.thumbPath as AnyObject) as? String {
                let seconds = (object.duration+500)/1000
                let durationString = String(format: "%@2zd:%02zd", seconds.truncatingRemainder(dividingBy: 60), seconds.truncatingRemainder(dividingBy: 60))
                durationCache.setObject(duration as AnyObject, forKey: object.thumbPath as AnyObject)
                
                self.durationLabel?.text = durationString
            }
        } else {
            self.durationLabel?.text = nil
        }
        
        self.durationLabel?.sizeToFit()
        if originFrame == self.durationLabel!.frame {
            self.setNeedsLayout()
        }
    }
    
    func cacheCostForImage(_ image: UIImage?) -> Int {
        guard let image = image else { return 0 }
        return Int(image.size.height * image.size.width * image.scale * image.scale)
    }


}


class MediaPreviewViewController: TSViewController {
    var objects: [MediaPreviewObject]?
    var focusObject: MediaPreviewObject?
    var session: NIMSession?
    var collectionView: UICollectionView?
    var itemCountPerLine:CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0.0
    var minimumLineSpacing: CGFloat = 0.0
    
    var scrollToFocus: Bool = false
    var calendar: Calendar? = nil
    var titles: [String]?
    var contents: [String : Any]?
    
    init (objects: [MediaPreviewObject], focusObject: MediaPreviewObject, session: NIMSession) {
        
        self.objects = objects
        self.focusObject = focusObject
        self.session = session
        itemCountPerLine = 3
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        calendar = Calendar.current
        contents = [String : Any]()
        titles = [String]()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "pic_video".localized
        
        self.sort()
        
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.register(MediaPreviewViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView?.register(MediaPreviewViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        self.view.addSubview(self.collectionView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !scrollToFocus && self.objects?.count != nil {
            let indexPath = self.indexPath(object: self.focusObject!)
            
            // By Kit Foong (Fixed crash when collection view section is less than indexpath)
            if (indexPath.section < self.collectionView!.numberOfSections && indexPath.row < (self.collectionView?.numberOfItems(inSection: indexPath.section))!) {
                self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
                scrollToFocus = true
            }
        }
    }
    
    func objectAtIndex(indexPath: IndexPath) -> MediaPreviewObject {
        let key = "\(titles![indexPath.section])"
        let array = contents![key] as! [MediaPreviewObject]
        return array[indexPath.row]
    }
    
    func indexPath(object: MediaPreviewObject) -> IndexPath {
        let key = self.keyForPreviewObject(object: object)
        guard let array = contents![key] as? [MediaPreviewObject] else { return  IndexPath(row: 0, section: 0) }
        //let array = contents![key] as! [MediaPreviewObject]
        
        var section = titles!.index(of: key)!
        section = (section != NSNotFound ? section : 0)
        var row = array.firstIndex(of: object) ?? NSNotFound
        row = row != NSNotFound ? row : 0
        
        return IndexPath(row: row, section: section)
    }
    
    func keyForPreviewObject(object: MediaPreviewObject) -> String {
        let time = object.timestamp
        let date = Date(timeIntervalSince1970: time)
        let now = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year, .hour], from: date)
        let nowComponents = calendar.dateComponents([.day, .month, .year, .hour], from: now)
        
        var key = ""
        if dateComponents.year == nowComponents.year && dateComponents.month == nowComponents.month && dateComponents.weekOfMonth == nowComponents.weekOfMonth {
            key = "this_week".localized
        } else {
            key = String(format: "year_month".localized, dateComponents.year!,dateComponents.month!)
        }
        
        return key
    }
    
    func sort() {
        contents?.removeAll()
        titles?.removeAll()
        
        for (_, obj) in self.objects!.enumerated() {
            let object = obj
            let key = self.keyForPreviewObject(object: object)
            var array:[Any]? = contents![key] as? [Any]
            if array == nil {
                array = []
                contents![key] = array
                
                titles?.append(key)
            }
        
            array!.append(object)
            contents![key] = array
        }
    }
}


extension MediaPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing =  self.minimumInteritemSpacing * (self.itemCountPerLine - 1)
        let width = (collectionView.width - spacing) / self.itemCountPerLine
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 45)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titles?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let title = titles![section]
        let array = contents![title] as? [Any]
        
        return array!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MediaPreviewViewCell
        let object = self.objectAtIndex(indexPath: indexPath)
        cell.refresh(object: object)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let focusObject:MediaPreviewObject = self.objectAtIndex(indexPath: indexPath)
        
        let vc = MediaGalleryPageViewController(objects: self.objects!, focusObject: focusObject, session: self.session!, showMore: false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var resusableView = MediaPreviewViewHeader()
        if kind == UICollectionView.elementKindSectionHeader {
            resusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! MediaPreviewViewHeader
            let title = "\(titles![indexPath.section])"
            resusableView.refresh(title: title)
        }
        
        return resusableView
    }
}

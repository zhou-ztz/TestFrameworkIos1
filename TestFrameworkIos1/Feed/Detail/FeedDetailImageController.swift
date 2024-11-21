//
// Created by Francis Yeap on 10/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import FLAnimatedImage
import SDWebImage
import SDWebImageFLPlugin
import Hero

enum FeedDetailImageControllerState {
    case normal
    case zoomable
}

class FeedDetailImageController: TSViewController, UIGestureRecognizerDelegate {
    private let zoomView: ImageZoomView = ImageZoomView(frame: .zero)

    private(set) lazy var imageView = {
       return zoomView.imageView
    }()

    var state: FeedDetailImageControllerState = .normal
    private(set) var imageUrlPath: String = ""
    private(set) var imageIndex: Int = 0
    private(set) var model: FeedListCellModel?
    private let doubleTapGesture = UITapGestureRecognizer()
    private let singleTap = UITapGestureRecognizer()
    var onSingleTapView: EmptyClosure?
    var onDoubleTapView: EmptyClosure?
    var onZoomUpdate: EmptyClosure?

    init(imageUrlPath: String = "", imageIndex: Int, model: FeedListCellModel, placeholderImage: UIImage? = nil, transitionId: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.imageUrlPath = imageUrlPath
        self.imageIndex = imageIndex
        self.model = model
        self.hero.isEnabled = true
        if let transitionId = transitionId {
            self.imageView.hero.id = transitionId
        }

        let imageUrl = SDWebImageManager.shared.cacheKey(for: URL(string: imageUrlPath))
        if let imageData = SDImageCache.shared.diskImageData(forKey: imageUrl) {
            // Load image from cache
            let image = UIImage.sd_image(with: imageData)
            self.imageView.image = image
        } else {
            // Load image from URL
            self.imageView.sd_setImage(with: URL(string: imageUrlPath), placeholderImage:nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadGifUrlPath()
        
        view.backgroundColor = .black

        view.addSubview(zoomView)

        self.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)

        doubleTapGesture.delegate = self
        singleTap.delegate = self

        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        doubleTapGesture.addActionBlock { [weak self]_ in
            guard let self = self else { return }
            if case let self.state = FeedDetailImageControllerState.zoomable {
                self.zoomView.toggleZoom()
            } else {
                self.onDoubleTapView?()
            }
        }

        view.addGestureRecognizer(singleTap)
        singleTap.addActionBlock { [weak self] _ in
            self?.zoomView.resetZoom()
            self?.onSingleTapView?()
        }

        zoomView.onZoomUpdate = onZoomUpdate
        view.layoutIfNeeded()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        //开始记录停留时间
        stayBeginTimestamp = Date().timeStamp
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.behaviorUserFeedStayData()
    }
    func reloadGifUrlPath() {
//        guard let url = try? self.imageUrlPath.asURL() else { return }
//        let session = URLSession(configuration: .default)
//        let task = session.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            if let response = response as? HTTPURLResponse {
//                if let redirectUrl = response.url {
//                    print("Redirected URL: \(redirectUrl)")
//                    self.imageView.sd_setImage(with: redirectUrl, placeholderImage: nil, options: .highPriority)
//                }
//            }
//        }
//
//        task.resume()
        guard let url = try? self.imageUrlPath.asURL() else { return }
        let imageUrl = SDWebImageManager.shared.cacheKey(for: url)
        
        if let imageData = SDImageCache.shared.diskImageData(forKey: imageUrl) {
            // Load image from cache
            let image = UIImage.sd_image(with: imageData)
            self.imageView.image = image
        } else {
            // Load image from URL
            self.imageView.sd_setImage(with: url, placeholderImage:nil)
        }
        
    }
//    func setImage(with url: String?) {
//        guard let url = try? url.orEmpty.asURL() else { return }
////        imageView.yy_setImage(with: url, placeholder: nil)
//
//
////        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.progressiveLoad], context: [.imageThumbnailPixelSize: CGSize(width: 100, height: 100)], progress: nil, completed: nil, usingFailedURLCache: true, refreshCached: true, shouldDecodeImmediately: false, options: options)
//
//
//
//    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/preferring_one_gesture_over_another
        if gestureRecognizer == self.singleTap && otherGestureRecognizer == self.doubleTapGesture {
            return true
        }
        return false
    }
}


extension FeedDetailImageController {
    func behaviorUserFeedStayData() {
        if stayBeginTimestamp != "" {
            stayEndTimestamp = Date().timeStamp
            let stay = stayEndTimestamp.toInt()  - stayBeginTimestamp.toInt()
            if stay > 5 {
                self.stayBeginTimestamp = ""
                self.stayEndTimestamp = ""
                EventTrackingManager.instance.trackEvent(
                    itemId: self.model?.idindex.stringValue ?? "",
                    itemType: ItemType.shortvideo.rawValue,
                    behaviorType: BehaviorType.stay,
                    sceneId: "",
                    moduleId: ModuleId.feed.rawValue,
                    pageId: PageId.feed.rawValue,
                    behaviorValue: stay.stringValue
                )
            }
        }
    }
}

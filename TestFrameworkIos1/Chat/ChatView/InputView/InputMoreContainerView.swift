//
//  InputMoreContainerView.swift
//  Yippi
//
//  Created by Khoo on 16/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

let NIMMaxItemCountInPage = 8
let NIMButtonItemWidth = Int(ScreenSize.ScreenWidth / 4) //previous: 75
let NIMButtonItemHeight = 75 //previous: 85
let NIMPageRowCount = 2
let NIMPageColumnCount = 4
let NIMButtonBegintLeftX = 11
let pageControlHeight = 15

class InputMoreContainerView: UIView {
    var config: IMChatViewConfig? = IMChatViewConfig() {
        didSet {
            self.genMediaButtons()
            self.pageView?.reloadData()
        }
    }

    var actionDelegate: CustomInputBarDelegate?
    var pageView: PageView?
    var mediaButtons: [UIView]?
    var mediaItems: [MediaItem] = []
    var pageContrl = UIPageControl()
    
    override var frame: CGRect {
        didSet {
            let originalWidth = frame.size.width
            super.frame = frame
            if originalWidth != frame.size.width {
                pageView?.frame = bounds
                pageView?.reloadData()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        pageView = PageView(frame: bounds)
        pageView?.dataSource = self
        pageView?.pageViewDelegate = self
        backgroundColor = .white
        
        self.addSubview(pageView!)
        
        pageView?.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // For Testing Purpose, delete this after config file setup
        self.genMediaButtons()
        self.pageView?.reloadData()
        self.setupPageControl()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        pageView?.dataSource = nil
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 216)
    }
    
    func mediaPageView(_ pageView: PageView?, beginItem begin: Int, endItem end: Int) -> UIView? {
        let subView = UIView()
        let columnWidth:CGFloat = CGFloat(self.width - CGFloat(NIMPageColumnCount * NIMButtonItemWidth))
        let span =  columnWidth / CGFloat(NIMPageColumnCount + 1)
        let startY = CGFloat(NIMButtonBegintLeftX)
        var coloumnIndex = 0
        var rowIndex = 0
        var indexInPage = 0

        for index in begin..<end {
            let button = mediaButtons![index]
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchButton(_:)))
            button.addGestureRecognizer(tapGesture)

            //计算位置
            rowIndex = indexInPage / NIMPageColumnCount
            coloumnIndex = indexInPage % NIMPageColumnCount
            let indexInt = (NIMButtonItemWidth + Int(span)) * coloumnIndex
            let x = CGFloat(span + CGFloat(indexInt))
            var y: CGFloat = 0.0
            if rowIndex > 0 {
                y = CGFloat(Int(CGFloat(rowIndex * NIMButtonItemHeight) + startY) + 15)
            } else {
                y = CGFloat(CGFloat(rowIndex * NIMButtonItemHeight) + startY)
            }
            subView.addSubview(button)
           // button.frame = CGRect(x: x, y: y, width: CGFloat(NIMButtonItemWidth), height: CGFloat(NIMButtonItemHeight))
            button.snp.makeConstraints { (make) in
                make.left.equalTo(x)
                make.top.equalTo(y)
                make.width.equalTo(CGFloat(NIMButtonItemWidth))
                make.height.equalTo(CGFloat(NIMButtonItemHeight))
            }
            
            indexInPage += 1
        }
        
        return subView
    }
    
    func reloadMediaItems(removeVoice: Bool) {
        self.genMediaButtons(removeVoice: removeVoice)
        self.pageView?.reloadData()
    }
    
    func genMediaButtons(removeVoice: Bool = false) {
        var mediaButtons:[UIView]? = [UIView]()
        var mediaItems:[MediaItem]? = [MediaItem]()
        var items:[MediaItem] = []

        // Uncomment this when set from IM
//        if self.config == nil {
//            items = nil
//        } else {
//            items = self.config?.mediaItems
//        }
        
        items = self.config?.mediaItems() ?? []
        
        if removeVoice {
            items = items.filter { $0 != .voiceCall }
        }
        
        for (index,item) in items.enumerated() {
            mediaItems!.append(item)
            
            let stackView = UIStackView()
            stackView.tag = index
            stackView.axis = .vertical
            stackView.alignment = .center
            //stackView.distribution = .fill
            stackView.spacing = 6
            let image = UIImageView(image: item.info.icon)
            image.contentMode = .center
            image.backgroundColor = UIColor(hexString: "#F7F7F7")
            stackView.addArrangedSubview(image)
            let x = CGFloat(NIMButtonItemWidth - 57) / 2.0
            image.snp.makeConstraints {
                $0.width.height.equalTo(57)
                $0.leading.equalTo(x)
                $0.trailing.equalTo(-x)
            }
            
            image.frame = CGRect(x: x, y: 0, width: 57, height: 57)
            
            image.width = 57
            image.height = 57
            
            //image.circleCorner()
            image.roundCorner(8)
            let label = UILabel()
            label.text = item.info.title
            label.textColor = AppTheme.black
            label.font = UIFont.systemFont(ofSize: 10.0)
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
            mediaButtons!.append(stackView)
        }

        self.mediaButtons = mediaButtons
        self.mediaItems = mediaItems ?? []
    }
    
    func setupPageControl() {
        pageContrl.pageIndicatorTintColor = UIColor.gray
        pageContrl.currentPageIndicatorTintColor = TSColor.main.theme
        pageContrl.numberOfPages = numberOfPages(pageView)
        pageContrl.frame = CGRect(x: 0, y: 0, width: 120, height: pageControlHeight)
        
        self.addSubview(pageContrl)
        
        pageContrl.snp.makeConstraints {
            $0.top.equalTo(pageView!.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func oneLineMedia(inPageView: PageView?, viewInPage index: Int, count: Int) -> UIView? {
        let subView = UIView()
        let countWidth:CGFloat = CGFloat(count * Int(NIMButtonItemWidth))
        let width:CGFloat = CGFloat(self.width - countWidth)
        let span =  width / CGFloat(count + 1)
        
        for btnIndex in 0..<count {
            let button = mediaButtons![btnIndex]
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchButton(_:)))
            button.addGestureRecognizer(tapGesture)
            let x:CGFloat = CGFloat(span + (CGFloat(Int(NIMButtonItemWidth)) + span))
            let iconRect = CGRect(x: x * CGFloat(btnIndex), y: 58, width: CGFloat(NIMButtonItemWidth), height: CGFloat(NIMButtonItemHeight))
            button.frame = iconRect
            button.roundCorner(button.bounds.height/2)
            subView.addSubview(button)
        }
        return subView
    }

    // MARK: - button actions
    @objc func onTouchButton(_ sender: UITapGestureRecognizer?) {
        let index = sender?.view?.tag ?? 0
        let item = mediaItems[index]
        
        switch item {
        case .album: actionDelegate?.imageTapped?()
        case .camera: actionDelegate?.cameraTapped?()
        case .file: actionDelegate?.attachmentTapped?()
        case .redpacket: actionDelegate?.eggTapped?()
        case .videoCall: actionDelegate?.videoCallTapped?()
        case .voiceCall: actionDelegate?.voiceCallTapped?()
        case .sendCard: actionDelegate?.onContactTapped?()
        case .whiteBoard: actionDelegate?.onWhiteboardTapped?()
        case .sendLocation: actionDelegate?.onLocationTapped?()
        case .voiceToText: actionDelegate?.onVoiceToTextTapped?()
        case .rps: actionDelegate?.onRPSTapped?()
        case .collectMessage: actionDelegate?.oncollectionMessageTapped?()
        case .secretMessage: actionDelegate?.onSecretMessageTapped?()
        default: break
        }
    }
}

extension InputMoreContainerView: PageViewDataSource {
    // MARK: Page View Data Source
    func numberOfPages(_ pageView: PageView?) -> Int {
        var count = mediaItems.count / NIMMaxItemCountInPage
        count = mediaButtons!.count % NIMMaxItemCountInPage == 0 ? count : count + 1
        return max(count, 1)
    }

    func pageView(_ pageView: PageView?, viewInPage index: Int) -> UIView? {
        var index = index
        if mediaButtons!.count == 2 || mediaButtons!.count == 3 {
            return oneLineMedia(inPageView: pageView, viewInPage: index, count: mediaButtons!.count)
        }
        
        if index < 0 {
            index = 0
        }
        let begin = index * Int(NIMMaxItemCountInPage)
        var end = (index + 1) * Int(NIMMaxItemCountInPage)
        if end > mediaButtons!.count {
            end = mediaButtons!.count
        }
        return mediaPageView(pageView, beginItem: begin, endItem: end)
    }
}

extension InputMoreContainerView: PageViewDelegate {
    // MARK: Page View Delegate
    func pageViewDidScroll(_ pageView: PageView?) {
        self.pageContrl.currentPage = pageView?.currentPage ?? 0
    }
}


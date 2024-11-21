//
//  TSIMToolChoose.swift
//  Yippi
//
//  Created by Kit Foong on 27/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

// MARK: Public methods extensions

extension TSIMToolChoose {
    func dismissToolTips() {
        self.dismissWithAnimation()
    }
}

public extension UIView {
    @discardableResult
    func showIMToolChoose(identifier: String, data: [GroupIMActionItem], arrowPosition: TSIMToolChoose.ArrowPosition, preferences: ToolChoosePreferences = ToolChoosePreferences(), delegate: IMToolChooseDelegate? = nil, dismissCompletion: EmptyClosure? = nil) -> TSIMToolChoose {
        let tooltip = TSIMToolChoose(view: self, identifier: identifier, data: data, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate, dismissCompletion: dismissCompletion)
        tooltip.calculateBubbleSize()
        tooltip.calculateFrame()
        tooltip.show()
        TSRootViewController.share.toolTipIM = tooltip
        return tooltip
    }
}

public protocol IMToolChooseDelegate: class {
    func didSelectedItem(model: IMActionItem)
}

// MARK: TSIMToolChoose class implementation

public class TSIMToolChoose: UIView, UIGestureRecognizerDelegate {
    public enum ArrowPosition: Int {
        case top
        case right
        case bottom
        case left
        case topRight
        case topLeft
        case bottomLeft
        case bottomRight
        case topRightWithButtonHeight
        case none
    }
    
    // MARK: Variables
    
    public let controller = ToolTipViewController()
    
    private var arrowPosition: ArrowPosition = .top
    private var bubbleFrame: CGRect = .zero
    
    private var containerWindow: UIWindow?
    private weak var presentingView: UIView?
    
    private var id: String
    
    private weak var delegate: IMToolChooseDelegate?
    
    private var viewDidAppearDate: Date = Date()
    
    private var preferences: ToolChoosePreferences
    var data = [GroupIMActionItem]()
    let noOfCellsInRow = 4
    
    private var dismissCompletion: EmptyClosure?
    
    // MARK: Lazy variables
    private lazy var gradient: CGGradient = { [unowned self] in
        let colors = self.preferences.drawing.bubble.gradientColors.map { $0.cgColor } as CFArray
        let locations = self.preferences.drawing.bubble.gradientLocations
        return CGGradient(colorsSpace: nil, colors: colors, locations: locations)!
    }()
    
    private lazy var bubbleSize: CGSize = { [unowned self] in
        var height = min(preferences.drawing.rowHeight * CGFloat(data.count), preferences.drawing.rowHeight * CGFloat(preferences.drawing.rowMax))
        return CGSize(width: ScreenWidth * 0.85, height: height)
    }()
    
    private lazy var contentSize: CGSize = { [unowned self] in
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        switch self.arrowPosition {
        case .top, .bottom, .topRight, .topLeft, .bottomRight, .bottomLeft, .topRightWithButtonHeight, .none:
            height = self.preferences.drawing.arrow.size.height + self.bubbleSize.height
            width = self.bubbleSize.width
        case .right, .left:
            height = self.bubbleSize.height
            width = self.preferences.drawing.arrow.size.height + self.bubbleSize.width
        }
        
        return CGSize(width: width, height: height)
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(UINib(nibName: "TSChooseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TSChooseCollectionViewCell.cellIdentifier)
        collection.register(TSChooseFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TSChooseFooterView.cellIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
        collection.isUserInteractionEnabled = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    // MARK: Initializer
    init(view: UIView, identifier: String,  data: [GroupIMActionItem], arrowPosition: ArrowPosition, preferences: ToolChoosePreferences, delegate: IMToolChooseDelegate? = nil, dismissCompletion: EmptyClosure? = nil) {
        self.presentingView = view
        self.id = identifier
        self.data = data
        self.arrowPosition = arrowPosition
        self.preferences = preferences
        self.delegate = delegate
        self.dismissCompletion = dismissCompletion
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture methods
    @objc func handleTap() {
        dismissCompletion?()
        dismissWithAnimation()
    }
    
    // MARK: Private methods
    fileprivate func calculateBubbleSize() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            //let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            let size = Int((ScreenWidth * 0.85) / CGFloat(noOfCellsInRow))
            //let totalPages = Int(ceil(Double(self.data.count) / Double(noOfCellsInRow)))
            var height = CGFloat(size * self.data.count)
            
            var paddingHeight: CGFloat = self.data.count >= 2 ? 10 : 0
            
            for var item in self.data {
                for var sub in item.items {
                    var textSize = sub.title.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10))
                    if textSize.width > (CGFloat(size) * 0.6) {
                        paddingHeight += 10
                        break
                    }
                }
            }
            
            if self.data.count == 1 && (self.data.first?.items.count ?? 0) < 4 {
                bubbleSize = CGSize(width: CGFloat(size * (self.data.first?.items.count ?? 0)) + 20, height: height + paddingHeight)
                return
            }
            
            bubbleSize = CGSize(width: ScreenWidth * 0.85, height: height + paddingHeight)
        }
    }
    
    fileprivate func calculateFrame() {
        guard let presentingView = presentingView else { return }
        let refViewFrame = presentingView.convert(presentingView.bounds, to: UIApplication.shared.keyWindow);
        
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0
        
        let spacingForBorder: CGFloat = (preferences.drawing.bubble.border.color != nil) ? preferences.drawing.bubble.border.width : 0
        
        switch arrowPosition {
        case .topRightWithButtonHeight:
            xOrigin = refViewFrame.center.x - contentSize.width / 2 + 15
            yOrigin = refViewFrame.y + refViewFrame.height + UIApplication.shared.statusBarFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder + contentSize.width - 18, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .top:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .topLeft:
            xOrigin = refViewFrame.x + 50
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleFrame.x + preferences.drawing.arrow.size.width + 10, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .topRight:
            xOrigin = UIScreen.main.bounds.width - (contentSize.width + spacingForBorder * 2) - preferences.drawing.bubble.inset
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x:  bubbleSize.width - (preferences.drawing.arrow.size.width + 10), y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        case .right:
            xOrigin = refViewFrame.x - contentSize.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleSize.width + preferences.drawing.arrow.size.height + spacingForBorder, y: refViewFrame.center.y - yOrigin)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottom:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y - contentSize.height
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: bubbleSize.height + preferences.drawing.arrow.size.height)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottomLeft:
            xOrigin = refViewFrame.x + 50
            yOrigin = refViewFrame.y - contentSize.height
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleFrame.x + preferences.drawing.arrow.size.width + 10, y: bubbleSize.height + preferences.drawing.arrow.size.height)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottomRight:
            xOrigin = UIScreen.main.bounds.width - (contentSize.width + spacingForBorder * 2) - preferences.drawing.bubble.inset
            yOrigin = refViewFrame.y - contentSize.height
            bubbleFrame = CGRect(x: spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: bubbleSize.width - (preferences.drawing.arrow.size.width + 10), y: bubbleSize.height + preferences.drawing.arrow.size.height)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            bubbleFrame = CGRect(x: preferences.drawing.arrow.size.height + spacingForBorder, y: spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: spacingForBorder, y: refViewFrame.center.y - yOrigin)
            collectionView.frame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .none:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            bubbleFrame = CGRect(x: spacingForBorder, y: preferences.drawing.arrow.size.height + spacingForBorder, width: bubbleSize.width, height: bubbleSize.height)
            preferences.drawing.arrow.tip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            collectionView.frame = CGRect(x: 0, y: preferences.drawing.arrow.size.height, width: bubbleSize.width, height: bubbleSize.height)
        }
        
        let calculatedFrame = CGRect(x: xOrigin, y: yOrigin, width: contentSize.width + spacingForBorder * 2, height: contentSize.height + spacingForBorder * 2)
        frame = adjustFrame(calculatedFrame)
    }
    
    private func adjustFrame(_ frame: CGRect) -> CGRect {
        let bounds: CGRect = UIScreen.main.bounds
        let restrictedBounds = CGRect(x: bounds.x + preferences.drawing.bubble.inset,
                                      y: bounds.y + preferences.drawing.bubble.inset,
                                      width: bounds.width - preferences.drawing.bubble.inset * CGFloat(2),
                                      height: bounds.height - preferences.drawing.bubble.inset * CGFloat(2))
        
        if !restrictedBounds.contains(frame) {
            var newFrame: CGRect = frame
            
            if frame.x < restrictedBounds.x {
                let diff: CGFloat = -frame.x + preferences.drawing.bubble.inset
                newFrame.x = frame.x + diff
                if arrowPosition == .top || arrowPosition == .bottom || arrowPosition == .topRight {
                    preferences.drawing.arrow.tip.x = max(preferences.drawing.arrow.size.width, preferences.drawing.arrow.tip.x - diff)
                }
            }
            
            if frame.x + frame.width > restrictedBounds.x + restrictedBounds.width {
                let diff: CGFloat = frame.x + frame.width - restrictedBounds.x - restrictedBounds.width
                newFrame.x = frame.x - diff
                if arrowPosition == .top || arrowPosition == .bottom || arrowPosition == .topRight {
                    preferences.drawing.arrow.tip.x = min(newFrame.width - preferences.drawing.arrow.size.width, preferences.drawing.arrow.tip.x + diff)
                }
            }
            
            return newFrame
        }
        
        return frame
    }
    
    fileprivate func show() {
        controller.view.alpha = 0
        controller.view.addSubview(self)
        
        createWindow(with: controller)
        addTapGesture(for: controller)
        addSubview(collectionView)
        addCollectionTapGesture()
        showWithAnimation()
    }
    
    private func addCollectionTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCollectionTap(_:)))
        collectionView.addGestureRecognizer(tap)
    }
    
    @objc func handleCollectionTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) {
            let model = self.data[indexPath.section].items[indexPath.row]
            self.handleTap()
            self.delegate?.didSelectedItem(model: model)
       }
    }
    
    private func createWindow(with viewController: UIViewController) {
        self.containerWindow = UIWindow(frame: UIScreen.main.bounds)
        self.containerWindow!.rootViewController = viewController
        self.containerWindow!.windowLevel = UIWindow.Level.alert + 1;
        self.containerWindow!.makeKeyAndVisible()
    }
    
    private func addTapGesture(for viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        viewController.view.addGestureRecognizer(tap)
    }
    
    private func showWithAnimation() {
        transform = preferences.animating.showInitialTransform
        alpha = preferences.animating.showInitialAlpha
        
        UIView.animate(withDuration: preferences.animating.showDuration, delay: 0, usingSpringWithDamping: preferences.animating.springDamping, initialSpringVelocity: preferences.animating.springVelocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.showFinalTransform
            self.alpha = 1
            self.containerWindow?.rootViewController?.view.alpha = 1
        }, completion: { (completed) in
            self.viewDidAppear()
        })
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: preferences.animating.dismissDuration, delay: 0, usingSpringWithDamping: preferences.animating.springDamping, initialSpringVelocity: preferences.animating.springVelocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.dismissTransform
            self.alpha = self.preferences.animating.dismissFinalAlpha
            self.containerWindow?.rootViewController?.view.alpha = 0
        }) { (finished) -> Void in
            self.viewDidDisappear()
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
            self.containerWindow?.resignKey()
            self.containerWindow = nil
        }
    }
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawBackgroundLayer()
        drawBubble(context)
    }
    
    private func viewDidAppear() {
        self.viewDidAppearDate = Date()
    }
    
    private func viewDidDisappear() {
        let viewDidDisappearDate = Date()
        let timeInterval = viewDidDisappearDate.timeIntervalSince(self.viewDidAppearDate)
        
    }
    
    // MARK: Drawing methods
    private func drawBackgroundLayer() {
        if let view = self.containerWindow?.rootViewController?.view, let presentingView = presentingView {
            let refViewFrame = presentingView.convert(presentingView.bounds, to: UIApplication.shared.keyWindow);
            let radius = refViewFrame.center.farCornerDistance()
            let frame = view.bounds
            let layer = RadialGradientBackgroundLayer(frame: frame, center: refViewFrame.center, radius: radius, locations: preferences.drawing.background.gradientLocations, colors: preferences.drawing.background.gradientColors)
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    private func drawBubbleBorder(_ context: CGContext, path: CGMutablePath, borderColor: UIColor) {
        context.saveGState()
        context.addPath(path)
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(preferences.drawing.bubble.border.width)
        context.strokePath()
        context.restoreGState()
    }
    
    private func drawBubble(_ context: CGContext) {
        context.saveGState()
        let path = CGMutablePath()
        
        switch arrowPosition {
        case .topRight, .top, .topRightWithButtonHeight:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y))
            addArrowTipArc(with: startingPoint, to: path)
        case .topLeft:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y))
            addArrowTipArc(with: startingPoint, to: path)
        case .right:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y - preferences.drawing.arrow.size.width / 2)
            path.move(to: startingPoint)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y + preferences.drawing.arrow.size.width / 2))
            addArrowTipArc(with: startingPoint, to: path)
        case .bottom:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height)
            path.move(to: startingPoint)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height))
            addArrowTipArc(with: startingPoint, to: path)
        case .bottomRight:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height)
            path.move(to: startingPoint)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height))
            addArrowTipArc(with: startingPoint, to: path)
        case .bottomLeft:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height)
            path.move(to: startingPoint)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y + bubbleFrame.height))
            addArrowTipArc(with: startingPoint, to: path)
        case .left:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y + preferences.drawing.arrow.size.width / 2)
            path.move(to: startingPoint)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.height, y: preferences.drawing.arrow.tip.y - preferences.drawing.arrow.size.width / 2))
            addArrowTipArc(with: startingPoint, to: path)
        case .none:
            let startingPoint = CGPoint(x: preferences.drawing.arrow.tip.x - preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrow.tip.x + preferences.drawing.arrow.size.width / 2, y: bubbleFrame.y))
        }
        
        path.closeSubpath()
        
        context.addPath(path)
        context.clip()
        context.fillPath()
        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: frame.height), options: [])
        context.restoreGState()
        
        if let borderColor = preferences.drawing.bubble.border.color {
            drawBubbleBorder(context, path: path, borderColor: borderColor)
        }
    }
    
    private func addTopArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x, y:  bubbleFrame.y), tangent2End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y + bubbleFrame.height), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addRightArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y), tangent2End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addBottomArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y + bubbleFrame.height), tangent2End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addLeftArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y + bubbleFrame.height), tangent2End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y + bubbleFrame.height), radius: preferences.drawing.bubble.cornerRadius)
    }
    
    private func addArrowTipArc(with startingPoint: CGPoint, to path: CGMutablePath) {
        path.addArc(tangent1End: preferences.drawing.arrow.tip, tangent2End: startingPoint, radius: preferences.drawing.arrow.tipCornerRadius)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let tview = touch.view, NSStringFromClass(type(of: tview.self)) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
}

extension TSIMToolChoose: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        //let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        let size = Int(((ScreenWidth * 0.85) - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TSChooseCollectionViewCell.cellIdentifier, for: indexPath) as! TSChooseCollectionViewCell
        let model = self.data[indexPath.section].items[indexPath.row]
        cell.iconTitleLabel.text = model.title
        cell.iconTitleLabel.textColor = preferences.drawing.message.color
        cell.iconImageView.image = UIImage.set_image(named: model.image)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section != self.data.count - 1 {
            return CGSize(width: bubbleSize.width, height: 1)
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section != self.data.count - 1 {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TSChooseFooterView.cellIdentifier, for: indexPath)
                footerView.width =  bubbleSize.width * 0.94
                
                return footerView
            }
        }
        /// Normally should never get here
        return UICollectionReusableView()
    }
}


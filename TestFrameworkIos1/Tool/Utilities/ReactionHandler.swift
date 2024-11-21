//
// Created by Francis Yeap on 07/12/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class ReactionHandler {
    private let iconHeight: CGFloat = 38
    private let padding: CGFloat = 8
    private var hitTest: UIView?
    
    var reactions: [ReactionTypes] = ReactionTypes.allCases
    var didSelectIcon: Int?
    var isForCollectionCell: Bool = false
    private var willShowInInverse: Bool = false
    private var inverseMultiplier: CGFloat {
        if willShowInInverse {
            return -0.5
        }
        return 0.5
    }
    
    private var reactionViews: [ReactionSelectorView] = []
    private var pointOrigin: CGPoint = .zero
    private var panIndex = 0
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private lazy var nameViews: [UIView] = {
        var views: [UIView] = []
        let height: CGFloat = 28.0
        let padding:CGFloat = 11.0
        
        for reaction in reactions {
            let container = UIView()
            let bg = UIView().build { (view) -> () in
                view.backgroundColor = AppTheme.materialBlack.withAlphaComponent(0.8)
            }
            let label = UILabel().build { (label) -> () in
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 12)
                label.text = reaction.title
            }

            container.addSubview(bg)
            container.addSubview(label)

            bg.snp.makeConstraints { v in
                v.left.top.centerX.centerY.equalToSuperview()
                v.height.equalTo(height)
            }
            label.snp.makeConstraints { v in
                v.centerY.equalTo(bg)
                v.left.right.equalTo(bg).inset(padding)
            }
            
            label.sizeToFit()
            
            bg.roundCorner(height/2)
            container.frame = CGRect(x: 0, y: 0, width: label.frame.width + padding*2, height: height)
 
            views.append(container)
        }
        return views
    }()


    private lazy var stackView: UIStackView = {
        return UIStackView().configure { stackView in
            stackView.distribution = .fillEqually
            stackView.spacing = self.padding
            stackView.layoutMargins = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
            stackView.isLayoutMarginsRelativeArrangement = true
        }
    }()

    lazy var iconsContainerView: UIView = {
        return createReactionView()
    }()

    lazy var longPressGesture: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
    }()
    lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.handleLongPress(gesture:)))
    }()

    var feedId: Int
    var feedItem: FeedListCellModel?
    weak var reactionView: UIView?
    weak var view: UIView?
    var apiInProgress = false
    var currentReaction: ReactionTypes?

    var onSelect: ((_ reaction: ReactionTypes?) -> Void)?
    var onPresent: EmptyClosure?
    var onDismiss: EmptyClosure?
    var onError: ((_ fallbackReaction: ReactionTypes?, _ message: String) -> Void)?
    var onSuccess: ((_ message: String) -> Void)?

    var shouldBlockInteraction: Bool = true
    private var theme: Theme = .white

    lazy var bgView: TouchAbsorbingView = {
        let bg = TouchAbsorbingView().build { v in
            v.backgroundColor = .clear
            v.isUserInteractionEnabled = true
            v.backgroundColor = UIColor.black.withAlphaComponent(CGFloat.leastNormalMagnitude)
        }
        
        bg.onTouchInside = { [weak self] in
            self?.reset()
        }
        return bg
    }()

    init(reactionView: UIView, toAppearIn view: UIView, currentReaction: ReactionTypes?, feedId: Int, feedItem: FeedListCellModel?, shouldBlockInteraction: Bool = true, theme: Theme = .white, reactions :[ReactionTypes] = ReactionTypes.allCases, isForCollectionCell: Bool = false) {
        self.reactionView = reactionView
        self.view = view
        self.feedId = feedId
        self.feedItem = feedItem
        self.theme = theme
        self.currentReaction = currentReaction
        self.shouldBlockInteraction = shouldBlockInteraction
        self.reactions = reactions
        self.isForCollectionCell = isForCollectionCell

        reactionView.addTap(action: { [weak self] (_) in
            guard TSCurrentUserInfo.share.isLogin == true else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            guard let self = self else { return }
            self.onTapReactionView()
        })
    }
    
    func onTapReactionView() {
        weak var wself = self
        guard let cur = wself?.currentReaction else {
            self.didSelectIcon = 0
            wself?.onSelect(reaction: .heart)
            wself?.currentReaction = .heart
            return
        }
        self.didSelectIcon = nil
        wself!.onSelect(reaction: nil)
        wself!.currentReaction = nil
    }

    func onSelect(reaction: ReactionTypes?) {
        onSelect?(reaction)
        postReaction()
    }
    
    private func createReactionView() -> UIView {
        let containerView = UIView()
        switch theme {
        case .white: containerView.backgroundColor = .white
        case .dark: containerView.backgroundColor = AppTheme.materialBlack
        }
        
        reactionViews.removeAll()

        let arrangedSubviews = reactions.enumerated().map({ (index, reaction) -> UIView in
            let custom = ReactionSelectorView(reactionType: reaction)
            
            custom.addTap { [weak self] (_) in
                self?.didSelectIcon = index
                self?.onSelect(reaction: reaction)
                self?.reset()
            }
//            custom.imageView.image = reaction.image
            custom.tag = index
            custom.stackview.tag = index
            
            custom.nameLabel.text = reaction.title
            reactionViews.append(custom)
            return custom
        })

        
        stackView.removeAllArrangedSubviews()
        for subview in arrangedSubviews {
            stackView.addArrangedSubview(subview)
        }
        
        containerView.addSubview(stackView)

        let numIcons = CGFloat(arrangedSubviews.count)
        let width =  numIcons * self.iconHeight + (numIcons + 1) * padding

        containerView.frame = CGRect(x: 0, y: 0, width: width, height: iconHeight + 2 * padding)
        containerView.layer.cornerRadius = containerView.frame.height / 2

        // shadow
        containerView.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)

        stackView.frame = containerView.frame
        
        containerView.addGestureRecognizer(panGesture)
        return containerView
    }


    @objc func handleBgGesture(gesture: UIGestureRecognizer) {

    }


    @objc func handleLongPress(gesture: UIGestureRecognizer) {
        guard TSCurrentUserInfo.share.isLogin else {
            return
        }
        
        switch gesture.state { 
        case .began:
            guard gesture == longPressGesture else { return }
            hitTest = nil
            handleGestureBegan(gesture: gesture)
            
        case .changed:
            handleGestureChanged(gesture: gesture)
            
        case .ended:
            guard didSelectIcon != nil else {
                self.onPresent?()
                return
            }
            self.onSelect(reaction: reactions[panIndex])
            self.reset()
            
        default: break
        }
        
    }
    
    func reset() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let stackView = self.iconsContainerView.subviews.first
            stackView?.subviews.enumerated().forEach({ (i, v) in
                
                let rect = self.iconsContainerView.convert(v.center, to: self.view)
                let center = rect.x - v.width / 2
                self.nameViews[i].transform = CGAffineTransform(translationX: center, y: self.iconsContainerView.origin.y - self.iconHeight*0.5*self.inverseMultiplier)
                
                v.transform = .identity
                self.nameViews[i].alpha = 0
            })
            
            self.iconsContainerView.transform = self.iconsContainerView.transform.translatedBy(x: 0, y: 50*self.inverseMultiplier)
            self.iconsContainerView.alpha = 0
            
        }, completion: { (_) in
            
            self.bgView.removeFromSuperview()
            self.iconsContainerView.removeFromSuperview()
            self.onDismiss?()
            self.iconsContainerView = self.createReactionView()
            if let iconVal = self.didSelectIcon {
                let selectedReaction = self.reactions[iconVal]
                self.currentReaction = selectedReaction
                self.onSelect(reaction: selectedReaction)
            }
            self.didSelectIcon = nil
            self.nameViews.forEach { (v) in
                v.removeFromSuperview()
            }
        })
    }

    fileprivate func handleGestureChanged(gesture: UIGestureRecognizer) {
        let pressedLocation = gesture.location(in: self.iconsContainerView)
        
        let fixedYLocation = CGPoint(x: pressedLocation.x, y: self.iconsContainerView.frame.height / 2)

        let hitTestView = iconsContainerView.hitTest(fixedYLocation, with: nil)
        
        var hitChanged = false
        if hitTest != nil, hitTest != hitTestView {
            feedbackGenerator.impactOccurred()
            hitChanged = true
        }
        
        hitTest = hitTestView
        
        if let hitView = hitTestView as? ReactionSelectorView, let view = view, hitChanged == true {
            let myview = nameViews[hitView.tag]
            didSelectIcon = hitView.tag
            
            let centerPosition = self.iconsContainerView.convert(hitView.center, to: view)
            let location = centerPosition.x - myview.width / 2
            let startingPosY: CGFloat
            if self.willShowInInverse {
                startingPosY = self.iconsContainerView.frame.maxY - myview.height / 2
            } else {
                startingPosY = self.iconsContainerView.origin.y - myview.height / 2
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                hitView.imageView.transform = CGAffineTransform(scaleX: 1.8, y: 1.8).translatedBy(x: 0, y: -self.iconHeight*0.5*self.inverseMultiplier)
//                hitView.nameContentView.transform = CGAffineTransform(scaleX: 1, y: 1).translatedBy(x: 0, y: (-25 * 1.3*self.inverseMultiplier))
                myview.transform = CGAffineTransform(translationX: location, y: startingPosY - ((5 + 45)*1.5*self.inverseMultiplier))
                myview.alpha = 1
            })
            panIndex = hitView.tag
            
            let stackView = self.iconsContainerView.subviews.first
            stackView?.subviews.enumerated().forEach({ (i, v) in
                UIView.animate(withDuration: 0.3) {
                    if v != hitView {
                        let rect = self.iconsContainerView.convert(v.center, to: self.view)
                        let center = rect.x - v.width / 2
                        
                        (v as? ReactionSelectorView)?.imageView.transform = .identity
                        
                        self.nameViews[i].transform = CGAffineTransform(translationX: center, y: startingPosY - 0 * self.inverseMultiplier)
                        self.nameViews[i].alpha = 0
                    }
                }
            })
        }
    }

    fileprivate func handleGestureBegan(gesture: UIGestureRecognizer) {
        if let view = view {
            panIndex = 0
            
            if shouldBlockInteraction {
                bgView.frame = view.frame
                self.view!.addSubview(bgView)
            }
            self.view!.addSubview(iconsContainerView)

            let pressedLocation = gesture.location(in: view)
            var pressedLocationY = pressedLocation.y - (iconsContainerView.height)
            
            willShowInInverse = pressedLocation.y < 80

            var centeredX = (view.frame.width - iconsContainerView.frame.width) / 2
            
            if isForCollectionCell {
                if (pressedLocation.x / 2.0) + iconsContainerView.width > ScreenWidth {
                    centeredX = ScreenWidth - iconsContainerView.width - 10
                } else {
                    centeredX = (pressedLocation.x / 2.0) - 30
                }
                
                if willShowInInverse {
                    pressedLocationY = pressedLocation.y + 18
                } else {
                    pressedLocationY -= 18
                }
            } else {
                pressedLocationY -= 18
            }

            iconsContainerView.alpha = 0
            self.iconsContainerView.transform = CGAffineTransform(translationX: centeredX, y: isForCollectionCell ? pressedLocationY : pressedLocation.y)

            let adjustedPressY = self.willShowInInverse ? self.iconsContainerView.height : self.iconsContainerView.height + 28.0 // 28-name view height
            
            self.pointOrigin = CGPoint(x: centeredX, y: pressedLocationY)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.iconsContainerView.alpha = 1
                self.iconsContainerView.transform = CGAffineTransform(translationX: self.pointOrigin.x, y: self.pointOrigin.y)
            }) { (_) in
                
                for (i, v) in self.nameViews.enumerated() {
                    let associatedReaction = self.stackView.arrangedSubviews[i]
                    let centerPosition = self.iconsContainerView.convert(associatedReaction.frame.center, to: self.view)
                    let location = centerPosition.x
                    
                    self.reactionViews[i].animatedView.play()
                    self.view?.addSubview(v)
                    v.alpha = 0
                    
                    let startingPosY = self.willShowInInverse ? self.iconsContainerView.frame.maxY : self.iconsContainerView.origin.y - 28.0 // 28-name view height
                    let adjustment: CGFloat = self.willShowInInverse ? -1.0 : 1.0
                    v.transform = CGAffineTransform(translationX: location, y: startingPosY - (5.0 + 30.0) * adjustment)
                }
            }
        }
    }
}


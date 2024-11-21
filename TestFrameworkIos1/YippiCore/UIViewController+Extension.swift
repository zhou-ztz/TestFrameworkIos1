//
//  UIViewController+Extension.swift
//  Yippi
//
//  Created by Yong Tze Ling on 17/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import SwiftEntryKit

public typealias EmptyClosure = () -> Void

/// 打赏类型
enum TSRewardType {
    case moment
    case news
    case user
    case post
    case live(messageId: String)
    case sticker
}

public enum Theme {
    case white, dark
}

private class NavLeftAlignWrapperView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: UIView.noIntrinsicMetric)
    }

    init(custom view: UIView) {
        super.init(frame: .zero)

        addSubview(view)
        view.snp.makeConstraints { v in
            v.top.bottom.equalToSuperview()
            v.left.right.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

private class TitleView: UIView {
    let titleLabel = UILabel()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: UIView.noIntrinsicMetric)
    }

    init(text: String, color: UIColor) {
        super.init(frame: .zero)

        addSubview(titleLabel)

        titleLabel.textColor = color
        titleLabel.text = text
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.snp.makeConstraints { v in
            v.top.bottom.right.equalToSuperview()
            v.left.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


extension UIViewController {
 
    
    static var topMostController: UIViewController? {
        var topMostController: UIViewController?
        topMostController = UIApplication.shared.keyWindow?.rootViewController
        
        while topMostController?.presentedViewController != nil {
            topMostController = topMostController?.presentedViewController
        }
        if topMostController is UITabBarController {
            let tabBarController = topMostController as? UITabBarController
            return tabBarController?.selectedViewController
        }
        if topMostController is UINavigationController {
            let navigationController = topMostController as? UINavigationController
            return navigationController?.visibleViewController == nil ? navigationController : navigationController?.visibleViewController
        }
        
        if let topMostController1 = topMostController {
            
            if NSStringFromClass(type(of: topMostController1).self).hasSuffix("TSRootViewController") && topMostController1.children.count > 0 {
                topMostController = topMostController1.children.last
                if topMostController is UITabBarController {
                    let tabBarController = topMostController as? UITabBarController
                    topMostController = tabBarController?.selectedViewController
                    if topMostController is UINavigationController {
                        let navigationController = topMostController as? UINavigationController
                        topMostController = navigationController?.visibleViewController == nil ? navigationController : navigationController?.visibleViewController
                    }
                } else if topMostController is UINavigationController{
                    let navigationController = topMostController as? UINavigationController
                    topMostController = navigationController?.visibleViewController == nil ? navigationController : navigationController?.visibleViewController
                }
            }
            
        }
        
        return topMostController
    }
    
    func showAlert(title: String? = nil, message: String, buttonTitle: String, defaultAction: @escaping ((UIAlertAction) -> Void), cancelTitle: String? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: defaultAction))
        
        if let canceltitle = cancelTitle {
            alert.addAction(UIAlertAction(title: canceltitle, style: .cancel, handler: cancelAction))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showLoading(with title: String = "", description: String = "", theme: Theme = .white, backgroundColor: UIColor = .clear) {
        let view = PlaceHolderView(offset: 0, heading: title, detail: description, lottieName: "feed-loading", theme: theme)
        view.backgroundColor = backgroundColor
        view.tag = 10001
        UIApplication.shared.windows.first?.addSubview(view)
        view.bindToEdges()
    }
    
    func dismissLoading() {
        if let view = UIApplication.shared.windows.first?.viewWithTag(10001) {
            view.removeFromSuperview()
        }
    }
    
    func setLeftAlignedNavigationItemView(_ customView: UIView) {

        self.navigationItem.titleView = NavLeftAlignWrapperView(custom: customView)
    }

    func setLeftAlignedNavigationItemTitle(text: String,
                                           color: UIColor) {

        let titleView = TitleView(text: text, color: color)
        self.navigationItem.titleView = titleView
    }

//    func presentTipping(target: Any, type: TSRewardType, theme: Theme = .white, defaultPageIdx: Int = 0, delegate: RewardViewProtocol? = nil, onSuccess: ((Any, RewardModel) -> Void)? = nil) {
//        let rewardVC = RewardViewController(target: target, type: type, theme: theme, onRewardSuccess: onSuccess)
//        rewardVC.modalTransitionStyle = .crossDissolve
//        rewardVC.modalPresentationStyle = .overCurrentContext
//        rewardVC.delegate = delegate
//        rewardVC.defaultPageIndex = defaultPageIdx
//        self.present(rewardVC, animated: true, completion: nil)
//    }
//    
    func presentPopVC(target: Any, type: TSPopUpType, delegate: CustomPopListProtocol? = nil) {
        var items: [TSPopUpItem] = []
        switch type {
        case .moreUser:
            guard let feedModel = target as? FeedListCellModel, let id = CurrentUserSessionInfo?.userIdentity else {
                return
            }
            //是否收藏
            let isCollect = (feedModel.toolModel?.isCollect).orFalse ? false : true
            items.append(.save(isSaved: isCollect))
            items.append(.reportPost)
        case .moreMe:
            if !UserDefaults.teenModeIsEnable {
                items = [.edit]
            }
            guard let feedModel = target as? FeedListCellModel, let id = CurrentUserSessionInfo?.userIdentity else {
                return
            }
            //是否Pin
            let isPinned = feedModel.isPinned ? true : false
            items.append(.pinTop(isPinned: isPinned))
      
            //是否收藏
            let isCollect = (feedModel.toolModel?.isCollect).orFalse ? false : true
            items.append(.save(isSaved: isCollect))
            
            //是否关闭评论
            let isCommentDisabled = (feedModel.toolModel?.isCommentDisabled).orFalse
            
            items.append(.comment(isCommentDisabled: isCommentDisabled))
            items.append(.deletePost)
        case .share:
            if !UserDefaults.teenModeIsEnable {
                items = [.message]
            }
            items.append(.shareExternal)
        case .selfComment:
            guard let target = target as? LivePinCommentModel, let model = target.model as? FeedCommentListCellModel else { return }
            if target.requiredPinMessage {
                items = [model.showTopIcon ? .liveUnPinComment(model: target) : .livePinComment(model: target), .deleteComment(model: target), .copy(model: target)]
            } else {
                items = [.deleteComment(model: target), .copy(model: target)]
            }
        case .normalComment:
            guard let target = target as? LivePinCommentModel, let model = target.model as? FeedCommentListCellModel else { return }
            if target.requiredPinMessage {
                items = [model.showTopIcon ? .liveUnPinComment(model: target) : .livePinComment(model: target), .reportComment(model: target), .copy(model: target)]
            } else {
                items = [.reportComment(model: target), .copy(model: target)]
            }
        }
   
        let popVC = CustomPopListViewController(type: type, items: items)
        popVC.modalTransitionStyle = .crossDissolve
        popVC.modalPresentationStyle = .overCurrentContext
        popVC.delegate = delegate
//        rewardVC.defaultPageIndex = defaultPageIdx
        self.present(popVC, animated: true, completion: nil)
    }
    
    func showSuccess(message: String) {
        let topShow = TSIndicatorWindowTop(state: .success, title: message)
        topShow.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showError(message: String = "please_retry_option".localized) {
        UIViewController.showBottomFloatingToast(with: "", desc: message, background: AppTheme.materialBlack.withAlphaComponent(0.8), displayDuration: 1.5)
    }
    
    func showTopIndicator(status: LoadingState , _ title: String) {
        let alert = TSIndicatorWindowTop(state: status, title: title)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showTopFloatingToast(with title: String, desc: String = "", background: UIColor? = nil, customView: UIView? = nil) {
        var attr = UIView.topToastAttributes
        attr.name = "toast"
        attr.displayDuration = 2.5
        
        var backgroundColor = background
        
        if backgroundColor == nil {
            backgroundColor = UIColor.black.withAlphaComponent(0.75)
        }
        
        attr.entryBackground = .color(color: EKColor(backgroundColor!))
        
        if let customView = customView {
            SwiftEntryKit.display(entry: customView, using: attr)
            return
        }
        
        let toastView = AlertContentView(for: title, desc: desc, background: backgroundColor!)
        
        SwiftEntryKit.display(entry: toastView, using: attr)
    }

    @discardableResult
    func showBottomFloatingView(with controller: UIViewController, displayDuration: TimeInterval = 2.5, allowTouch: Bool = true) -> SwiftEntryKit.EntryDismissalDescriptor {
        let entryname = UUID().uuidString
        var attr = UIView.bottomToastAttributes
        attr.name = entryname
        attr.displayDuration = displayDuration
        attr.screenInteraction = allowTouch ? .dismiss : .absorbTouches
        attr.entryInteraction = .absorbTouches

        attr.entryBackground = .color(color: EKColor(UIColor.clear))

        let nav = TSNavigationController(rootViewController: controller)
        nav.view.roundCornerWithCorner(UIRectCorner([.topLeft, .topRight]), radius: 10, fillColor: .clear, shadow: false)

        SwiftEntryKit.display(entry: controller, using: attr)

        return .specific(entryName: entryname)
    }

    @discardableResult
    func showBottomFloatingView(with customView: UIView, displayDuration: TimeInterval = 2.5, allowTouch: Bool = true) -> SwiftEntryKit.EntryDismissalDescriptor {
        let entryname = UUID().uuidString
        var attr = UIView.bottomToastAttributes
        attr.name = entryname
        attr.displayDuration = displayDuration
//        attr.screenInteraction = allowTouch ? .forward : .forward
        attr.screenInteraction = .forward
        attr.entryInteraction = .absorbTouches

        attr.entryBackground = .color(color: EKColor(UIColor.clear))
        SwiftEntryKit.display(entry: customView, using: attr)

        return .specific(entryName: entryname)
    }

    func dismisSwiftyEntry(named: String? = nil) {
        guard let name = named else {
            SwiftEntryKit.dismiss(.displayed)
            return
        }
        SwiftEntryKit.dismiss(.specific(entryName: name))
    }

    func dismissSwiftyEntryErrors() {
        SwiftEntryKit.dismiss(.specific(entryName: "errors"), with: nil)
    }

    static func showBottomFloatingToast(with title: String, desc: String, background:UIColor? = nil, displayDuration: TimeInterval = 2.5) {
        guard SwiftEntryKit.isCurrentlyDisplaying == false else { return }
        
        var attr = UIView.bottomToastAttributes
        attr.name = "errors"
        attr.displayDuration = displayDuration
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        
        var backgroundColor = background
        
        if backgroundColor == nil {
            backgroundColor = UIColor.black.withAlphaComponent(0.75)
        }
        
        attr.entryBackground = .color(color: EKColor(backgroundColor!))
        
        var message = (desc.isEmpty && title.isEmpty) ? "please_retry_option".localized : desc
        
        let toastView = AlertContentView(for: title, desc: message, background: backgroundColor!)
        
        SwiftEntryKit.display(entry: toastView, using: attr)
    }

    /// ratio 0-1.0
    func showBottomSlideUp(controller: UIViewController, ratio: CGFloat = 0.6, height: CGFloat = 0) {
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.roundCorners = .top(radius: 10)
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: EKColor(AppTheme.dimmedDarkestBackground))
        attributes.entryBackground = .clear
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.scroll = .disabled
        attributes.entranceAnimation = .init(
                translate: .init(
                        duration: 0.2,
                        spring: nil
                )
        )
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.shadow = .active(with: .init(
                                        color: .black,
                                        opacity: 0.3,
                                        radius: 6))
        attributes.positionConstraints.size = .init(width: .constant(value: 300), height: .intrinsic)
       //attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
        attributes.statusBar = .dark

        //controller.view.roundCornerWithCorner([.topRight, .topLeft], radius: 10, fillColor: .white, shadow: false)
        SwiftEntryKit.display(entry: controller, using: attributes, presentInsideKeyWindow: true)
    }

    var isModal: Bool {
        return presentingViewController != nil || navigationController?.presentingViewController?.presentedViewController == navigationController || tabBarController?.presentingViewController is UITabBarController
    }
    
    func heroPush(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard (viewController is TSNavigationController) == false else {
            viewController.hero.isEnabled = true
            viewController.heroModalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .push(direction: .right))
            (viewController as? TSNavigationController)?.setCloseButton(backImage: true)
            self.present(viewController.fullScreenRepresentation, animated: true, completion: completion)
            
            return
        }
            
        let nav = TSNavigationController(rootViewController: viewController)
        nav.hero.isEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .push(direction: .right))
        nav.setCloseButton(backImage: true)
        self.present(nav.fullScreenRepresentation, animated: true, completion: completion)
    }
    
    func showDialog(image: UIImage? = nil, title: String? = nil, message: String, dismissedButtonTitle: String, onDismissed: (()->())?, onCancelled: (()->())? = nil, cancelButtonTitle: String? = nil, isRedPacket: Bool? = false, isInsufficientBalance: Bool? = false, isFavouriteMessage: Bool? = false) {
        let alertViewContent = UIView(frame: .zero)
        alertViewContent.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
        }
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.spacing = 20
        
        if let img = image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            mainStackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(30)
                $0.width.equalTo(120)
                $0.height.equalTo(imageView.snp.width)
            }
        }
        
        let contentLabelStackView = UIStackView()
        contentLabelStackView.axis = .vertical
        contentLabelStackView.alignment = .fill
        contentLabelStackView.distribution = .fill
        contentLabelStackView.spacing = 8
        
        if let titleString = title {
            let alertTitle = UILabel()
            alertTitle.applyStyle(.bold(size: 16, color: .black), setAdaptive: true)
            alertTitle.text = titleString
            alertTitle.textAlignment = .center
            alertTitle.numberOfLines = 1
            contentLabelStackView.addArrangedSubview(alertTitle)
            alertTitle.snp.makeConstraints {
                if isInsufficientBalance ?? false {
                    $0.top.equalToSuperview().offset(20)
                }
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
            }
        }
        
        let alertDescription = UILabel()
        alertDescription.applyStyle(.regular(size: 14, color: .black), setAdaptive: true)
        alertDescription.text = message
        alertDescription.textAlignment = .center
        alertDescription.numberOfLines = 0
        alertDescription.textColor = UIColor(red: 136.0/255.0, green: 136.0/255.0, blue: 136.0/255.0, alpha: 1.0)
        contentLabelStackView.addArrangedSubview(alertDescription)
        alertDescription.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubview(contentLabelStackView)
        contentLabelStackView.snp.makeConstraints {
            if isFavouriteMessage ?? false {
                $0.top.equalToSuperview().offset(25)
            }
            $0.left.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-25)
        }
        let okButton = UIButton()
        let cancelButton = UIButton()
        
        if isRedPacket ?? false {
            let buttonStackView = UIStackView()
            buttonStackView.axis = .horizontal
            buttonStackView.alignment = .center
            buttonStackView.distribution = .fill
            buttonStackView.spacing = 8
            
            buttonStackView.snp.makeConstraints {
                $0.height.equalTo(70)
            }
            
            if let cancelTitle = cancelButtonTitle {
                if isFavouriteMessage ?? false {
                    cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0) , backgroundColor: UIColor(hex: 0xF5F5F5), cornerRadius: 22.5))
                } else {
                    cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0), backgroundColor: .clear, cornerRadius: 0))
                }
                buttonStackView.addArrangedSubview(cancelButton)
                cancelButton.snp.makeConstraints {
                    $0.height.equalTo(45)
                    $0.width.equalTo(145)
                }
            }
            
            if isFavouriteMessage ?? false {
                okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: .white, backgroundColor: UIColor(hex: 0xED2121), cornerRadius: 22.5))
            } else {
                okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: .white, backgroundColor: TSColor.main.theme, cornerRadius: 22.5))
            }
            buttonStackView.addArrangedSubview(okButton)
            okButton.snp.makeConstraints {
                $0.height.equalTo(45)
                $0.width.equalTo(145)
            }
            
            mainStackView.addArrangedSubview(buttonStackView)
        }else {
            okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: .white, backgroundColor: TSColor.main.theme, cornerRadius: 22.5))
            mainStackView.addArrangedSubview(okButton)
            okButton.snp.makeConstraints {
                $0.left.equalToSuperview().offset(59)
                $0.right.equalToSuperview().offset(-59)
                $0.height.equalTo(45)
            }
            
            if let cancelTitle = cancelButtonTitle {
                cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0), backgroundColor: .clear, cornerRadius: 0))
                mainStackView.addArrangedSubview(cancelButton)
                cancelButton.snp.makeConstraints {
                    $0.left.equalToSuperview().offset(59)
                    $0.right.equalToSuperview().offset(-59)
                    $0.height.equalTo(20)
                }
            }
        }
        alertViewContent.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        alertViewContent.setNeedsLayout()
        alertViewContent.layoutIfNeeded()
        
        var allowDismiss = Bool()
        if isRedPacket! {
            allowDismiss = false
        } else {
            allowDismiss = true
        }
        let popup = TSAlertController(style: .popup(customview: alertViewContent), hideCloseButton: true, allowBackgroundDismiss: allowDismiss)
        popup.modalPresentationStyle = .overFullScreen
        okButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onDismissed?()
        }
        cancelButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onCancelled?()
        }
        self.present(popup, animated: false)
    }
    
    func showRLDelete(title: String? = nil, message: String, dismissedButtonTitle: String, onDismissed: (()->())?, onCancelled: (()->())? = nil, cancelButtonTitle: String? = nil) {
        let alertViewContent = UIView(frame: .zero)
        alertViewContent.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
        }
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.spacing = 20
        
        let contentLabelStackView = UIStackView()
        contentLabelStackView.axis = .vertical
        contentLabelStackView.alignment = .fill
        contentLabelStackView.distribution = .fill
        contentLabelStackView.spacing = 15
        
        let actionStackView = UIStackView()
        actionStackView.axis = .horizontal
        actionStackView.alignment = .fill
        actionStackView.distribution = .fill
        actionStackView.spacing = 8
        
        if let titleString = title {
            let alertTitle = UILabel()
            alertTitle.applyStyle(.bold(size: 16, color: .black), setAdaptive: true)
            alertTitle.text = titleString
            alertTitle.textAlignment = .left
            alertTitle.numberOfLines = 1
            contentLabelStackView.addArrangedSubview(alertTitle)
            alertTitle.snp.makeConstraints {
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
            }
        }
        
        let alertDescription = UILabel()
        alertDescription.applyStyle(.regular(size: 14, color: .black), setAdaptive: true)
        alertDescription.text = message
        alertDescription.textAlignment = .left
        alertDescription.numberOfLines = 0
        alertDescription.textColor = UIColor(hex: 0x808080)
        contentLabelStackView.addArrangedSubview(alertDescription)
        alertDescription.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubview(contentLabelStackView)
        contentLabelStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-25)
        }
        
        
        let okButton = UIButton()
        let cancelButton = UIButton()
        
        
        if let cancelTitle = cancelButtonTitle {
            cancelButton.applyStyle(.custom(text: cancelTitle, textColor: UIColor(hex: 0x808080), backgroundColor: .clear, cornerRadius: 0))
            actionStackView.addArrangedSubview(cancelButton)
        }
        
        
        okButton.applyStyle(.custom(text: dismissedButtonTitle, textColor: AppTheme.red, backgroundColor: .clear, cornerRadius: 0))
        actionStackView.addArrangedSubview(okButton)
        
        alertViewContent.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        mainStackView.addArrangedSubview(actionStackView)
        actionStackView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.width.equalToSuperview().multipliedBy(0.45)
        }
        
        alertViewContent.setNeedsLayout()
        alertViewContent.layoutIfNeeded()
        
        var allowDismiss = Bool()
     
        allowDismiss = true
        
        let popup = TSAlertController(style: .popup(customview: alertViewContent), hideCloseButton: true, allowBackgroundDismiss: allowDismiss)
        popup.modalPresentationStyle = .overFullScreen
        okButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onDismissed?()
        }
        cancelButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            popup.dismiss()
            onCancelled?()
        }
        self.present(popup, animated: false)
    }
    
    static func loadViewControllerFromStoryboard<T: UIViewController>(from bundle: Bundle = .main) -> T{
        let identifier = String(describing: self)
        
        guard let vc =  UIStoryboard(name: identifier, bundle: bundle).instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("UIViewController with identifier '\(identifier)' was not found")
        }
        return vc
    }
}

extension UINavigationController: LoadingViewDelegate { }

extension UINavigationController {
    func popViewController(animated: Bool, completion: @escaping (() -> ())) {
        popViewController(animated: animated)
        
        if self.transitionCoordinator != nil && animated == true {
            self.transitionCoordinator!.animate(alongsideTransition: nil) { (_) in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
 
}

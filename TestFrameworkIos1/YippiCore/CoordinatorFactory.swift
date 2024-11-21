// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

@objc public protocol StickerShopViewCoordinatorType: NSObjectProtocol {
    func start(completion: (() -> Void)?)
    func showStickerDetail(_ bundleId: String)
}
@objc public protocol BeautyShopViewCoordinatorType: NSObjectProtocol {
    func startPresentView(completion: (() -> Void)?)
    
}

@objc public protocol CoordinatorFactoryType {
    @objc func makeStickerShopCoordinator(navigationController: UINavigationController) ->  StickerShopViewCoordinatorType!
    @objc func makeBeautyShopCoordinator(navigationController: UINavigationController) ->  BeautyShopViewCoordinatorType!
}

// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

/* NOTE: Just to have a simple dependency injection container. Later to consider whether Dip, SwiftInject, Needle, Typhoon
 - https://github.com/AliSoftware/Dip
  - https://github.com/pjwelcome/CakePatternWithSwinject
 - https://github.com/appsquickly/Typhoon
 - https://github.com/uber/needle
*/
import Foundation

@objc public protocol CoreDependencyType {
    func resolveViewControllerFactory() -> ViewControllerFactoryType
   // func resolveCoordinatorFactory() -> CoordinatorFactoryType
    func resolvePopupDialogFactory() -> PopupDialogFactoryType
    func resolveUtilityFactory() -> UtilityFactoryType
    func resolveViewFactory() -> ViewFactoryType
  //  func resolveShareActionSheetFactory() -> ShareActionSheetFactoryType
}

@objcMembers
public class DependencyContainer: NSObject, CoreDependencyType {
  
    
    public func resolveViewFactory() -> ViewFactoryType {
        return self.coreDependency.resolveViewFactory()
    }
    
    public func resolveUtilityFactory() -> UtilityFactoryType {
        return self.coreDependency.resolveUtilityFactory()
    }
    
    public func resolveViewControllerFactory() -> ViewControllerFactoryType {
        return self.coreDependency.resolveViewControllerFactory()
    }

    public func resolvePopupDialogFactory() -> PopupDialogFactoryType {
        return self.coreDependency.resolvePopupDialogFactory()
    }
    
    private var coreDependency: CoreDependencyType!
    public static let shared = DependencyContainer()
    
    public func register(_ coreDependency: CoreDependencyType) {
        self.coreDependency = coreDependency
    }
}

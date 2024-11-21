import Foundation
import UIKit

protocol CoordinatorNavigationDelegate: class {
    associatedtype viewController: UIViewController
    func dismiss(vc: viewController)
}

/**
	Every child coordinator must implement Coordinator protocol
	- func start: Starts the coordinator process, it usually decides what is going to be presented
	- var services: Property that contains all the services that are being used in the app
	- var finish: Is a closure that notifies parent Coordinator that the child coordinator is finished.
	- var currentVC: Returns view controller that is currently being displayed
*/
public protocol CoordinatorType: class {
	init(services: ServicesType, navigation: UINavigationController?)
	func start()
	var services: ServicesType { get }
	var finish: (_ coordinator: CoordinatorType) -> () { get set }
	var navigation: UINavigationController? { get set }
	var currentViewController: UIViewController?  { get }
}

public protocol TabCoordinatorType {
    associatedtype RootType: UIViewController
    var rootViewController: RootType { get }
    var tabBarItem: UITabBarItem { get }
}

extension TabCoordinatorType {
    public var deGenericize: AnyTabCoordinator {
        return AnyTabCoordinator(self)
    }
}

extension CoordinatorType {
	public var currentViewController: UIViewController? {
		return navigation?.viewControllers.last
	}
}

public class AnyTabCoordinator {
    public var rootViewController: UIViewController
    public var coordinatorClassName: String
    var tabBarItem: UITabBarItem
    init<T: TabCoordinatorType>(_ tabCoordinator: T) {
        coordinatorClassName = String(describing: type(of: tabCoordinator))
        rootViewController = tabCoordinator.rootViewController
        tabBarItem = tabCoordinator.tabBarItem
    }
}

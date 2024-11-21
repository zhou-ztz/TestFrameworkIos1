import Foundation
import UIKit


open class BaseViewController: UIViewController {
    
    var services: ServicesType!
    
    public convenience init(services: ServicesType) {
        self.init(nibName: nil, bundle: nil)
        self.services = services
    }
    
}

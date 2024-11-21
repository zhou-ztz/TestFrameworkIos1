import Foundation

@objc public enum WalletType: Int {
    case yipps
    case cpoint
    
    public func name() -> String {
        switch self {
        case .yipps: return "yipps"
        case .cpoint: return "cpoint"
        default:
            return ""
        }
    }
}

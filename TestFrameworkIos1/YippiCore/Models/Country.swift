import Foundation
import UIKit

public struct Country: Equatable {
    
    public var name: String?
    public var phoneCode: String?
    public var flagImage: UIImage?
    public var isoCode: String?
    
    public static var all: [Country] {
        let sortedCodes = IsoCountries.allCountries.map { $0.alpha2 }
        let countries = sortedCodes.compactMap { Country(isoCode: $0) }
        return countries
    }
    
    public static var `default`: Country {
        return Country(isoCode: "MY")!
    }
    
    public init?(isoCode: String) {
        guard let flagImage = UIImage.set_image(named: "ic_flag_\(isoCode.lowercased())") else {
            return nil
        }
        self.name = Locale.current.localizedString(forRegionCode: isoCode)
        self.phoneCode = IsoCountryCodes.find(key: isoCode).calling
        self.flagImage = flagImage
        self.isoCode = isoCode
    }
    
    public init?(phoneCode: String) {
        let isoCode = IsoCountryCodes.searchByCallingCode(calllingCode: phoneCode).alpha2
        self.init(isoCode: isoCode)
    }
    

    public static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.isoCode?.lowercased() == rhs.isoCode?.lowercased()
    }
}

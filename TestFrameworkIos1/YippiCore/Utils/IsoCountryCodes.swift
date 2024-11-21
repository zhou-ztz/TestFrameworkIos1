class IsoCountryCodes {
    
    class func find( key:String ) -> IsoCountryInfo {
        let country = IsoCountries.allCountries.filter { $0.alpha2 == key.uppercased() || $0.alpha3 == key.uppercased() || $0.numeric == key }
        return country[0]
    }
    
    class func searchByName( name:String ) -> IsoCountryInfo {
        let country = IsoCountries.allCountries.filter { $0.name == name }
        
        return (!country.isEmpty) ? country[0] : IsoCountryInfo(name: "", numeric: "", alpha2: "", alpha3: "", calling: "", currency: "", continent: "")
    }
    
    class func searchByCurrency( currency:String ) -> [IsoCountryInfo] {
        let country = IsoCountries.allCountries.filter { $0.currency == currency }
        return country
    }
    
    class func searchByCallingCode( calllingCode:String ) -> IsoCountryInfo {
        let country = IsoCountries.allCountries.filter { $0.calling == calllingCode }
        return country[0]
    }
}

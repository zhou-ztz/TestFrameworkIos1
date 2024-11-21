//
// Created by Francis Yeap on 09/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation

typealias CountryCode = String
typealias LanguageCode = String
typealias GameCode = String


enum FeedCategoryOptionsType {
    case country(selections: [CountryEntity], preselection: CountryCode, onSelect: ((CountryCode) -> Void)?)
    case language(selections: [LanguageEntity], preselection: LanguageCode, onSelect: ((LanguageCode) -> Void)?)
}

struct CountryCategorySelector {
    var options: [CountryEntity] {
        return CountriesStoreManager().fetch()
    }
}

struct LanguageCategorySelector {
    var options: [LanguageEntity] {
        return LanguageStoreManager().fetch()
    }
}


// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

public extension Bool {
    init(value: String) {
        self.init(value == "1" || value.lowercased() == "true")
    }
}

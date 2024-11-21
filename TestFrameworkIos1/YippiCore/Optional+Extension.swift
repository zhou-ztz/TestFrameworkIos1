import Foundation

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped == String {
    public func or(_ val: String) -> String {
        guard let _string = self else { return String.empty }
        return val
    }
    
    public var orEmpty: String {
        guard let _string = self else { return String.empty }
        return _string
    }
}

extension Optional where Wrapped == Double {
    public var orZero: Double {
        guard let _double = self else { return 0.0 }
        return _double
    }
}


extension Optional where Wrapped == CGFloat {
    public var orZero: CGFloat {
        guard let _cgfloat = self else { return 0 }
        return _cgfloat
    }
}

extension Optional where Wrapped == Int {
        
    public var orInvalidateInt: Int {
        guard let _int = self else { return -1 }
        return _int
    }


    public var orZero: Int {
        guard let _int = self else { return 0 }
        return _int
    }
    
    public var stringValue: String {
        guard let _int = self else { return "" }
        return "\(_int)"
    }

}

extension Optional where Wrapped == Bool {
    
    public var orFalse: Bool {
        guard let _bool = self else { return false }
        return _bool
    }
    
}

import Foundation

public enum ApiResult<Value> {
    case success(Value)
    case failure(Error)
}

public enum ResultErrorWithValue<Value> {
    case success(Value)
    case failure(Value)
}
public typealias ResultCallback<Value> = (ApiResult<Value>) -> Void
public typealias ResultWithErrorCallback<Value> = (ResultErrorWithValue<Value>) -> Void

/// All successful responses return this, and contains all
/// the metainformation about the returned chunk.
public struct DataContainer<Results: Decodable>: Decodable {
    public let offset: Int
    public let limit: Int
    public let total: Int
    public let count: Int
    public let results: Results
}

/// Common object for images coming from the Marvel API
/// Shows how to fully conform to Decodable
public struct Image: Decodable {
    /// Server sends the remote URL splits in two: the path and the extension
    enum ImageKeys: String, CodingKey {
        case path = "path"
        case fileExtension = "extension"
    }
    
    /// The remote URL for this image
    public let url: URL
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImageKeys.self)
        
        let path = try container.decode(String.self, forKey: .path)
        let fileExtension = try container.decode(String.self, forKey: .fileExtension)
        
        guard let url = URL(string: "\(path).\(fileExtension)") else { throw APIError.decoding }
        
        self.url = url
    }
}

/// Dumb error to model simple errors
/// In a real implementation this should be more exhaustive
public enum APIError: Error {
    case encoding
    case decoding
    case server(code: Int, message: String)
    
    public var code: Int {
        switch self {
        case .server(let code, _):
            return code
        default:
            return -1 //TODO: Should be unexpected error message, debug show original message
        }
    }
    
    public var message: String {
        switch self {
        case .server( _, let message):
            return message
        default:
            return self.localizedDescription //TODO: Should be unexpected error message, debug show original message
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        let errorMessage: String
        switch code {
        default:
            errorMessage = self.message
            break
        }
        return errorMessage
    }
    
    public var localizedDescription: String {
        return errorDescription ?? ""
    }
}

@objc public extension NSError {
    var errorCode: Int {
        if self is APIError {
            return (self as! APIError).code
        }
        return 0
    }
    
    var errorMessage: String {
        if self is APIError {
            return (self as! APIError).localizedDescription
        }
        
        return localizedDescription
    }
}

/// Encodes any encodable to a URLQueryItem list
enum URLQueryItemEncoder {
    static func encode<T: Encodable>(_ encodable: T) throws -> [URLQueryItem] {
        let parametersData = try JSONEncoder().encode(encodable)
        let parameters = try JSONDecoder().decode([String: HTTPParameter].self, from: parametersData)
        return parameters.map { URLQueryItem(name: $0, value: $1.description) }
    }

    static func encodeAsDictionary<T: APIRequest>(_ encodable: T) throws -> [String: String] {
        let parametersData = try JSONEncoder().encode(encodable)
        let parameters = try JSONDecoder().decode([String: String].self, from: parametersData)
        if let excludedEncodeKeys = encodable.excludedEncodeKeys {
            return parameters.filter { !excludedEncodeKeys.contains($0.key) }
        }

        return parameters
    }
}

// Utility type so that we can decode any type of HTTP parameter
// Useful when we have mixed types in a HTTP request
enum HTTPParameter: CustomStringConvertible, Decodable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else {
            throw APIError.decoding
        }
    }
    
    var description: String {
        switch self {
        case .string(let string):
            return string
        case .bool(let bool):
            return String(describing: bool)
        case .int(let int):
            return String(describing: int)
        case .double(let double):
            return String(describing: double)
        }
    }
}

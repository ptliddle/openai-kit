
#if USE_NIO && canImport(NIOHTTP1)
import NIOHTTP1
import AsyncHTTPClient
#endif


import Foundation

protocol Request {
    var method: HTTPMethod { get }
    var scheme: API.Scheme { get }
    var host: String { get }
    var path: String { get }
    var body: Data? { get }
    var headers: HTTPHeaders { get }
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension Request {
    static var encoder: JSONEncoder { .requestEncoder }

    var scheme: API.Scheme { .https }
    var host: String { "api.openai.com" }
    var body: Data? { nil }
    
    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        return headers
    }
    
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .secondsSince1970 }
}

extension JSONEncoder {
    static var requestEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        // We have to turn off default encoding to snakecase as it breaks schema encoding.
        // Instead we use custom snake_case properties for encoding the OpenAI API payloads
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

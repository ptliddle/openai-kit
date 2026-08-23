
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
    
    // NOTE: See KNOWN_ISSUES.md for information about the key encoding/decoding strategy asymmetry.
    // The decoder uses .convertFromSnakeCase; the encoder does NOT use .convertToSnakeCase.
    // Types needing explicit snake_case keys for encoding must use a separate EncodingKeys enum
    // (see Chat.Message for an example). Do NOT add snake_case raw values to CodingKeys used for
    // decoding — they will break because .convertFromSnakeCase converts keys before matching.
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

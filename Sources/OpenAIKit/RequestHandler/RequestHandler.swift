import Foundation


protocol RequestHandler {
    var configuration: Configuration { get }
    func perform<T: Decodable>(request: Request) async throws -> T
    func stream<T: Decodable>(request: Request) async throws -> AsyncThrowingStream<T, Error>
}

extension RequestHandler {
    func generateURL(for request: Request) throws -> String {
        var components = URLComponents()
        components.scheme = configuration.api?.scheme.value ?? request.scheme.value
        components.host = configuration.api?.host ?? request.host
        components.path = [configuration.api?.path, request.path]
            .compactMap { $0 }
            .joined()
            
        guard let url = components.url else {
            throw RequestHandlerError.invalidURLGenerated
        }
    
        return url.absoluteString
    }
}

public struct DelegatedRequest {
    public var method: String
    public var scheme: String
    public var host: String
    public var path: String
    public var body: Data?
    public var headers: [String: String]
    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    
    init(from request: Request) {
        
        var headers = [String: String]()
        for header in request.headers {
            headers[header.0] = header.1
        }
        
        self = Self.init(method: request.method.rawValue,
                         scheme: request.scheme.value,
                         host: request.host,
                         path: request.path,
                         headers: headers,
                         body: request.body,
                         keyDecodingStrategy: request.keyDecodingStrategy,
                         dateDecodingStrategy: request.dateDecodingStrategy)
    }
    
    public init(method: String, scheme: String, host: String, path: String, headers: [String : String], body: Data? = nil, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
        self.method = method
        self.scheme = scheme
        self.host = host
        self.path = path
        self.body = body
        self.headers = headers
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }

}

public protocol DelegatedRequestHandler {
    var configuration: Configuration { get set }
    
    func perform<T: Decodable>(request: DelegatedRequest) async throws -> T
    func stream<T: Decodable>(request: DelegatedRequest) async throws -> AsyncThrowingStream<T, Error>
}

struct DelegatedRequestWrapper: RequestHandler {
    
    var configuration: Configuration = Configuration(apiKey: "N/A") // This is actually done in DelegatedRequestHandler but need this to adhere to existing RequestHandler protocol
    
    let handler: DelegatedRequestHandler
    
    func perform<T>(request: Request) async throws -> T where T : Decodable {
        try await handler.perform(request: DelegatedRequest(from: request))
    }
    
    func stream<T>(request: Request) async throws -> AsyncThrowingStream<T, Error> where T : Decodable {
        try await handler.stream(request: DelegatedRequest(from: request))
    }
}

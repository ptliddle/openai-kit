#if os(Linux)

import AsyncHTTPClient
import NIO
import NIOHTTP1
import NIOFoundationCompat
import Foundation

struct NIORequestHandler: RequestHandler {
    let httpClient: HTTPClient
    let configuration: Configuration
    let decoder: JSONDecoder
    
    init(
        httpClient: HTTPClient,
        configuration: Configuration,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.httpClient = httpClient
        self.configuration = configuration
        self.decoder = decoder
    }
    
    func perform<T: Decodable>(request: Request) async throws -> T {
        let url = try generateURL(for: request)
        
        let body: HTTPClient.Body? = {
            guard let data = request.body else { return nil }
            return .data(data)
        }()
        
        // On Linux, we need to convert between OpenAIKit and NIOHTTP1 types
        var nioHeaders = NIOHTTP1.HTTPHeaders()
        
        // Add configuration headers
        for (name, value) in configuration.headers {
            nioHeaders.add(name: name, value: value)
        }
        
        // Add request headers
        for (name, value) in request.headers {
            nioHeaders.add(name: name, value: value)
        }
        
        let nioMethod = NIOHTTP1.HTTPMethod(rawValue: request.method.rawValue)
        
        let response = try await httpClient.execute(
            request: HTTPClient.Request(
                url: url,
                method: nioMethod,
                headers: nioHeaders,
                body: body
            )
        ).get()
        
        
        guard let byteBuffer = response.body else {
            throw RequestHandlerError.responseBodyMissing
        }
        
        decoder.keyDecodingStrategy = request.keyDecodingStrategy
        decoder.dateDecodingStrategy = request.dateDecodingStrategy

        do {
            return try decoder.decode(T.self, from: byteBuffer)
        } catch {
            throw try decoder.decode(APIErrorResponse.self, from: byteBuffer)
        }
    }
    
    func stream<T: Decodable>(request: Request) async throws -> AsyncThrowingStream<T, Error> {
        
        let url = try generateURL(for: request)
        
        var httpClientRequest = HTTPClientRequest(url: url)
        

        // On Linux, we need to convert between OpenAIKit and NIOHTTP1 types
        // Add configuration headers
        for (name, value) in configuration.headers {
            httpClientRequest.headers.add(name: name, value: value)
        }
        
        // Add request headers
        for (name, value) in request.headers {
            httpClientRequest.headers.add(name: name, value: value)
        }
        
        httpClientRequest.method = NIOHTTP1.HTTPMethod(rawValue: request.method.rawValue)

        if let body = request.body {
            httpClientRequest.body = .bytes(body)
        }
        
        decoder.keyDecodingStrategy = request.keyDecodingStrategy
        decoder.dateDecodingStrategy = request.dateDecodingStrategy
        
        let response = try await httpClient.execute(httpClientRequest, timeout: .seconds(25))
        
        return AsyncThrowingStream<T, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await buffer in response.body {
                        String(buffer: buffer)
                            .components(separatedBy: "data: ")
                            .filter { $0 != "data: " }
                            .compactMap {
                                guard let data = $0.data(using: .utf8) else { return nil }
                                return try? decoder.decode(T.self, from: data)
                            }
                            .forEach { value in
                                continuation.yield(value)
                            }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

}
#endif

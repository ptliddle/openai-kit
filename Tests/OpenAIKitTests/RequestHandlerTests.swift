import XCTest

#if os(Linux)
import NIOHTTP1
import NIOPosix
import AsyncHTTPClient
#endif

@testable import OpenAIKit

final class RequestHandlerTests: XCTestCase {
    
#if os(Linux)
    private var httpClient: HTTPClient!
    
    override func setUp() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    }
    
    override func tearDownWithError() throws {
        try httpClient.syncShutdown()
    }
    
    private func requestHandler(
        configuration: Configuration
    ) -> RequestHandler {
        return NIORequestHandler(httpClient: httpClient, configuration: configuration)
    }
#else
    var urlSession: URLSession!
    
    override func setUp() {
        urlSession = URLSession(configuration: .default)
    }
    
    private func requestHandler(configuration: Configuration) -> RequestHandler {
        return URLSessionRequestHandler(session: urlSession, configuration: configuration)
    }
    
    override func tearDownWithError() throws {
        urlSession = nil
    }
#endif
    
    
    func test_generateURL_requestWithCustomValues() throws {
        let configuration = Configuration(apiKey: "TEST")
        
        let request = TestRequest(
            scheme: .custom("openai"),
            host: "chatgpt.is.cool",
            path: "/v1/i-know"
        )
        
        let url = try requestHandler(configuration: configuration).generateURL(for: request)
        
        XCTAssertEqual(url, "openai://chatgpt.is.cool/v1/i-know")
    }
    
    func test_generateURL_configWithCustomValues() throws {
        let api = API(scheme: .http, host: "chat.openai.com")
        let configuration = Configuration(apiKey: "TEST", api: api)
        
        let request = TestRequest(
            scheme: .https,
            host: "some-host",
            path: "/v1/test"
        )
        
        let url = try requestHandler(configuration: configuration).generateURL(for: request)
        
        XCTAssertEqual(url, "http://chat.openai.com/v1/test")
    }
    
}

private struct TestRequest: Request {
    let method: HTTPMethod = .GET
    let scheme: API.Scheme
    let host: String
    let path: String
}

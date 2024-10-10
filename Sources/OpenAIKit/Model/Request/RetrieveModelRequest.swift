#if os(Linux)
import NIOHTTP1
import AsyncHTTPClient
#endif

import Foundation

struct RetrieveModelRequest: Request {
    let method: HTTPMethod = .GET
    let path: String
    
    init(id: String) {
        self.path = "/v1/models/\(id)"
    }
}



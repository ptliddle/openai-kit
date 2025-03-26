#if USE_NIO
import NIOHTTP1
#endif

import Foundation

struct RetrieveFileContentRequest: Request {
    let method: HTTPMethod = .GET
    let path: String
    
    init(id: String) {
        self.path = "/v1/files/\(id)/content"
    }
}


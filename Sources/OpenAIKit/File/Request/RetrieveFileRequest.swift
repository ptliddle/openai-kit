#if os(Linux)
import NIOHTTP1
#endif

import Foundation

struct RetrieveFileRequest: Request {
    let method: HTTPMethod = .GET
    let path: String
    
    init(id: String) {
        self.path = "/v1/files/\(id)"
    }
}



#if USE_NIO
import NIOHTTP1
#endif

import Foundation

struct DeleteFileRequest: Request {
    let method: HTTPMethod = .DELETE
    let path: String
    
    init(id: String) {
        self.path = "/v1/files/\(id)"
    }
}


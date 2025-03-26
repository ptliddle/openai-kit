import Foundation

#if USE_NIO
import NIOHTTP1
#endif

struct ListFilesRequest: Request {
    let method: HTTPMethod = .GET
    let path = "/v1/files"
}

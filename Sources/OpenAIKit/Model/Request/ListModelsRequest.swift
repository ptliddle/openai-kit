#if os(Linux)
import NIOHTTP1
import AsyncHTTPClient
#endif

import Foundation

struct ListModelsRequest: Request {
    let method: HTTPMethod = .GET
    let path = "/v1/models"
}


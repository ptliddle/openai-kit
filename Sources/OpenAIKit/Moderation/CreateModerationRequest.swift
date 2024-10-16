#if os(Linux)
import NIOHTTP1
import AsyncHTTPClient
#endif

import Foundation

struct CreateModerationRequest: Request {
    let method: HTTPMethod = .POST
    let path = "/v1/moderations"
    let body: Data?
    
    init(
        input: String,
        model: Moderation.Model
    ) throws {
        
        let body = Body(
           input: input,
           model: model
        )
                
        self.body = try Self.encoder.encode(body)
    }
}

extension CreateModerationRequest {
    struct Body: Encodable {
        let input: String
        let model: Moderation.Model
    }
}


#if os(Linux)
import NIOHTTP1
import AsyncHTTPClient
#endif


import Foundation
import SwiftyJsonSchema

struct CreateEmbeddingRequest: Request {
    let method: HTTPMethod = .POST
    let path = "/v1/embeddings"
    let body: Data?
    
    init(
        model: String,
        input: [String],
        user: String?
    ) throws {
        
        let body = Body(
            model: model,
            input: input,
            user: user
        )
                
        self.body = try Self.encoder.encode(body)
    }
}

extension CreateEmbeddingRequest {
    struct Body: Encodable {
        let model: String
        let input: [String]
        let user: String?
    }
}

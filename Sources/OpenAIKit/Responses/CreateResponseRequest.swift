import Foundation

struct CreateResponseRequest: Request {

    
    var method: HTTPMethod = .POST
    var path: String { "/v1/responses" }
  
    let body: Data?

    init(
        model: String,
        input: ResponseInput,
        include: [String]? = nil,
        instructions: String? = nil,
        previousResponseId: String? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        metadata: [String: String]? = nil,
        topP: Double? = nil,
        tools: [Tool]? = nil,
        user: String? = nil,
        method: HTTPMethod = .POST
    ) {
        self.method = method
        
        let body = Body(
            model: model,
            input: input,
            include: include,
            instructions: instructions,
            previousResponseId: previousResponseId,
            maxTokens: maxTokens,
            temperature: temperature,
            metadata: metadata,
            topP: topP,
            tools: tools,
            user: user
        )
        
        self.body = try? Self.encoder.encode(body)
    }
}



extension CreateResponseRequest {
    struct Body: Encodable {
        
        let model: String
        let input: ResponseInput
        let include: [String]?
        let instructions: String?
        let previousResponseId: String?
        let maxTokens: Int?
        let temperature: Double?
        let metadata: [String: String]?
        let parallelToolCalls: Bool = true
        let store: Bool = true
        let topP: Double?
        let tools: [Tool]?
        let user: String?
            
        enum CodingKeys: String, CodingKey {
            case model
            case input
            case include
            case instructions
            case previousResponseId = "previous_response_id"
            
            case temperature
            case topP = "top_p"
            case n
            case stream
            case stop
            case maxTokens = "max_output_tokens"
            case user
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            
            try container.encode(input, forKey: .input)
            
            try container.encodeIfPresent(include, forKey: .include)

            try container.encode(temperature, forKey: .temperature)
            try container.encode(topP, forKey: .topP)

            if let maxTokens {
                try container.encode(maxTokens, forKey: .maxTokens)
            }
            
            try container.encodeIfPresent(user, forKey: .user)
        }
    }
}


struct RetrieveResponseRequest: Request {
    let responseId: String
    
    var method: HTTPMethod = .GET
    var path: String { "/v1/responses/\(responseId)" }
}

struct ListResponsesRequest: Request {
    let limit: Int?
    let before: String?
    let after: String?
    
    var method: HTTPMethod = .GET
    var path: String { "/v1/responses" }
    
    var body: Data? {
        var params: [String: Any] = [:]
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        if let before = before {
            params["before"] = before
        }
        
        if let after = after {
            params["after"] = after
        }
        
        if params.isEmpty {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: params)
    }
}

public struct Tool: Codable {
    public let type: ToolType
    
    public enum ToolType: String, Codable {
        case webSearch = "web_search"
        case fileSearch = "file_search"
    }
}

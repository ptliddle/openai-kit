import Foundation

#if USE_NIO
import NIOHTTP1
#endif

public struct CreateResponseRequest: Request {
    
    public enum ResponseFormat: Encodable {
        case text
        case jsonObject
        case jsonSchema(JSONSchema, String)
        
        enum CodingKeys: String, CodingKey {
            case type
            case name
            case strict
            case schema
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Encode the type property inside the parent container
            switch self  {
            case .text:
                try container.encode("text", forKey: .type)
            case .jsonObject:
                try container.encode("json_object", forKey: .type)
            case .jsonSchema(let (schema, name)):
                try container.encode("json_schema", forKey: .type)
                try container.encode(name, forKey: .name)
                try container.encode(true, forKey: .strict)
                try container.encode(schema, forKey: .schema)
            }
            
        }
    }
    
    
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
        responseFormat: ResponseFormat? = nil,
        metadata: [String: String]? = nil,
        store: Bool = true,
        topP: Double? = nil,
        tools: [Tool]? = nil,
        user: String? = nil,
        method: HTTPMethod = .POST,
        reasoningEffort: String?
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
            responseFormat: responseFormat,
            metadata: metadata,
            store: store,
            topP: topP,
            tools: tools,
            user: user, 
            reasoningEffort: reasoningEffort
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
        let responseFormat: CreateResponseRequest.ResponseFormat?
        let metadata: [String: String]?
        let parallelToolCalls: Bool = true
        let store: Bool
        let topP: Double?
        let tools: [Tool]?
        let user: String?
        let reasoningEffort: String?
            
        enum CodingKeys: String, CodingKey {
            case model
            case input
            case include
            case instructions
            case previousResponseId = "previous_response_id"
            case text
            case temperature
            case topP = "top_p"
            case tools
            case n
            case stream
            case stop
            case store
            case maxTokens = "max_output_tokens"
            case user
            case reasoning
        }
        
        
        struct Text: Encodable {
            var format: ResponseFormat?
        }
        
        enum ReasoningKeys: String, CodingKey {
            case effort
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            
            try container.encode(input, forKey: .input)
            
            if let reasoningEffort = reasoningEffort {
                var nestedContainer = container.nestedContainer(keyedBy: ReasoningKeys.self, forKey: .reasoning)
                try nestedContainer.encodeIfPresent(reasoningEffort, forKey: .effort)
            }
            
            try container.encodeIfPresent(include, forKey: .include)
            
            try container.encodeIfPresent(instructions, forKey: .instructions)
            
            try container.encodeIfPresent(previousResponseId, forKey: .previousResponseId)
            
            try container.encode(store, forKey: .store)

            try container.encode(temperature, forKey: .temperature)
            
            if let responseFormat = responseFormat {
                try container.encode(Text(format: responseFormat), forKey: .text)
            }
            
            try container.encode(topP, forKey: .topP)
            
            try container.encodeIfPresent(tools, forKey: .tools)

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

/// This is a type for handing codable objects through directly to an API
/// This allows the library to not have to worry about the specific implementation details just that it can be converted to JSON for sending
/// and the response can be decoded
public struct ErasedCodable: Codable {

    var codable: Codable
    
    enum CodingKeys: CodingKey {
        case cType
        case codable
    }
    
    public init(with codable: Codable) {
        self.codable = codable
    }
    
    public init(from decoder: any Decoder) throws {
        // For decode we through and error
        fatalError("Decoding a wrapped codable is not currently supported, grab the data and decode directly")
    }
    
    // For encoding we just grab the container and call encode on the wrapped type
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
}

public struct Tool: Encodable {
    
    public enum ToolType: String, Codable {
        case webSearch = "web_search"
        case fileSearch = "file_search"
        case function = "function"
    }
    
    public let type: ToolType
    public let name: String
    public let description: String
    public let parameters: ErasedCodable // This should be a json schema
    
    public init(type: ToolType, name: String, description: String, parameters: ErasedCodable) {
        self.type = type
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

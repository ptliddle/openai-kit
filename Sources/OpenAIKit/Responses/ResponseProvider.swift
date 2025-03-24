import Foundation

public struct ResponseProvider {
    private let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }

    /**
     Create a response with structured messages
     POST
      
     https://api.openai.com/v1/responses
     
     Creates a response for the provided input messages and parameters
     */
    public func create(
        model: ModelID,
        messages: [InputMessage],
        include: [String]? = nil,
        instructions: String? = nil,
        previousResponseId: String? = nil,
        temperature: Double? = nil,
        responseFormat: CreateResponseRequest.ResponseFormat? = nil,
        topP: Double? = nil,
        maxTokens: Int? = nil,
        metadata: [String: String]? = nil,
        store: Bool = true,
        tools: [Tool]? = nil,
        user: String? = nil
    ) async throws -> Response {
        let request = CreateResponseRequest(
            model: model.id,
            input: .message(messages),
            include: include,
            instructions: instructions,
            previousResponseId: previousResponseId,
            maxTokens: maxTokens,
            temperature: temperature,
            responseFormat: responseFormat, //CreateResponseRequest.ResponseFormat(from: responseFormat),
            metadata: metadata,
            store: store,
            topP: topP,
            tools: tools,
            user: user,
            method: .POST
        )
        
        return try await requestHandler.perform(request: request)
    }
    
    /**
     Retrieve a response
     GET
      
     https://api.openai.com/v1/responses/{response_id}
     
     Retrieves a response by its ID
     */
    public func retrieve(responseId: String) async throws -> Response {
        let request = RetrieveResponseRequest(responseId: responseId)
        return try await requestHandler.perform(request: request)
    }
    
    /**
     List responses
     GET
      
     https://api.openai.com/v1/responses
     
     Lists responses created by the user
     */
    public func list(
        limit: Int? = nil,
        before: String? = nil,
        after: String? = nil
    ) async throws -> ResponseList {
        let request = ListResponsesRequest(
            limit: limit,
            before: before,
            after: after
        )
        
        return try await requestHandler.perform(request: request)
    }
}

public struct ResponseList: Codable {
    public let object: String
    public let data: [Response]
    public let firstId: String
    public let lastId: String
    public let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case object, data
        case firstId = "first_id"
        case lastId = "last_id"
        case hasMore = "has_more"
    }
}

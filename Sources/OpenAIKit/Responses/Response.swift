import Foundation

/**
 Represents a response from the OpenAI Responses API.
 */
public struct Response: Codable {
    
    public struct Usage: Codable {
        
        public struct Details: Codable {
            public let cachedTokens: Int?
            public let reasoningTokens: Int?
        }
        
        public let inputTokens: Int
        public let inputTokensDetails: Details
        public let outputTokens: Int
        public let outputTokensDetails: Details
        public let totalTokens: Int
    }
    
    public let id: String
    public let object: String
    public let createdAt: Date
    public let status: String
    public let error: ResponseError?
    public let incompleteDetails: IncompleteDetails?
    public let instructions: String?
    public let maxOutputTokens: Int?
    public let model: String
    public let output: [OutputItem]
    public let parallelToolCalls: Bool
    public let previousResponseId: String?
    public let reasoning: Reasoning
    public let store: Bool
    public let temperature: Double
    public let text: TextFormat
    public let toolChoice: String
    public let tools: [ResponseTool]
    public let topP: Double
    public let truncation: String
    public let usage: Usage
    public let user: String?
    public let metadata: [String: String]?
    
    public struct ResponseError: Codable {
        public let code: String?
        public let message: String?
    }
    
    public struct IncompleteDetails: Codable {
        public let reason: String?
    }
    
    public struct Reasoning: Codable {
        public let effort: String?
        public let generateSummary: Bool?
    }
    
    public struct TextFormat: Codable {
        public let format: Format
        
        public struct Format: Codable {
            public let type: String
        }
    }
    
    // Renamed to ResponseTool to avoid conflicts with Tool in CreateResponseRequest
    public struct ResponseTool: Codable {
        public let type: String
        public let function: ToolFunction?
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt
        case status
        case error
        case incompleteDetails
        case instructions
        case maxOutputTokens 
        case model
        case output
        case parallelToolCalls
        case previousResponseId
        case reasoning
        case store
        case temperature
        case text
        case toolChoice 
        case tools
        case topP 
        case truncation
        case usage
        case user
        case metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        object = try container.decode(String.self, forKey: .object)
        
        // Handle timestamp conversion to Date
        let timestamp = try container.decode(Int.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        status = try container.decode(String.self, forKey: .status)
        error = try container.decodeIfPresent(ResponseError.self, forKey: .error)
        incompleteDetails = try container.decodeIfPresent(IncompleteDetails.self, forKey: .incompleteDetails)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        maxOutputTokens = try container.decodeIfPresent(Int.self, forKey: .maxOutputTokens)
        model = try container.decode(String.self, forKey: .model)
        output = try container.decode([OutputItem].self, forKey: .output)
        parallelToolCalls = try container.decode(Bool.self, forKey: .parallelToolCalls)
        previousResponseId = try container.decodeIfPresent(String.self, forKey: .previousResponseId)
        reasoning = try container.decode(Reasoning.self, forKey: .reasoning)
        store = try container.decode(Bool.self, forKey: .store)
        temperature = try container.decode(Double.self, forKey: .temperature)
        text = try container.decode(TextFormat.self, forKey: .text)
        toolChoice = try container.decode(String.self, forKey: .toolChoice)
        tools = try container.decode([ResponseTool].self, forKey: .tools)
        topP = try container.decode(Double.self, forKey: .topP)
        truncation = try container.decode(String.self, forKey: .truncation)
        usage = try container.decode(Usage.self, forKey: .usage)
        user = try container.decodeIfPresent(String.self, forKey: .user)
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(object, forKey: .object)
        
        // Convert Date back to timestamp
        let timestamp = Int(createdAt.timeIntervalSince1970)
        try container.encode(timestamp, forKey: .createdAt)
        
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(error, forKey: .error)
        try container.encodeIfPresent(incompleteDetails, forKey: .incompleteDetails)
        try container.encodeIfPresent(instructions, forKey: .instructions)
        try container.encodeIfPresent(maxOutputTokens, forKey: .maxOutputTokens)
        try container.encode(model, forKey: .model)
        try container.encode(output, forKey: .output)
        try container.encode(parallelToolCalls, forKey: .parallelToolCalls)
        try container.encodeIfPresent(previousResponseId, forKey: .previousResponseId)
        try container.encode(reasoning, forKey: .reasoning)
        try container.encode(store, forKey: .store)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(text, forKey: .text)
        try container.encode(toolChoice, forKey: .toolChoice)
        try container.encode(tools, forKey: .tools)
        try container.encode(topP, forKey: .topP)
        try container.encode(truncation, forKey: .truncation)
        try container.encode(usage, forKey: .usage)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}



// MARK: - OutputItem
public struct OutputItem: Codable {
    public let id: String
    public let type: String
    public let status: String?
    public let role: String?
    public let content: [ResponseContent]?
    public let summary: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, type, status, role, content, summary
    }
}

// MARK: - ResponseContent
public struct ResponseContent: Codable {
    public let type: String
    public let text: String?
    public let annotations: [Annotation]?
    public let toolCalls: [ToolCall]?
    
    enum CodingKeys: String, CodingKey {
        case type, text, annotations
        case toolCalls = "tool_calls"
    }
}

// MARK: - Annotation
public struct Annotation: Codable {
    // Add properties as needed for annotations
}

// MARK: - ToolCall
public struct ToolCall: Codable {
    public let id: String
    public let type: String
    public let name: String?
    public let args: [String: String]?
    public let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, name, args, status
    }
}

// MARK: - ToolFunction
public struct ToolFunction: Codable {
    public let name: String
    public let description: String?
    public let parameters: ParametersObject?
    
    enum CodingKeys: String, CodingKey {
        case name, description, parameters
    }
    
    public struct ParametersObject: Codable {
        // This is a placeholder to handle the JSON schema parameters
        // In a real implementation, you might want to parse this more specifically
        public let properties: [String: String]?
        public let type: String?
        public let required: [String]?
    }
}

// MARK: - Extensions for convenience methods
extension OutputItem {
    public var contentText: String? {
        guard let content = content else { return nil }
        return content.compactMap { item in
            return item.text
        }.joined(separator: "\n")
    }
}

extension ResponseContent {
    public var isText: Bool {
        return type == "output_text"
    }
    
    public var isToolCall: Bool {
        return type == "tool_calls"
    }
}

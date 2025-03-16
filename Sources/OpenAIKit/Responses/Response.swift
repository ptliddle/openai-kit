import Foundation

/**
 Represents a response from the OpenAI Responses API.
 */
public struct Response {
    
    public struct Usage: Codable {
        
        public struct Details: Codable {
            var cachedTokens: Int? = 0
            var reasoningTokens: Int? = 0
        }
        
        public var inputTokens: Int = 0
        
        public var inputTokensDetails: Details
        
        public var outputTokens: Int = 0
        
        public var outputTokensDetails: Details
        
        public var totalTokens: Int = 0
    }
    
    public let id: String
    public let object: String
    public let createdAt: Date
    public let status: String
    public let error: String?
    public let incompleteDetails: String?
    public let instructions: String?
    public let maxOutputTokens: Int?
    public let model: String
    public let output: [Message]
    public let parallelToolCalls: Bool
    public let previousResponseId: String?
    public let reasoning: Reasoning
    public let store: Bool
    public let temperature: Double
    public let text: TextFormat
    public let toolChoice: String
    public let tools: [Tool]
    public let topP: Double
    public let truncation: String
    public let usage: Self.Usage
    public let user: String?
    public let metadata: [String: String]
    
    public struct Reasoning: Codable {
        public let effort: String?
        public let summary: String?
    }
    
    public struct TextFormat: Codable {
        public let format: Format
        
        public struct Format: Codable {
            public let type: String
        }
    }
}



extension Response: Codable {}

extension Response {
    public struct Message: Codable {
        public let id: String
        public let role: Role
        public let content: [Content]
        public let type: String
        
        public enum Role: String, Codable {
            case user
            case assistant
            case system
        }
        
        public var contentText: String {
            return self.content.compactMap { content in
                guard case let .outputText(string) = content else {
                    return "TOOL CALL HERE"
                }
                return string
            }.joined(separator: "\n")
        }
    }
}

extension Response {
    public enum Content: Codable {
        case outputText(String)
        case toolCall(ToolCall)
        
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case annotations
            case toolCalls = "tool_calls"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "output_text":
                let text = try container.decode(String.self, forKey: .text)
                self = .outputText(text)
            case "tool_calls":
                let toolCall = try container.decode(ToolCall.self, forKey: .toolCalls)
                self = .toolCall(toolCall)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .outputText(let text):
                try container.encode("output_text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .toolCall(let toolCall):
                try container.encode("tool_calls", forKey: .type)
                try container.encode(toolCall, forKey: .toolCalls)
            }
        }
    }
}

extension Response {
    public struct ToolCall: Codable {
        public let id: String
        public let type: String
        public let status: Status
        
        public enum Status: String, Codable {
            case completed
            case inProgress = "in_progress"
            case failed
        }
    }
}

import Foundation

/**
 Represents a response from the OpenAI Responses API.
 */
public struct Response {
    public let id: String
    public let object: String
    public let createdAt: Date
    public let status: String
    public let model: String
    public let input: [Message]
    public let output: [Message]
    public let usage: Usage
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

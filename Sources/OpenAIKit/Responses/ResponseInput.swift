import Foundation

/**
 Represents the input for the Responses API.
 */
public enum ResponseInput: Codable {
    case string(String)
    case messages([InputItem])
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let text):
            try container.encode(text)
        case .messages(let messages):
            try container.encode(messages)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            self = .string(text)
        } else if let messages = try? container.decode([InputItem].self) {
            self = .messages(messages)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode ResponseInput")
        }
    }
}

public enum InputItem: Codable {
    case message(InputMessage)
    case reasoning(Reasoning)
    
    case toolCall(ToolCall)
    case toolOutput(ToolOutputContent)
    
    
    enum CodingKeys: CodingKey {
        case message
        case toolOutput
        case toolCall
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        if let message = try? container.decodeIfPresent(InputMessage.self) {
            self = .message(message)
        }
        else if let toolOutput = try? container.decodeIfPresent(ToolOutputContent.self) {
            self = .toolOutput(toolOutput)
        }
        else if let toolCall = try? container.decodeIfPresent(ToolCall.self) {
            self = .toolCall(toolCall)
        }
        else if let reasoning = try? container.decodeIfPresent(Reasoning.self) {
            self = .reasoning(reasoning)
        }
        else {
            throw DecodingError.typeMismatch(InputItem.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No valid InputItem was found"))
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .message(let message):
            try container.encode(message)
        case .toolOutput(let toolOutput):
            try container.encode(toolOutput)
        case .toolCall(let toolCall):
            try container.encode(toolCall)
        case .reasoning(let reasoning):
            try container.encode(reasoning)
        }
    }
}

public struct InputMessage: Codable {
    public let role: Role
    public let content: [Response.MessageContent]
    
    public init(role: Role, content: [Response.MessageContent]) {
        self.role = role
        self.content = content
    }
    
    public enum Role: String, Codable {
        case user
        case assistant
        case system
    }
}

extension Response {
    
    public enum MessageContent: Codable {
        
        case inputText(String)
        case inputImage(url: String)
        case inputFile(String)
        
        case outputText(String)     // Represents input text that was previously output by AI, the responses API requires us to differentiate
        
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case imageUrl  = "image_url"
            case fileId = "file_id"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "input_text":
                let text = try container.decode(String.self, forKey: .text)
                self = .inputText(text)
            case "output_text":
                let text = try container.decode(String.self, forKey: .text)
                self = .outputText(text)
            case "input_image":
                let imageUrl = try container.decode(String.self, forKey: .imageUrl)
                self = .inputImage(url: imageUrl)
            case "input_file":
                let fileId = try container.decode(String.self, forKey: .fileId)
                self = .inputFile(fileId)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .inputText(let text):
                try container.encode("input_text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .outputText(let text):
                try container.encode("output_text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .inputImage(let imageUrl):
                try container.encode("input_image", forKey: .type)
                try container.encode(imageUrl, forKey: .imageUrl)
            case .inputFile(let fileId):
                try container.encode("input_file", forKey: .type)
                try container.encode(fileId, forKey: .fileId)
            }
        }
    }
}

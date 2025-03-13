import Foundation

/**
 Given a prompt, the model will return one or more predicted chat completions, and can also return the probabilities of alternative tokens at each position.
 */
public struct Chat {
    public let id: String
    public let object: String
    public let created: Date
    public let model: String
    public let choices: [Choice]
    public let usage: Usage
}

extension Chat: Codable {}

extension Chat {
    public struct Choice {
        public let index: Int
        public let message: Message
        public let finishReason: FinishReason?
    }
}

extension Chat.Choice: Codable {}

public enum MessageContent: Hashable, Codable {
    case string(String)
    case verbatim(String)
    case fileId(String)
    
    enum CodingKeys: CodingKey {
        case type
        case text
        case fileId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        var allKeys = ArraySlice(container.allKeys)
//        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
//            throw DecodingError.typeMismatch(MessageContent.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
//        }
//        switch onlyKey {
//        case .string:
//            let nestedContainer = try container.nestedContainer(keyedBy: MessageContent.StringCodingKeys.self, forKey: .string)
//            self = MessageContent.string(try nestedContainer.decode(String.self, forKey: MessageContent.StringCodingKeys._0))
//        case .verbatim:
//            let nestedContainer = try container.nestedContainer(keyedBy: MessageContent.VerbatimCodingKeys.self, forKey: .verbatim)
//            self = MessageContent.verbatim(try nestedContainer.decode(String.self, forKey: MessageContent.VerbatimCodingKeys._0))
//        case .fileId:
//            let nestedContainer = try container.nestedContainer(keyedBy: MessageContent.FileIdCodingKeys.self, forKey: .fileId)
//            self = MessageContent.fileId(try nestedContainer.decode(String.self, forKey: MessageContent.FileIdCodingKeys._0))
//        }
        
        let type = try container.decode(String?.self, forKey: .type)

        switch type {
      
        case Optional.none:
            var sContainer = try decoder.singleValueContainer()
            let text = try sContainer.decode(String.self)
            self = .verbatim(text)
        case .some(let subtype):
            switch subtype {
            case "input_text":
                let text = try container.decode(String.self, forKey: .text)
                self = .string(text)
            case "input_file":
                let fileId = try container.decode(String.self, forKey: .text)
                self = .fileId(fileId)
            default:
                throw NSError(domain: "Unknown type", code: 0)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let text):
            try container.encode("input_text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .verbatim(let verbatim):
            var sContainer = encoder.singleValueContainer()
            try sContainer.encode(verbatim)
        case .fileId(let fileId):
            try container.encode("input_file", forKey: .type)
            try container.encode(fileId, forKey: .fileId)
        }
    }
}

extension Chat {
    public enum Message: Hashable {
        case system(content: String)
        case user(content: MessageContent)
        case assistant(content: String)
    }
}

extension Chat.Message: Codable {
    public enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let role = try container.decode(String.self, forKey: .role)
        let content = try container.decode(String.self, forKey: .content)
        switch role {
        case "system":
            self = .system(content: content)
        case "user":
            self = .user(content: MessageContent.string(content))
        case "assistant":
            self = .assistant(content: content)
        default:
            throw DecodingError.dataCorruptedError(forKey: .role, in: container, debugDescription: "Invalid type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .system(let content):
            try container.encode("system", forKey: .role)
            try container.encode(content, forKey: .content)
        case .user(let content):
            try container.encode("user", forKey: .role)
            switch content {
            case .verbatim(let vText):
                try container.encode(vText, forKey: .content)
            case .string(let text):
                try container.encode(text, forKey: .content)
            case .fileId(let fileId):
                try container.encode(fileId, forKey: .content)
            }
        case .assistant(let content):
            try container.encode("assistant", forKey: .role)
            try container.encode(content, forKey: .content)
        }
    }
}

extension Array<Chat.Message>: Codable {
    public func encode(to encoder: Encoder) throws {
        if self.count == 1 {
            print("encodde 1")
        }
        else {
            print("Gabd")
        }
    }
}

extension Chat.Message {
    public var content: String {
        get {
            switch self {
            case .system(let content), .assistant(let content):
                return content
            case .user(let content):
                guard case let MessageContent.string(text) = content else {
                    return "No string content"
                }
                return text
            }
        }
        set {
            switch self {
            case .system: self = .system(content: newValue)
            case .user: self = .user(content: .string(newValue))
            case .assistant: self = .assistant(content: newValue)
            }
        }
    }
}

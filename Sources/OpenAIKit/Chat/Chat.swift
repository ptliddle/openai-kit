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

extension Chat {
    public enum Message: Hashable {
        case system(content: String)
        case user(content: ContentOption)
        case assistant(content: AssistantContentOption)
        case tool(content: String, toolCallId: ToolID)
    }
}

extension Chat.Message {
    
    public typealias ToolID = String
    
    public enum AssistantContentOption: Hashable, Codable {
        case text(String)
        case toolCalls([Chat.ToolCall], String?, ToolID?)
    }
}

extension Chat {
    public struct ToolCall: Hashable, Codable {
        public let index: Int?
        public let id: String
        public let type: String
        public let function: Function
    }
}

extension Chat.ToolCall {
    public struct Function: Hashable, Codable {
        public let name: String
        public let arguments: String
    }
}

extension Chat {
    public struct FunctionCall: Hashable, Codable {
        public let name: String
        public let arguments: String
    }
}

extension Chat.Message {
    
    //        {
    //            "role": "user",
    //            "content": [
    //              {
    //                "type": "text",
    //                "text": "What is in this image?"
    //              },
    //              {
    //                "type": "image_url",
    //                "image_url": {
    //                  "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
    //                }
    //              }
    //            ]
    //          }
    
    public enum ContentOption: Hashable, Codable {
        
        case text(String)
        case content([MessageContent])
        
        private enum CodingKeys: String, CodingKey {
            case type
            case text
            case content
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Chat.Message.ContentOption.CodingKeys.self)
            
            // Try
            do {
                // Try and decode as text
                let textContent = try container.decode(String.self, forKey: .content)
                self = .text(textContent)
            }
            catch let error as DecodingError {
                print(error)
                // Try as content
                let content = try container.decode([MessageContent].self, forKey: .content)
                self = .content(content)
            }
        }
        
        enum ContentCodingKeys: String, CodingKey {
            case type
            case text
            case imageUrl = "image_url"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer() //.container(keyedBy: CodingKeys.self)
            switch self {
            case .text(let text):
                try container.encode(text)
            case .content(let content):
                try container.encode(content) //, forKey: .content)
            }
        }
    }
    
    public enum MessageContent: Hashable, Codable {
        case text(String)
        
        case imageUrl(String)
        case audioUrl(String)
        
        case image(Data, String)
        case audio(Data)
        // Add more cases as needed for different content types
        
        private enum CodingKeys: String, CodingKey {
            case type
            case text
            case imageUrl = "image_url"
            case audioUrl = "audio_url"
            
            var snakeCase: String {
                switch self {
                case .audioUrl:
                    return "audio_url"
                case .imageUrl:
                    return "image_url"
                default:
                    return self.rawValue
                }
            }
        }
        
        // Struct to represent flexible content object
        struct ContentObject: Decodable {
            let type: String
            
            // Dynamic content fields based on type
            let text: String?
            let imageUrl: String?
            let audioUrl: String?
            
            // Additional fields can be added as needed
        }
        
        private static func extractAudioDetails(fromUrl url: String) throws -> MessageContent {
            // If we have a standard url extract it and return imageUrl
            if let urlcomps = URLComponents(string: url), (urlcomps.scheme == "http" || urlcomps.scheme == "https") {
                return .audioUrl(url)
            }
            else {
                fatalError("We need to implement decoding base64 audio")
            }
        }
        
        private static func extractImageDetails(fromUrl url: String) throws -> MessageContent {
   
            // If we have a standard url extract it and return imageUrl
            if let urlcomps = URLComponents(string: url), (urlcomps.scheme == "http" || urlcomps.scheme == "https") {
                return .imageUrl(url)
            }
            else {
                
                // If we have base64 encoded data
                // "image_url": f"data:image/jpeg;base64,{base64_image}",
                
                guard let prefixRange = url.range(of: "data:image/", options: .anchored) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.imageUrl], debugDescription: "url does not contain data:image"))
                }
                
                guard let nextOccurrenceIndex = url[prefixRange.upperBound...].firstIndex(of: ";") else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.imageUrl], debugDescription: "url does not contain data:image"))
                }
                
                let imageType = String(url[prefixRange.upperBound..<nextOccurrenceIndex])
                
                guard let base64PrefixRange = url[nextOccurrenceIndex...].range(of: "base64,") else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.imageUrl], debugDescription: "url does not contain base64"))
                }
                
                let base64String = url[base64PrefixRange.upperBound...]
                guard let data = Data(base64Encoded: String(base64String)) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.imageUrl], debugDescription: "Expected base64 data"))
                }
                return .image(data, imageType)
            }
        }
        
        enum ImageURLKeys: CodingKey {
            case url
        }
        
        // Decode to handle different structures of content objects
        public init(from decoder: Decoder) throws {
            
//        {
//            "role": "user",
//            "content": [
//              {
//                "type": "text",
//                "text": "What is in this image?"
//              },
//              {
//                "type": "image_url",
//                "image_url": {
//                  "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
//                }
//              }
//            ]
//        }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case CodingKeys.text.snakeCase:
                guard let decodedText = try container.decodeIfPresent(String.self, forKey: .text) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.text], debugDescription: "No text data exists in message"))
                }
                self = .text(decodedText)
            case CodingKeys.imageUrl.snakeCase:
                let imageContainer = try container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageUrl)
                guard let imageUrl = try imageContainer.decodeIfPresent(String.self, forKey: .url) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.imageUrl], debugDescription: "No image url exists in message"))
                }
                self = try Self.extractImageDetails(fromUrl: imageUrl)
            case CodingKeys.audioUrl.snakeCase:
                self = .audioUrl("NONE")
                break
            default:
                print("Unknown type")
                throw NSError(domain: "No known type to decode", code: 0)
            }
        }
        
        private enum ImageTypeKeys: String, CodingKey {
            case type = "type"
            case imageUrl = "image_url"
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .text(let text):
                try container.encode(CodingKeys.text.snakeCase, forKey: .type)
                try container.encode(text, forKey: .text)
            case .imageUrl(let url):
                var nestedContainer = container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageUrl)
                try container.encode(CodingKeys.imageUrl.snakeCase, forKey: .type)
                try nestedContainer.encode(url, forKey: .url)
            case .image(let data, let imageType):
                
                var nestedContainer = container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageUrl)
                try container.encode(CodingKeys.imageUrl.snakeCase, forKey: .type)
      
                
//                var topContainer = encoder.unkeyedContainer()
//                var container = topContainer.nestedContainer(keyedBy: ImageTypeKeys.self)
                let imageUrl = "data:image/\(imageType);base64,\(data.base64EncodedString())"
                try nestedContainer.encode(imageUrl, forKey: .url)
                
//                try container.encode("image_url", forKey: .type)
//                var urlContainer = container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageUrl)
//                try urlContainer.encode(imageUrl, forKey: .url)
            case  .audioUrl(let url):
                fatalError("Audio url encoding not implemented")
                break
            case .audio(let data):
                fatalError("Audio data encoding is not implemented")
            default:
                fatalError("Unknown type")
            }
        }
    }
}

extension Chat.Message: Codable {
    private enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls
        case toolCallId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let role = try container.decode(String.self, forKey: .role)

        switch role {
        case "system":
            let text = try container.decode(String.self, forKey: .content)
            self = .system(content: text)
        case "user":
            do {
                let text = try container.decode(String.self, forKey: .content)
                self = .user(content: .text(text))
            }
            catch let DecodingError.typeMismatch(type, context) where type == String.self {
                let newContent = try container.decode([MessageContent].self, forKey: .content)
                self = .user(content: .content(newContent))
            }
            catch {
                throw error
            }
        case "assistant":
            let toolCalls = try container.decodeIfPresent([Chat.ToolCall].self, forKey: .toolCalls)
            let toolCallId = try container.decodeIfPresent(String.self, forKey: .toolCallId)
            let text = (try? container.decodeIfPresent(String.self, forKey: .content)) ?? ""
            if let toolCalls, !toolCalls.isEmpty {
                self = .assistant(content: .toolCalls(toolCalls, text, toolCallId))
            }
            else {
                self = .assistant(content: .text(text))
            }
        case "tool":
            let content = try container.decode(String.self, forKey: .content)
            guard let toolCallId = try container.decodeIfPresent(String.self, forKey: .toolCallId) else {
                throw DecodingError.keyNotFound(CodingKeys.toolCallId, .init(codingPath: decoder.codingPath, debugDescription: "tool_call_id is required for tool messages"))
            }
            self = .tool(content: content, toolCallId: toolCallId)
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
            case .text(let text):
                try container.encode(text, forKey: .content)
            default:
                try container.encode(content, forKey: .content)
            }
        case .assistant(let content):
            try container.encode("assistant", forKey: .role)
            switch content {
            case .text(let text):
                try container.encode(text, forKey: .content)
            case .toolCalls(let toolCalls, let text, let toolCallId):
                try container.encode(toolCalls, forKey: .toolCalls)
                try container.encode(text ?? "", forKey: .content)
                try container.encodeIfPresent(toolCallId, forKey: .toolCallId)
            }
        case .tool(let content, let toolCallId):
            try container.encode("tool", forKey: .role)
            try container.encode(content, forKey: .content)
            try container.encode(toolCallId, forKey: .toolCallId)
        }
    }
}

extension Chat.Message {
    
    public var content: MessageContent {
        get {
            switch self {
            case .system(let content):
                return .text(content)
            case .assistant(let content):
                switch content {
                case .text(let text):
                    return .text(text)
                case .toolCalls(let tools, let text, let toolId):
                    return .text(text ?? "")
                }
            case .user(let content):
                switch content {
                case .text(let text):
                    return .text(text)
                case .content(let items):
                    if items.count == 1, let first = items.first {
                        return first
                    }
                    let text = items.compactMap({ item in
                        if case let .text(value) = item {
                            return value
                        }
                        return nil
                    }).joined(separator: "\n")
                    return .text(text)
                }
            case .tool(let content, let toolCallId):
                return .text(content)
            }
        }
        set {
            switch self {
            case .system(let content):
                self = .system(content: content)
            case .assistant(let content):
                self = .assistant(content: content)
            case .user(let content):
                self = .user(content: content)
            case .tool(let content, let toolCallId):
                self = .tool(content: content, toolCallId: toolCallId)
            }
        }
    }
}

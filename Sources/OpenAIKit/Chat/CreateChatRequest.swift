
#if os(Linux)
import NIOHTTP1
import AsyncHTTPClient
#endif

import Foundation
import SwiftyJsonSchema


public enum ResponseFormat {
    case jsonObject
    case jsonSchema(JSONSchema)
}

extension ResponseFormat: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
    
    private enum SchemaCodingKeys: CodingKey {
        case strict
        case schema
        case name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode the type property inside the parent container
        switch self  {
        case .jsonObject:
            try container.encode("json_object", forKey: .type)
        case .jsonSchema(let schema):
            try container.encode("json_schema", forKey: .type)
            var schemaContainer = container.nestedContainer(keyedBy: SchemaCodingKeys.self, forKey: .jsonSchema)
            try schemaContainer.encode("MyName", forKey: .name)
            try schemaContainer.encode(true, forKey: .strict)
            try schemaContainer.encode(schema, forKey: .schema)
        }
        
    }
}

struct CreateChatRequest: Request {
    let method: HTTPMethod = .POST
    let path = "/v1/chat/completions"
    let body: Data?
    
    init(
        model: String,
        messages: [Chat.Message],
        temperature: Double,
        topP: Double,
        n: Int,
        stream: Bool,
        stops: [String],
        maxTokens: Int?,
        presencePenalty: Double,
        frequencyPenalty: Double,
        logitBias: [String: Int],
        user: String?,
        responseFormat: ResponseFormat?
    ) throws {
        
        let body = Body(
            model: model,
            messages: messages,
            temperature: temperature,
            topP: topP,
            n: n,
            stream: stream,
            stops: stops,
            maxTokens: maxTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            logitBias: logitBias,
            user: user,
            responseFormat: responseFormat
        )
                
        self.body = try Self.encoder.encode(body)
    }
}

extension CreateChatRequest {
    struct Body: Encodable {
        let model: String
        let messages: [Chat.Message]
        let temperature: Double
        let topP: Double
        let n: Int
        let stream: Bool
        let stops: [String]
        let maxTokens: Int?
        let presencePenalty: Double
        let frequencyPenalty: Double
        let logitBias: [String: Int]
        let user: String?
        let responseFormat: ResponseFormat?
            
        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case input
            case temperature
            case topP = "top_p"
            case n
            case stream
            case stop
            case maxTokens = "max_tokens"
            case presencePenalty = "presence_penalty"
            case frequencyPenalty = "frequency_penalty"
            case logitBias  = "logit_bias"
            case user
            case responseFormat = "response_format"
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            
            struct TempMessage: Codable {
                let content: [String]
            }
            
            if !messages.isEmpty {
                if messages.count > 1 {
                    
                    let gr = Dictionary<String, [Chat.Message]>.init(grouping: messages) { element in
                        switch element {
                        case .assistant(_):
                            return "assistant"
                        case .system(_):
                            return "system"
                        case .user(_):
                            return "user"
                        }
                    }.mapValues({
                        TempMessage(content: $0.map({ $0.content }))
                    })
                    
              
                    
//                    let groupedMessages = messages.reduce([String: [MessageContent]](), { partialResult, message in
//                        switch message {
//                        case .assistant(let content):
//                            partialResult["assistant"].append(.string(content))
//                        case .system(let content):
//                            partialResult["system", default: [MessageContent]].append(content)
//                        case .user(let content):
//                            partialResult["user", default: [MessageContent]].append(content)
//                        }
//                    })
                    
                    print(gr)
                    
                    try container.encode([gr], forKey: .input)
                    
//                    gr.keys.forEach { key in
//                        let values = gr[key]
//                        values?.forEach({ message in
//                            
//                            let subcont = container.nestedContainer(keyedBy: Chat.Message.CodingKeys.self, forKey: .messages)
//                            
//                            try subcont.encode(message.content, forKey: \.content)
//                        })
//                    }
                    
                }
                else {
                    try container.encode(messages, forKey: .messages)
                }
            }

            try container.encode(temperature, forKey: .temperature)
            try container.encode(topP, forKey: .topP)
            try container.encode(n, forKey: .n)
            try container.encode(stream, forKey: .stream)
            
            if !stops.isEmpty {
                try container.encode(stops, forKey: .stop)
            }
            
            if let maxTokens {
                try container.encode(maxTokens, forKey: .maxTokens)
            }
            
            try container.encode(presencePenalty, forKey: .presencePenalty)
            try container.encode(frequencyPenalty, forKey: .frequencyPenalty)
            
            if !logitBias.isEmpty {
                try container.encode(logitBias, forKey: .logitBias)
            }
            
            try container.encodeIfPresent(user, forKey: .user)
            
            try container.encodeIfPresent(responseFormat, forKey: .responseFormat)
        }
    }
}

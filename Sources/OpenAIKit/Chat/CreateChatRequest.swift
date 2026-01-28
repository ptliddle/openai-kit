
#if USE_NIO
import NIOHTTP1
import AsyncHTTPClient
#endif

import Foundation

// Custom encoding for ChatRequest so it works with inception tool calling
struct ChatEncodableTool: Encodable {
    let tool: Tool

    enum CodingKeys: CodingKey {
        case type
        case function
    }

    enum FunctionCodingKeys: CodingKey {
        case name
        case description
        case parameters
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tool.type.rawValue, forKey: .type)

        var functionContainer = container.nestedContainer(keyedBy: FunctionCodingKeys.self, forKey: .function)
        try functionContainer.encode(tool.name, forKey: .name)
        try functionContainer.encode(tool.description, forKey: .description)
        try functionContainer.encode(tool.parameters, forKey: .parameters)
    }
}


public struct CreateChatRequest: Request {
    
    public enum ResponseFormat: Encodable {
        case jsonObject
        case jsonSchema(JSONSchema, String?)
        
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
            case .jsonSchema(let (schema, name)):
                try container.encode("json_schema", forKey: .type)
                var schemaContainer = container.nestedContainer(keyedBy: SchemaCodingKeys.self, forKey: .jsonSchema)
                try schemaContainer.encode(name ?? "MyName", forKey: .name)
                try schemaContainer.encode(true, forKey: .strict)
                try schemaContainer.encode(schema, forKey: .schema)
            }
            
        }
    }
    
    let method: HTTPMethod = .POST 
    let path = "/v1/chat/completions"
    let body: Data?
    
    init(
        model: String,
        messages: [Chat.Message],
        temperature: Double?,
        topP: Double,
        n: Int,
        stream: Bool,
        stops: [String],
        maxTokens: Int?,
        presencePenalty: Double,
        frequencyPenalty: Double,
        logitBias: [String: Int],
        user: String?,
        responseFormat: CreateChatRequest.ResponseFormat?,
        tools: [Tool]?
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
            responseFormat: responseFormat,
            tools: tools
        )
                
        self.body = try Self.encoder.encode(body)
    }
}

extension CreateChatRequest {
    struct Body: Encodable {
        let model: String
        let messages: [Chat.Message]
        let temperature: Double?
        let topP: Double
        let n: Int
        let stream: Bool
        let stops: [String]
        let maxTokens: Int?
        let presencePenalty: Double
        let frequencyPenalty: Double
        let logitBias: [String: Int]
        let user: String?
        let responseFormat: CreateChatRequest.ResponseFormat?
        let tools: [Tool]?
            
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
            case tools
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            
            if !messages.isEmpty {
                try container.encode(messages, forKey: .messages)
            }

            try container.encodeIfPresent(temperature, forKey: .temperature)
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
//            try container.encode(responseFormat, forKey: .responseFormat)
            
            if let tools = tools, !tools.isEmpty {
                try container.encode(tools.map { ChatEncodableTool(tool: $0) }, forKey: .tools)
            }
        }
    }
}

//
//  ResponseOutput.swift
//  openai-kit
//
//  Created by Peter Liddle on 12/1/25.
//

import Foundation

// MARK: - Reasoning item parts (mirrors the Responses API spec)

/// A reasoning summary part: `{ "type": "summary_text", "text": "..." }`
public struct SummaryText: Codable, Equatable {

    public var text: String
    public var type = "summary_text"

    public init(text: String) {
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
    }
}

/// A reasoning text part: `{ "type": "reasoning_text", "text": "..." }`
public struct ReasoningText: Codable, Equatable {

    public var text: String
    public var type = "reasoning_text"

    public init(text: String) {
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
    }
}

// MARK: - Reasoning (input/replay item)

/// A reasoning item sent in `input` to replay previous reasoning.
/// Wire form: `{ "type": "reasoning", "id": "rs_...", "summary": [SummaryText], "content": [ReasoningText], "encrypted_content": "..." }`
/// Per spec: a replayed item must have either a non-empty summary or an encrypted_content.
public struct Reasoning: Codable {

    var type = "reasoning"
    public var id: String?
    public var summary: [SummaryText]?
    public var content: [ReasoningText]?
    public var encryptedContent: String?

    public init(id: String? = nil, summary: [SummaryText]? = nil, content: [ReasoningText]? = nil, encryptedContent: String? = nil) {
        self.id = id
        self.summary = summary
        self.content = content
        self.encryptedContent = encryptedContent
    }

    // Decoding keys are camelCase: the request decoder uses .convertFromSnakeCase
    // (see Request.swift KNOWN_ISSUES note). Do NOT add snake_case raw values here.
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case summary
        case content
        case encryptedContent
    }

    // Encoding keys are snake_case: the request encoder does NOT convert strategies
    enum EncodingKeys: String, CodingKey {
        case type
        case id
        case summary
        case content
        case encryptedContent = "encrypted_content"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decode(String.self, forKey: .type)) ?? "reasoning"
        self.id = try container.decodeIfPresent(String.self, forKey: .id)

        // Lenient summary decode: current spec/xAI form is [SummaryText] objects,
        // legacy OpenAI form is a plain [String]. Both converge on [SummaryText].
        if let typed = try? container.decodeIfPresent([SummaryText].self, forKey: .summary) {
            self.summary = typed
        }
        else if let legacy = try? container.decodeIfPresent([String].self, forKey: .summary) {
            self.summary = legacy.map(SummaryText.init(text:))
        }
        else {
            self.summary = nil
        }

        self.content = try container.decodeIfPresent([ReasoningText].self, forKey: .content)
        self.encryptedContent = try container.decodeIfPresent(String.self, forKey: .encryptedContent)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.summary, forKey: .summary)
        try container.encodeIfPresent(self.content, forKey: .content)
        try container.encodeIfPresent(self.encryptedContent, forKey: .encryptedContent)
    }
}


// MARK: - OutputItem
public struct OutputItem: Codable {
    public let id: String
    public let type: String
    public let status: String?
    public let role: String?
    public let content: [ResponseContent]?
    public let summary: [SummaryText]?
    public let encryptedContent: String?
    
    public let name: String?
    public let arguments: String?
    public let callId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case status
        case role
        case content
        case summary
        case encryptedContent
        case name
        case arguments
        case callId = "call_id"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.role = try container.decodeIfPresent(String.self, forKey: .role)
        self.content = try container.decodeIfPresent([ResponseContent].self, forKey: .content)

        // Lenient summary decode: xAI/current spec sends [SummaryText] objects,
        // legacy OpenAI sends a plain [String]. Both converge on [SummaryText].
        if let typed = try? container.decodeIfPresent([SummaryText].self, forKey: .summary) {
            self.summary = typed
        }
        else if let legacy = try? container.decodeIfPresent([String].self, forKey: .summary) {
            self.summary = legacy.map(SummaryText.init(text:))
        }
        else {
            self.summary = nil
        }

        self.encryptedContent = try container.decodeIfPresent(String.self, forKey: .encryptedContent)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.arguments = try container.decodeIfPresent(String.self, forKey: .arguments)
        self.callId = try container.decodeIfPresent(String.self, forKey: .callId)
    }
}

public struct ToolOutputContent: Codable {
    
    let type = "function_call_output"
    public var callId: String
    public var output: JSON     // This should be JSON content, which is output as a string
    
    enum CodingKeys: String, CodingKey {
        case type
        case callId = "call_id"
        case output
    }
    
    public init(callId: String, output: JSON) {
        self.callId = callId
        self.output = output
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.callId = try container.decode(String.self, forKey: .callId)
        let jsonString = try container.decode(String.self, forKey: .output)
        self.output = jsonString       // Decode as string but needs to be further decoded elsewhere
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(callId, forKey: .callId)
        
        // Output the output json as a string
        let jsonData = try JSONEncoder().encode(output)
        let jsonString = String(data: jsonData, encoding: .utf8)
        try container.encode(jsonString, forKey: .output)
    }
    
}

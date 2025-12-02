//
//  ResponseOutput.swift
//  openai-kit
//
//  Created by Peter Liddle on 12/1/25.
//

import Foundation

public struct Reasoning: Codable {
    
    var type = "reasoning"
    public var summary: [String]?
    public var id: String?

    public init(summary: [String]?, id: String?) {
        self.summary = summary
        self.id = id
    }
    
    
    enum CodingKeys: CodingKey {
        case type
        case summary
        case id
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.summary = try container.decodeIfPresent([String].self, forKey: .summary)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encodeIfPresent(self.summary, forKey: .summary)
        try container.encodeIfPresent(self.id, forKey: .id)
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
        case name
        case arguments
        case callId // = "call_id"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.role = try container.decodeIfPresent(String.self, forKey: .role)
        self.content = try container.decodeIfPresent([ResponseContent].self, forKey: .content)
        self.summary = try container.decodeIfPresent([String].self, forKey: .summary)
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

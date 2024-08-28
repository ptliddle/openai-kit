//
//  JsonSchema.swift
//
//
//  Created by Peter Liddle on 8/27/24.
//

import Foundation

// Define the top-level JSON schema struct
struct JsonSchema: Codable {
    let schema: String
    let type: String
    let items: Items

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case type
        case items
    }
}

// Define the Items struct
struct Items: Codable {
    let type: String
    let properties: Properties
    let required: [String]
    let additionalProperties: Bool
}

// Define the Properties struct
struct Properties: Codable {
    let id: PropertyType
    let context: PropertyType
}

// Define the PropertyType struct
struct PropertyType: Codable {
    let type: String
}

//// Example usage
//let jsonSchema = JSONSchema(
//    schema: "http://json-schema.org/draft-07/schema#",
//    type: "array",
//    items: Items(
//        type: "object",
//        properties: Properties(
//            id: PropertyType(type: "string"),
//            context: PropertyType(type: "string")
//        ),
//        required: ["id", "context"],
//        additionalProperties: false
//    )
//)
//
//// Encode the JSONSchema instance to JSON
//if let jsonData = try? JSONEncoder().encode(jsonSchema),
//   let jsonString = String(data: jsonData, encoding: .utf8) {
//    print(jsonString)
//}
// 
 

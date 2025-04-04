//
//  File.swift
//  
//
//  Created by Peter Liddle on 4/2/25.
//

import Foundation

struct TestHelpers {
    // Function to pretty print JSON data
    static func prettyPrintJSON(from data: Data) throws -> String {
        
        // Convert JSON data to a Dictionary
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        // Convert the Dictionary back to JSON data, but with pretty printed formatting
        let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.sortedKeys, .prettyPrinted])
        
        // Convert the pretty printed data to a String
        guard let prettyString = String(data: prettyData, encoding: .utf8) else {
            throw NSError(domain: "Couldn't get json string", code: 0)
        }
        
        return prettyString
    }
}

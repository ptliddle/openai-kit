import XCTest
@testable import OpenAIKit

final class ResponseTests: XCTestCase {
    
    func testResponseDecoding() throws {
        // Given
        let jsonString = """
        {
          "id": "resp_67ec9165a90881929d20add05a82e27601a6d217664dcae5",
          "object": "response",
          "created_at": 1743556966,
          "status": "completed",
          "error": null,
          "incomplete_details": null,
          "instructions": null,
          "max_output_tokens": null,
          "model": "o1-2024-12-17",
          "output": [
            {
              "type": "reasoning",
              "id": "rs_67ec91740af48192a6756bf7e5d90f1101a6d217664dcae5",
              "summary": []
            },
            {
              "type": "message",
              "id": "msg_67ec9175e2888192aa83162b8e84ab1301a6d217664dcae5",
              "status": "completed",
              "role": "assistant",
              "content": [
                {
                  "type": "output_text",
                  "text": " # Mind Map for UAT Development ",
                  "annotations": []
                }
              ]
            }
          ],
          "parallel_tool_calls": true,
          "previous_response_id": null,
          "reasoning": {
            "effort": "medium",
            "generate_summary": null
          },
          "store": true,
          "temperature": 1.0,
          "text": {
            "format": {
              "type": "text"
            }
          },
          "tool_choice": "auto",
          "tools": [],
          "top_p": 1.0,
          "truncation": "disabled",
          "usage": {
            "input_tokens": 1449,
            "input_tokens_details": {
              "cached_tokens": 0
            },
            "output_tokens": 2645,
            "output_tokens_details": {
              "reasoning_tokens": 960
            },
            "total_tokens": 4094
          },
          "user": null,
          "metadata": {}
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Debug: Print JSON structure
        if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("JSON Structure:")
            print(prettyString)
        }
        
        // Then
        do {
            let response = try decoder.decode(Response.self, from: jsonData)
            
            // Verify key properties
            XCTAssertEqual(response.id, "resp_67ec9165a90881929d20add05a82e27601a6d217664dcae5")
            XCTAssertEqual(response.object, "response")
            XCTAssertEqual(response.createdAt, Date(timeIntervalSince1970: TimeInterval(1743556966)))
            XCTAssertEqual(response.status, "completed")
            XCTAssertNil(response.error)
            XCTAssertEqual(response.model, "o1-2024-12-17")
            XCTAssertEqual(response.output.count, 2)
            XCTAssertEqual(response.output[0].type, "reasoning")
            XCTAssertEqual(response.output[1].type, "message")
            
            // Verify message content
            let messageOutput = response.output[1]
            XCTAssertEqual(messageOutput.role, "assistant")
            XCTAssertEqual(messageOutput.content?.count, 1)
            
            let content = messageOutput.content?.first
            XCTAssertEqual(content?.type, "output_text")
            XCTAssertEqual(content?.text, " # Mind Map for UAT Development ")
            
            // Verify usage
            XCTAssertEqual(response.usage.inputTokens, 1449)
            XCTAssertEqual(response.usage.outputTokens, 2645)
            XCTAssertEqual(response.usage.totalTokens, 4094)
            
            // Print successful decoding
            print("Successfully decoded Response object:")
            print("ID: \(response.id)")
            print("Model: \(response.model)")
            print("Output count: \(response.output.count)")
            if let content = response.output[1].content?.first {
                print("Message content: \(content.text ?? "nil")")
            }
            
        } catch {
            // Print detailed error information
            print("Decoding error: \(error)")
            
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key), context: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type), context: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: \(type), context: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
            }
            
            XCTFail("Failed to decode Response: \(error)")
        }
    }
}

# Known Issues

## Key Encoding/Decoding Strategy Asymmetry

### Problem

The library uses `.convertFromSnakeCase` on the JSON decoder (see `Request.swift`) but does **not** use `.convertToSnakeCase` on the encoder. This asymmetry exists because `.convertToSnakeCase` would corrupt JSON Schema keys (e.g. `additionalProperties`, `minLength`, `maxLength`) which must remain camelCase per the JSON Schema spec.

This creates a conflict: if a `Codable` type has explicit snake_case `CodingKeys` (e.g. `case createdAt = "created_at"`), decoding breaks because `.convertFromSnakeCase` converts the JSON key `created_at` → `createdAt` **before** matching against `CodingKeys`, so it looks for `stringValue == "createdAt"` but finds `"created_at"` — no match.

### Current Workaround

`Chat.Message` uses separate `CodingKeys` (camelCase, for decode) and `EncodingKeys` (snake_case, for encode) to work around this. This is a per-type hack.

### Types Affected

**Bidirectional types** (encode + decode) that need the `EncodingKeys` workaround or have explicit keys:
- `Chat.Message` — uses separate `EncodingKeys` (current workaround)
- `Response` — has explicit snake_case `CodingKeys` (currently broken for decode)
- `Response.Usage` — has explicit snake_case `CodingKeys` (currently broken for decode)
- `Response.Usage.Details` — has explicit snake_case `CodingKeys` (currently broken for decode)
- `Response.Reasoning` — has explicit snake_case `CodingKeys` (currently broken for decode)
- `OutputItem` — has explicit snake_case `CodingKeys` (currently broken for decode)

**Decode-only types** that rely on `.convertFromSnakeCase` and have no explicit `CodingKeys`:
- `Chat.Choice` (`finishReason` → `finish_reason`)
- `ChatStream.Choice` (`finishReason` → `finish_reason`)
- `Usage` (`promptTokens`, `completionTokens`, `totalTokens`)
- `Completion.Choice` (`finishReason` → `finish_reason`)
- `Completion.Choice.Logprobs` (`tokenLogprobs`, `topLogprobs`, `textOffset`)
- `File` (`createdAt` → `created_at`)

### Proper Fix

1. Remove `.convertFromSnakeCase` from `Request.keyDecodingStrategy` (change to `.useDefaultKeys`)
2. Add explicit snake_case `CodingKeys` to all 6 decode-only types listed above
3. Revert `Chat.Message` to use a single set of snake_case `CodingKeys` (remove `EncodingKeys`)
4. The 5 bidirectional types already have explicit snake_case `CodingKeys` — they will work correctly once `.convertFromSnakeCase` is removed
5. Remove the central note in `Request.swift` and the `EncodingKeys` enum in `Chat.swift`

This eliminates the asymmetry entirely. Every type explicitly declares its key mapping, and the encoder/decoder both use default key strategies. JSON Schema types (`JSONSchema` from SwiftyJsonSchema) are unaffected because they already have their own explicit `CodingKeys` with camelCase raw values where required by the spec.

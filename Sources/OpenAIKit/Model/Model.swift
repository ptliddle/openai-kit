import Foundation

/**
 List and describe the various models available in the API.
 */
public struct Model: Codable {
    public let id: String
    public let object: String
    public let created: Date
    public let ownedBy: String
    public let permission: [Permission]?
    public let root: String?
    public let parent: String?
}

extension Model {
    public struct Permission: Codable {
        public let id: String
        public let object: String
        public let created: Date
        public let allowCreateEngine: Bool
        public let allowSampling: Bool
        public let allowLogprobs: Bool
        public let allowSearchIndices: Bool
        public let allowView: Bool
        public let allowFineTuning: Bool
        public let organization: String
        public let group: String?
        public let isBlocking: Bool
    }
}

public protocol ModelID {
    var id: String { get }
}

// Get all openAI models
//  curl https://api.openai.com/v1/models   -H "Authorization: Bearer {OPENAI_KEY}"
//{
//  "object": "list",
//  "data": [
//    {
//      "id": "gpt-4o-realtime-preview-2024-12-17",
//      "object": "model",
//      "created": 1733945430,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-audio-preview-2024-12-17",
//      "object": "model",
//      "created": 1734034239,
//      "owned_by": "system"
//    },
//    {
//      "id": "dall-e-3",
//      "object": "model",
//      "created": 1698785189,
//      "owned_by": "system"
//    },
//    {
//      "id": "dall-e-2",
//      "object": "model",
//      "created": 1698798177,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-audio-preview-2024-10-01",
//      "object": "model",
//      "created": 1727389042,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4-0125-preview",
//      "object": "model",
//      "created": 1706037612,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4-turbo-preview",
//      "object": "model",
//      "created": 1706037777,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-mini-realtime-preview",
//      "object": "model",
//      "created": 1734387380,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-transcribe",
//      "object": "model",
//      "created": 1742068463,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-mini-transcribe",
//      "object": "model",
//      "created": 1742068596,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-realtime-preview",
//      "object": "model",
//      "created": 1727659998,
//      "owned_by": "system"
//    },
//    {
//      "id": "text-embedding-3-large",
//      "object": "model",
//      "created": 1705953180,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4",
//      "object": "model",
//      "created": 1687882411,
//      "owned_by": "openai"
//    },
//    {
//      "id": "text-embedding-ada-002",
//      "object": "model",
//      "created": 1671217299,
//      "owned_by": "openai-internal"
//    },
//    {
//      "id": "o1-pro",
//      "object": "model",
//      "created": 1742251791,
//      "owned_by": "system"
//    },
//    {
//      "id": "o1",
//      "object": "model",
//      "created": 1734375816,
//      "owned_by": "system"
//    },
//    {
//      "id": "o3-mini",
//      "object": "model",
//      "created": 1737146383,
//      "owned_by": "system"
//    },
//    {
//      "id": "computer-use-preview",
//      "object": "model",
//      "created": 1734655677,
//      "owned_by": "system"
//    },
//    {
//      "id": "tts-1-hd",
//      "object": "model",
//      "created": 1699046015,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-mini-audio-preview",
//      "object": "model",
//      "created": 1734387424,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-audio-preview",
//      "object": "model",
//      "created": 1727460443,
//      "owned_by": "system"
//    },
//    {
//      "id": "o1-preview-2024-09-12",
//      "object": "model",
//      "created": 1725648865,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-3.5-turbo-instruct-0914",
//      "object": "model",
//      "created": 1694122472,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-mini-search-preview",
//      "object": "model",
//      "created": 1741391161,
//      "owned_by": "system"
//    },
//    {
//      "id": "tts-1-1106",
//      "object": "model",
//      "created": 1699053241,
//      "owned_by": "system"
//    },
//    {
//      "id": "davinci-002",
//      "object": "model",
//      "created": 1692634301,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-3.5-turbo-1106",
//      "object": "model",
//      "created": 1698959748,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4-turbo",
//      "object": "model",
//      "created": 1712361441,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-3.5-turbo-instruct",
//      "object": "model",
//      "created": 1692901427,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-3.5-turbo",
//      "object": "model",
//      "created": 1677610602,
//      "owned_by": "openai"
//    },
//    {
//      "id": "chatgpt-4o-latest",
//      "object": "model",
//      "created": 1723515131,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-3.5-turbo-0125",
//      "object": "model",
//      "created": 1706048358,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-2024-05-13",
//      "object": "model",
//      "created": 1715368132,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-3.5-turbo-16k-0613",
//      "object": "model",
//      "created": 1685474247,
//      "owned_by": "openai"
//    },
//    {
//      "id": "gpt-3.5-turbo-16k",
//      "object": "model",
//      "created": 1683758102,
//      "owned_by": "openai-internal"
//    },
//    {
//      "id": "o1-preview",
//      "object": "model",
//      "created": 1725648897,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-search-preview",
//      "object": "model",
//      "created": 1741388720,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4.5-preview",
//      "object": "model",
//      "created": 1740623059,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o",
//      "object": "model",
//      "created": 1715367049,
//      "owned_by": "system"
//    },
//    {
//      "id": "gpt-4o-mini",
//      "object": "model",
//      "created": 1721172741,
//      "owned_by": "system"
//    },
//    {
//      "id": "o1-mini",
//      "object": "model",
//      "created": 1725649008,
//      "owned_by": "system"
//    },
//  ]
//}
extension Model {
    
    public struct Other: ModelID {
        public var id: String
    }
    
    public enum GPT4: String, ModelID {
        case o1 = "o1-2024-12-17"
        case o1Pro = "o1-pro"
        case o1Mini = "o1-mini"
        case gpt4 = "gpt-4"
        case gpt4o = "gpt-4o"
        case gpt4oLatest = "gpt-4o-2024-08-06"
        case gpt4turbo = "gpt-4-turbo"
        case gpt40314 = "gpt-4-0314"
        case gpt4_32k = "gpt-4-32k"
        case gpt4_32k0314 = "gpt-4-32k-0314"
        case gpt4_1106_preview = "gpt-4-1106-preview"
    }

    public enum GPT3: String, ModelID {
        case gpt3_5Turbo = "gpt-3.5-turbo"
        case gpt3_5Turbo_1106 = "gpt-3.5-turbo-1106"
        case gpt3_5Turbo16K = "gpt-3.5-turbo-16k"
        case gpt3_5Turbo0301 = "gpt-3.5-turbo-0301"
        case textDavinci003 = "text-davinci-003"
        case textDavinci002 = "text-davinci-002"
        case textCurie001 = "text-curie-001"
        case textBabbage001 = "text-babbage-001"
        case textAda001 = "text-ada-001"
        case textEmbeddingAda002 = "text-embedding-ada-002"
        case textDavinci001 = "text-davinci-001"
        case textDavinciEdit001 = "text-davinci-edit-001"
        case davinciInstructBeta = "davinci-instruct-beta"
        case davinci
        case curieInstructBeta = "curie-instruct-beta"
        case curie
        case ada
        case babbage
    }

    public enum Codex: String, ModelID {
        case codeDavinci002 = "code-davinci-002"
        case codeCushman001 = "code-cushman-001"
        case codeDavinci001 = "code-davinci-001"
        case codeDavinciEdit001 = "code-davinci-edit-001"
    }

    public enum Whisper: String, ModelID {
        case whisper1 = "whisper-1"
    }
}

extension RawRepresentable where RawValue == String {
    public var id: String {
        rawValue
    }
}

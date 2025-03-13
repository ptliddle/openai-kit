
#if os(Linux)
import NIOHTTP1
import NIO
import AsyncHTTPClient
#endif

import Foundation
import SwiftyJsonSchema

public struct Client {
    
    public let audio: AudioProvider
    public let chats: ChatProvider
    public let completions: CompletionProvider
    public let edits: EditProvider
    public let embeddings: EmbeddingProvider
    public let files: FileProvider
    public let images: ImageProvider
    public let models: ModelProvider
    public let moderations: ModerationProvider
    
    init(requestHandler: RequestHandler) {
        self.audio = AudioProvider(requestHandler: requestHandler)
        self.models = ModelProvider(requestHandler: requestHandler)
        self.completions = CompletionProvider(requestHandler: requestHandler)
        self.chats = ChatProvider(requestHandler: requestHandler)
        self.edits = EditProvider(requestHandler: requestHandler)
        self.images = ImageProvider(requestHandler: requestHandler)
        self.embeddings = EmbeddingProvider(requestHandler: requestHandler)
        self.files = FileProvider(requestHandler: requestHandler)
        self.moderations = ModerationProvider(requestHandler: requestHandler)
    }
    
#if os(Linux) || USE_NIO
    public init(
        httpClient: HTTPClient,
        configuration: Configuration
    ) {
        let requestHandler = NIORequestHandler(
            httpClient: httpClient,
            configuration: configuration
        )
        self.init(requestHandler: requestHandler)
    }
#endif
    
#if !os(Linux) && !USE_NIO
    public init(
        session: URLSession,
        configuration: Configuration
    ) {
        let requestHandler = URLSessionRequestHandler(
            session: session,
            configuration: configuration
        )
        self.init(requestHandler: requestHandler)
    }
#endif
}

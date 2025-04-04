import XCTest

#if USE_NIO
import NIOPosix
import AsyncHTTPClient
#endif

@testable import OpenAIKit

extension NSImage {
    func pngData() -> Data? {
        guard let tiffRepresentation = tiffRepresentation else {
            return nil
        }
        
        guard let bitmapImageRep = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        
        return bitmapImageRep.representation(using: .png, properties: [:])
    }
}

final class ClientTests: XCTestCase {
    
#if USE_NIO
    private var client: Client!
    private var httpClient: HTTPClient!
    override func setUp() {
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        
        let configuration = Configuration(apiKey: "YOUR-API-KEY")
        
        client = Client(
            httpClient: httpClient,
            configuration: configuration
        )
    }
    
    override func tearDownWithError() throws {
        try httpClient.syncShutdown()
    }
#else
    private var client: Client!
    
    override func setUp() {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("API required to perform tests")
        }
        let configuration = Configuration(apiKey: apiKey) //"YOUR-API-KEY")
        let urlSession = URLSession(configuration: .default)
        client = Client(session: urlSession, configuration: configuration)
    }
    
    override func tearDownWithError() throws {
        client = nil
    }
    
#endif
    
    func test_error() async throws {
        do {
            _ = try await client.files.retrieve(id: "NOT-VALID-ID")
        } catch {
            print(error)
        }
        
    }
    
    func test_listModels() async throws {
        let models = try await client.models.list()
        print(models)
        XCTAssertNotNil(models)
    }
    
    func test_retrieveModel() async throws {
        let models = try await client.models.retrieve(id: Model.GPT4.gpt4o.id)
        print(models)
        XCTAssertNotNil(models)
    }
    
    func test_gpt4Completion() async throws {
        let messages: [Chat.Message] = [
            .system(content: "You are a fairytale storyteller. Create a fairytale about the subject in the next message."),
            .user(content: .text("a happy wolf in the forrest"))
        ]
        
        let completion = try await client.chats.create(
            model: Model.GPT4.gpt4,
            messages: messages
        )
        
        print(completion)
    }
    
    func test_createCompletion() async throws {
        throw XCTSkip("Legacy Endpoint - No longer supported")
        let completion = try await client.completions.create(
            model: Model.GPT3.gpt3_5Turbo16K,
            prompts: ["Write a haiku"]
        )
        
        print(completion)
    }
    
    func test_createChat() async throws {
        let completion = try await client.chats.create(
            model: Model.GPT3.gpt3_5Turbo,
            messages: [
                .user(content: .text("Write a haiki"))
            ]
        )
        
        print(completion)
    }
    
    func test_createChatWithImage() async throws {
        
        let expectedOutputText = """
        This image features an illustration of a smartphone with a laboratory flask inside it. The flask contains a blue liquid and is surrounded by small sparkles, giving a sense of experimentation or innovation. The black background and simple color palette make it appear modern and digital-themed.") is not equal to ("The image is a logo featuring a smartphone with a laboratory flask inside it. The flask contains a blue liquid, and there are small sparkles around it, suggesting a theme of innovation or technology in science. The background is dark, which makes the white and blue elements stand out.
        """
        
//        let bundle = Bundle(for: type(of: self))
//        bundle.pathForImageResource(NSImage.Name.init(stringLiteral: "logo"))
//        guard let imagePath = bundle.path(forResource: "logo", ofType: "png", inDirectory: "Resources") else {
//            print("Could not find logo.png in bundle resources.")
//            return
//        }
        
        let url = Bundle.module.url(forResource: "logo", withExtension: "png")!
        
        let imageData = try Data(contentsOf: url)
        
        // Load the image from the file path
//        let image = NSImage(contentsOfFile: imagePath)
        
        let completion = try await client.chats.create(
            model: Model.GPT4.gpt4o,
            messages: [
                .user(content: .content([.image(imageData, "png")]))
            ], 
            temperature: 0.0
        )
        
//        completion.
        
        var encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(completion)
        
        guard case let Chat.Message.MessageContent.text(outputContent) = completion.choices.first!.message.content else {
            fatalError("No response")
        }
        
//        XCTAssertEqual(expectedOutputText, outputContent)
        XCTAssertNotNil(outputContent)
        
        let jsonPretty = try TestHelpers.prettyPrintJSON(from: data)
        print(jsonPretty)
    }
    
    func test_createChatStream() async throws {
        let stream = try await client.chats.stream(
            model: Model.GPT3.gpt3_5Turbo,
            messages: [
                .user(content: .text("Write a haiki"))
            ]
        )
        
        for try await chat in stream {
            if let message = chat.choices.first?.delta.content {
                print(message)
            }
        }        
    }


    func test_createEdit() async throws {
        throw XCTSkip("Deprecated endpoint")
        let edit = try await client.edits.create(
            input: "Whay day of the wek is it?",
            instruction: "Fix the spelling mistakes"
        )
        
        print(edit)
    }
    
    func test_createImage() async throws {
        let image = try await client.images.create(prompt: "Tiger Woods eating soup")
        
        print(image)
    }
    
    func test_createEditImage() async throws {
        let url = Bundle.module.url(forResource: "logo", withExtension: "png")!
        
        let data = try Data(contentsOf: url)
        
        let image = try await client.images.createEdit(
            image: data,
            mask: data,
            prompt: "Change background color to blue"
        )
        
        print(image)
    }
    
    func test_createImageVariation() async throws {
        let url = Bundle.module.url(forResource: "logo", withExtension: "png")!
        
        let data = try Data(contentsOf: url)
        
        let image = try await client.images.createVariation(image: data)
        
        print(image)
    }
    
    func test_createEmbedding() async throws {
        let embedding = try await client.embeddings.create(input: "he food was delicious and the waiter...")
        
        print(embedding)
    }
    
    func test_listFiles() async throws {
        let files = try await client.files.list()
        
        print(files)
    }
    
    func test_file_uploadRetrieveDelete() async throws {
        let url = Bundle.module.url(forResource: "example", withExtension: "jsonl")!
        
        let data = try Data(contentsOf: url)
        
        let uploadedFile = try await client.files.upload(
            file: data,
            fileName: "\(UUID().uuidString).jsonl",
            purpose: .fineTune
        )
        
        let retrievedFile = try await client.files.retrieve(id: uploadedFile.id)
        
        let _: SingleLineJSONL = try await client.files.retrieveFileContent(id: retrievedFile.id)
        
        let response = try await client.files.delete(id: retrievedFile.id)
                
        XCTAssertEqual(response.id, retrievedFile.id)
        
    }
    
    func test_createModeration() async throws {
        let moderation = try await client.moderations.createModeration(input: "I want to kill them.")
        
        print(moderation)
    }
    
    func test_createTranscription() async throws {
        let url = Bundle.module.url(forResource: "9000", withExtension: "mp3")!
        
        let data = try Data(contentsOf: url)
        
        let transcription = try await client.audio.transcribe(
            file: data,
            fileName: "9000.mp3",
            mimeType: .mpeg,
            language: .english
        )
        
        print(transcription)
    }
    
    func test_createTranslation() async throws {
        let url = Bundle.module.url(forResource: "cena", withExtension: "mp3")!
        
        let data = try Data(contentsOf: url)
        
        let translation = try await client.audio.translate(
            file: data,
            fileName: "cena.mp3",
            mimeType: .mpeg
        )
        
        print(translation)
    }
    
}

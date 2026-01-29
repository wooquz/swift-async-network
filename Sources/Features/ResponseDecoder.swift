import Foundation

public struct ResponseDecoder {
    public let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func decode<T: Decodable>(_ type: T.Type, from response: Response) throws -> T {
        try decoder.decode(T.self, from: response.data)
    }
}

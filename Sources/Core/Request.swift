import Foundation

public struct Request {
    public let method: HTTPMethod
    public let url: URL
    public var headers: [String: String]
    public var body: Encodable?
    public var query: [String: Any]?

    public init(
        method: HTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Encodable? = nil,
        query: [String: Any]? = nil
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.query = query
    }
}

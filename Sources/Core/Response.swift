import Foundation

public struct Response {
    public let data: Data
    public let urlResponse: HTTPURLResponse

    public var statusCode: Int { urlResponse.statusCode }

    public init(data: Data, urlResponse: HTTPURLResponse) {
        self.data = data
        self.urlResponse = urlResponse
    }
}

import Foundation

public protocol NetworkService {
    @discardableResult
    func request<T: Decodable>(
        _ request: Request
    ) async throws -> T

    @discardableResult
    func request(
        _ request: Request
    ) async throws -> Data
}

import Foundation

public actor NetworkClient {
    private let session: URLSession
    private let retryPolicy: RetryPolicy?
    private let interceptors: [RequestInterceptor]
    
    public init(
        session: URLSession = .shared,
        retryPolicy: RetryPolicy? = nil,
        interceptors: [RequestInterceptor] = []
    ) {
        self.session = session
        self.retryPolicy = retryPolicy
        self.interceptors = interceptors
    }
    
    public func request<T: Decodable>(
        method: HTTPMethod,
        url: String,
        headers: [String: String] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        var request = try buildRequest(method: method, url: url, headers: headers, body: body)
        
        for interceptor in interceptors {
            await interceptor.intercept(request: &request)
        }
        
        let (data, response) = try await performRequest(request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var attempts = 0
        let maxAttempts = retryPolicy?.maxAttempts ?? 1
        
        while attempts < maxAttempts {
            do {
                return try await session.data(for: request)
            } catch {
                attempts += 1
                if attempts >= maxAttempts {
                    throw error
                }
                try await Task.sleep(nanoseconds: retryPolicy?.delay(for: attempts) ?? 0)
            }
        }
        
        throw NetworkError.maxRetriesExceeded
    }
    
    private func buildRequest(
        method: HTTPMethod,
        url: String,
        headers: [String: String],
        body: Encodable?
    ) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case maxRetriesExceeded
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public protocol RequestInterceptor {
    func intercept(request: inout URLRequest) async
}

public struct RetryPolicy {
    let maxAttempts: Int
    let delay: (Int) -> UInt64
    
    public static func exponential(maxAttempts: Int = 3) -> RetryPolicy {
        return RetryPolicy(maxAttempts: maxAttempts) { attempt in
            UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
        }
    }
}

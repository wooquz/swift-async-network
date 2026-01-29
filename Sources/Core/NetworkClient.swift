import Foundation

public actor NetworkClient {
    private let session: URLSession
    private let retryPolicy: RetryPolicy?
    private let interceptors: [RequestInterceptor]
    private let logger: NetworkLogger?
    private let metricsCollector: MetricsCollector?
    
    public init(
        session: URLSession = .shared,
        retryPolicy: RetryPolicy? = nil,
        interceptors: [RequestInterceptor] = [],
        logger: NetworkLogger? = nil,
        metricsCollector: MetricsCollector? = nil
    ) {
        self.session = session
        self.retryPolicy = retryPolicy
        self.interceptors = interceptors
        self.logger = logger
        self.metricsCollector = metricsCollector
    }
    
    public func request<T: Decodable>(
        method: HTTPMethod,
        url: String,
        headers: [String: String] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        var request = try buildRequest(method: method, url: url, headers: headers, body: body)
        
        // Apply interceptors
        for interceptor in interceptors {
            await interceptor.intercept(request: &request)
        }
        
        // Log request
        logger?.logRequest(request)
        
        // Record metrics
        metricsCollector?.recordRequestStart(request)
        
        let (data, response) = try await performRequest(request)
        
        // Record metrics
        _ = metricsCollector?.recordRequestEnd(request)
        
        // Log response
        logger?.logResponse(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        if let retryPolicy = retryPolicy {
            return try await requestWithRetry(request: request, retryPolicy: retryPolicy)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
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
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            logger?.logError(error, for: request)
            throw error
        }
    }
    
    private func requestWithRetry<T: Decodable>(
        request: URLRequest,
        retryPolicy: RetryPolicy
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<retryPolicy.maxRetries {
            do {
                let (data, response) = try await performRequest(request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                lastError = error
                if attempt < retryPolicy.maxRetries - 1 {
                    try await Task.sleep(nanoseconds: UInt64(retryPolicy.delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.unknownError
    }
}

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case unknownError
}

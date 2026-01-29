import Foundation

public protocol NetworkLoggerProtocol {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: URLResponse, data: Data?)
    func logError(_ error: Error, for request: URLRequest)
}

public class NetworkLogger: NetworkLoggerProtocol {
    public enum LogLevel {
        case none
        case minimal
        case verbose
    }
    
    private let logLevel: LogLevel
    
    public init(logLevel: LogLevel = .minimal) {
        self.logLevel = logLevel
    }
    
    public func logRequest(_ request: URLRequest) {
        guard logLevel != .none else { return }
        
        print("\n🔵 ========== REQUEST ==========\n")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")
        
        if logLevel == .verbose {
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                print("Body: \(bodyString)")
            }
        }
        print("\n==============================\n")
    }
    
    public func logResponse(_ response: URLResponse, data: Data?) {
        guard logLevel != .none else { return }
        
        print("\n🟢 ========== RESPONSE =========\n")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            if logLevel == .verbose {
                print("Headers: \(httpResponse.allHeaderFields)")
            }
        }
        
        if logLevel == .verbose, let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Data: \(dataString)")
        }
        print("\n==============================\n")
    }
    
    public func logError(_ error: Error, for request: URLRequest) {
        guard logLevel != .none else { return }
        
        print("\n🔴 ========== ERROR ===========\n")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Error: \(error.localizedDescription)")
        print("\n==============================\n")
    }
}

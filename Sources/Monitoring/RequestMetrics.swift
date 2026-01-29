import Foundation

public struct RequestMetrics {
    public let requestStartTime: Date
    public let requestEndTime: Date
    public let responseStartTime: Date?
    public let responseEndTime: Date?
    
    public var totalDuration: TimeInterval {
        guard let responseEndTime = responseEndTime else {
            return Date().timeIntervalSince(requestStartTime)
        }
        return responseEndTime.timeIntervalSince(requestStartTime)
    }
    
    public var requestDuration: TimeInterval {
        guard let responseStartTime = responseStartTime else {
            return Date().timeIntervalSince(requestStartTime)
        }
        return responseStartTime.timeIntervalSince(requestStartTime)
    }
    
    public var responseDuration: TimeInterval? {
        guard let responseStartTime = responseStartTime,
              let responseEndTime = responseEndTime else {
            return nil
        }
        return responseEndTime.timeIntervalSince(responseStartTime)
    }
    
    public init(
        requestStartTime: Date,
        requestEndTime: Date,
        responseStartTime: Date?,
        responseEndTime: Date?
    ) {
        self.requestStartTime = requestStartTime
        self.requestEndTime = requestEndTime
        self.responseStartTime = responseStartTime
        self.responseEndTime = responseEndTime
    }
}

public class MetricsCollector {
    private var activeMetrics: [URLRequest: (start: Date, end: Date?)] = [:]
    
    public init() {}
    
    public func recordRequestStart(_ request: URLRequest) {
        activeMetrics[request] = (start: Date(), end: nil)
    }
    
    public func recordRequestEnd(_ request: URLRequest) -> RequestMetrics? {
        guard let metrics = activeMetrics[request] else { return nil }
        let endTime = Date()
        activeMetrics.removeValue(forKey: request)
        
        return RequestMetrics(
            requestStartTime: metrics.start,
            requestEndTime: endTime,
            responseStartTime: endTime,
            responseEndTime: endTime
        )
    }
}

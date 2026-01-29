import Foundation

public struct RetryPolicy {
    public let maxAttempts: Int
    public let delayProvider: (Int) -> TimeInterval
    public let shouldRetry: (Int, HTTPURLResponse?, Error) -> Bool

    public init(
        maxAttempts: Int,
        delayProvider: @escaping (Int) -> TimeInterval,
        shouldRetry: @escaping (Int, HTTPURLResponse?, Error) -> Bool
    ) {
        self.maxAttempts = maxAttempts
        self.delayProvider = delayProvider
        self.shouldRetry = shouldRetry
    }

    public static func exponential(maxAttempts: Int) -> RetryPolicy {
        RetryPolicy(
            maxAttempts: maxAttempts,
            delayProvider: { attempt in
                let base: Double = 0.5
                return base * pow(2, Double(attempt - 1))
            },
            shouldRetry: { _, response, error in
                if let response {
                    return (500...599).contains(response.statusCode)
                }
                let nsError = error as NSError
                return nsError.domain == NSURLErrorDomain
            }
        )
    }
}

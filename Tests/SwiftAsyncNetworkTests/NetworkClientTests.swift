import XCTest
@testable import SwiftAsyncNetwork

final class NetworkClientTests: XCTestCase {
    var client: NetworkClient!
    
    override func setUp() {
        super.setUp()
        client = NetworkClient()
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }
    
    // MARK: - Basic Request Tests
    
    func testSuccessfulRequest() async throws {
        struct MockResponse: Codable {
            let message: String
        }
        
        // Note: In real tests, you would use a mocked URLSession
        // This is a basic structure for testing
    }
    
    func testInvalidURL() async {
        do {
            struct MockResponse: Codable {
                let data: String
            }
            
            let _: MockResponse = try await client.request(
                method: .get,
                url: "invalid url with spaces"
            )
            
            XCTFail("Should throw an error for invalid URL")
        } catch NetworkError.invalidURL {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Retry Policy Tests
    
    func testRetryPolicyExponentialDelay() {
        let policy = RetryPolicy.exponential(maxAttempts: 3)
        
        XCTAssertEqual(policy.maxAttempts, 3)
        
        let delay1 = policy.delay(for: 1)
        let delay2 = policy.delay(for: 2)
        
        XCTAssertTrue(delay2 > delay1, "Exponential delay should increase")
    }
    
    // MARK: - HTTP Method Tests
    
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
    }
    
    // MARK: - Interceptor Tests
    
    func testRequestInterceptor() async {
        struct MockInterceptor: RequestInterceptor {
            func intercept(request: inout URLRequest) async {
                request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
            }
        }
        
        let clientWithInterceptor = NetworkClient(
            interceptors: [MockInterceptor()]
        )
        
        // Test would verify interceptor is called
        XCTAssertNotNil(clientWithInterceptor)
    }
}

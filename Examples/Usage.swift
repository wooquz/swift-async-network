import Foundation
import SwiftAsyncNetwork

// MARK: - Basic Usage Example

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

class NetworkExample {
    private let client = NetworkClient()
    
    // MARK: - GET Request
    func fetchUser() async throws {
        let user: User = try await client.request(
            method: .get,
            url: "https://api.example.com/users/1"
        )
        print("Fetched user: \(user.name)")
    }
    
    // MARK: - POST Request
    func createPost(title: String, body: String) async throws {
        struct CreatePostRequest: Encodable {
            let title: String
            let body: String
            let userId: Int
        }
        
        let newPost: Post = try await client.request(
            method: .post,
            url: "https://api.example.com/posts",
            headers: ["Authorization": "Bearer token"],
            body: CreatePostRequest(title: title, body: body, userId: 1)
        )
        print("Created post: \(newPost.title)")
    }
    
    // MARK: - With Retry Policy
    func fetchUserWithRetry() async throws {
        let clientWithRetry = NetworkClient(
            retryPolicy: .exponential(maxAttempts: 3)
        )
        
        let user: User = try await clientWithRetry.request(
            method: .get,
            url: "https://api.example.com/users/1"
        )
        print("Fetched user with retry: \(user.name)")
    }
    
    // MARK: - With Custom Headers Interceptor
    func fetchWithInterceptor() async throws {
        struct AuthInterceptor: RequestInterceptor {
            func intercept(request: inout URLRequest) async {
                request.setValue("Bearer my_token", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            }
        }
        
        let clientWithInterceptor = NetworkClient(
            interceptors: [AuthInterceptor()]
        )
        
        let user: User = try await clientWithInterceptor.request(
            method: .get,
            url: "https://api.example.com/users/1"
        )
        print("Fetched with interceptor: \(user.name)")
    }
}

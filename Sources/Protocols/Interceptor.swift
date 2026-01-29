import Foundation

public protocol RequestInterceptor {
    func intercept(request: inout URLRequest) async
}

public protocol ResponseInterceptor {
    func intercept(data: inout Data, response: inout HTTPURLResponse) async
}

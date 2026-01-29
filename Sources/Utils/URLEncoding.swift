import Foundation

public enum URLEncoding {
    public static func encode(_ url: URL, parameters: [String: Any]?) -> URL {
        guard let parameters, !parameters.isEmpty else { return url }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []

        for (key, value) in parameters {
            let stringValue: String

            switch value {
            case let v as String: stringValue = v
            case let v as CustomStringConvertible: stringValue = v.description
            default: continue
            }

            queryItems.append(URLQueryItem(name: key, value: stringValue))
        }

        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        return components?.url ?? url
    }
}

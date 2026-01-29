# Swift Async Network

## Описание

Современный HTTP клиент для iOS на основе async/await с поддержкой Codable, автоматическими повторными попытками, интерцепторами и встроенным мониторингом сетевых запросов.

## Возможности

🚀 **Async/Await API**
- Полная поддержка Swift Concurrency
- Типобезопасные запросы
- Автоматическая обработка ошибок

📦 **Codable Integration**
- Автоматическая сериализация/десериализация
- Поддержка кастомных энкодеров
- Generic типы для запросов и ответов

🔄 **Retry Logic**
- Настраиваемые стратегии повторных попыток
- Exponential backoff
- Условная логика повторов

🔌 **Interceptors**
- Request/Response interceptors
- Модификация заголовков
- Логирование запросов
- Обработка токенов

📊 **Network Monitoring**
- Отслеживание производительности
- Метрики запросов
- Детальное логирование

## Требования

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Структура проекта

```
swift-async-network/
├── Sources/
│   ├── Core/
│   │   ├── NetworkClient.swift
│   │   ├── Request.swift
│   │   └── Response.swift
│   ├── Protocols/
│   │   ├── NetworkService.swift
│   │   └── Interceptor.swift
│   ├── Features/
│   │   ├── RetryPolicy.swift
│   │   ├── RequestBuilder.swift
│   │   └── ResponseDecoder.swift
│   ├── Monitoring/
│   │   ├── NetworkLogger.swift
│   │   └── MetricsCollector.swift
│   └── Utils/
│       ├── HTTPMethod.swift
│       └── URLEncoding.swift
└── Tests/
    └── SwiftAsyncNetworkTests/

```

## Примеры использования

### Простой GET запрос

```swift
let client = NetworkClient()

struct User: Codable {
    let id: Int
    let name: String
}

let user = try await client.request(
    method: .get,
    url: "https://api.example.com/users/1"
)
print(user.name)
```

### POST запрос с телом

```swift
struct CreateUser: Codable {
    let name: String
    let email: String
}

let newUser = CreateUser(name: "John", email: "john@example.com")
let response: User = try await client.request(
    method: .post,
    url: "https://api.example.com/users",
    body: newUser
)
```

### Retry логика

```swift
let client = NetworkClient(
    retryPolicy: .exponential(maxAttempts: 3)
)

let data = try await client.request(
    method: .get,
    url: "https://api.example.com/data"
)
```

### Interceptors

```swift
class AuthInterceptor: RequestInterceptor {
    func intercept(request: inout URLRequest) async {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

let client = NetworkClient(
    interceptors: [AuthInterceptor()]
)
```

## Установка

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/wooquz/swift-async-network.git", from: "1.0.0")
]
```

## Лицензия

MIT License

---

# Swift Async Network

## Description

Modern HTTP client for iOS based on async/await with Codable support, automatic retry logic, interceptors, and built-in network request monitoring.

## Features

🚀 **Async/Await API**
- Full Swift Concurrency support
- Type-safe requests
- Automatic error handling

📦 **Codable Integration**
- Automatic serialization/deserialization
- Custom encoder support
- Generic types for requests and responses

🔄 **Retry Logic**
- Configurable retry strategies
- Exponential backoff
- Conditional retry logic

🔌 **Interceptors**
- Request/Response interceptors
- Header modification
- Request logging
- Token handling

📊 **Network Monitoring**
- Performance tracking
- Request metrics
- Detailed logging

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Project Structure

```
swift-async-network/
├── Sources/
│   ├── Core/
│   │   ├── NetworkClient.swift
│   │   ├── Request.swift
│   │   └── Response.swift
│   ├── Protocols/
│   │   ├── NetworkService.swift
│   │   └── Interceptor.swift
│   ├── Features/
│   │   ├── RetryPolicy.swift
│   │   ├── RequestBuilder.swift
│   │   └── ResponseDecoder.swift
│   ├── Monitoring/
│   │   ├── NetworkLogger.swift
│   │   └── MetricsCollector.swift
│   └── Utils/
│       ├── HTTPMethod.swift
│       └── URLEncoding.swift
└── Tests/
    └── SwiftAsyncNetworkTests/

```

## Usage Examples

### Simple GET Request

```swift
let client = NetworkClient()

struct User: Codable {
    let id: Int
    let name: String
}

let user = try await client.request(
    method: .get,
    url: "https://api.example.com/users/1"
)
print(user.name)
```

### POST Request with Body

```swift
struct CreateUser: Codable {
    let name: String
    let email: String
}

let newUser = CreateUser(name: "John", email: "john@example.com")
let response: User = try await client.request(
    method: .post,
    url: "https://api.example.com/users",
    body: newUser
)
```

### Retry Logic

```swift
let client = NetworkClient(
    retryPolicy: .exponential(maxAttempts: 3)
)

let data = try await client.request(
    method: .get,
    url: "https://api.example.com/data"
)
```

### Interceptors

```swift
class AuthInterceptor: RequestInterceptor {
    func intercept(request: inout URLRequest) async {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

let client = NetworkClient(
    interceptors: [AuthInterceptor()]
)
```

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/wooquz/swift-async-network.git", from: "1.0.0")
]
```

## License

MIT License

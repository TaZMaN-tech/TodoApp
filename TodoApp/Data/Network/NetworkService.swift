//
//  NetworkService.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class NetworkService {
    
    // MARK: - Properties
    
    private let todosURL = URL(string: "https://dummyjson.com/todos")!
    private let urlSession: URLSession
    
    // MARK: - Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Public Methods
    
    func fetchTodos() async throws -> [TaskItem] {
        // URLSession.data(for:) — async версия dataTask, встроена в iOS 15+
        let (data, response) = try await urlSession.data(for: makeRequest())
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
        
        let dto = try JSONDecoder().decode(TodoResponseDTO.self, from: data)
        // TodoMapper остаётся — маппинг DTO → TaskItem
        return TodoMapper.map(response: dto)
    }
    
    
    // MARK: - Private Methods
    
    private func makeRequest() -> URLRequest {
        var request = URLRequest(url: todosURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
    
    
    // MARK: - NetworkError
    
    enum NetworkError: Error {
        case networkError(Error)
        case invalidResponse
        case httpError(statusCode: Int)
        case noData
        case decodingError(Error)
        
        var localizedDescription: String {
            switch self {
            case .networkError(let error):
                return "Ошибка сети: \(error.localizedDescription)"
            case .invalidResponse:
                return "Получен невалидный ответ от сервера"
            case .httpError(let statusCode):
                return "Ошибка сервера: HTTP \(statusCode)"
            case .noData:
                return "Сервер не вернул данные"
            case .decodingError(let error):
                return "Ошибка парсинга данных: \(error.localizedDescription)"
            }
        }
    }

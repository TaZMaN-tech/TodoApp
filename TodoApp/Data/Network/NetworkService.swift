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
    
    func fetchTodos(completion: @escaping (Result<[TaskEntity], NetworkError>) -> Void) {
        var request = URLRequest(url: todosURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<[TaskEntity], NetworkError>) -> Void
    ) {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(.networkError(error)))
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(.invalidResponse))
            }
            return
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            DispatchQueue.main.async {
                completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(.noData))
            }
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(TodoResponseDTO.self, from: data)
            let entities = TodoMapper.map(response: responseDTO)
            
            DispatchQueue.main.async {
                completion(.success(entities))
            }
        } catch let decodingError {
            DispatchQueue.main.async {
                completion(.failure(.decodingError(decodingError)))
            }
        }
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

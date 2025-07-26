//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 16.07.2025.
//

import Foundation

final class OAuth2Service {
    // MARK: - Singleton
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    private let networkClient = NetworkClient()
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        // 1. Гарантируем, что `completion` вызывается только один раз
        var isCompletionCalled = false
        let safeCompletion: (Result<String, Error>) -> Void = { result in
            guard !isCompletionCalled else { return }
            isCompletionCalled = true
            completion(result)
        }
        
        // 2. Если уже есть активный запрос с таким же `code` → отменяем дубликат
        if let lastCode = lastCode, lastCode == code, currentTask != nil {
            safeCompletion(.failure(NetworkClient.NetworkError.duplicateRequest))
            return
        }
        
        // 3. Отменяем предыдущий запрос (если был)
        currentTask?.cancel()
        currentTask = nil
        
        // 4. Сохраняем новый `code`
        lastCode = code
        
        // 5. Выполняем запрос и сохраняем задачу
        currentTask = networkClient.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                // 6. Очищаем состояние после завершения
                self?.currentTask = nil
                self?.lastCode = nil
                safeCompletion(result)
            }
        }
        
        // 7. Если не удалось создать задачу → возвращаем ошибку
        if currentTask == nil {
            safeCompletion(.failure(NetworkClient.NetworkError.invalidRequest))
        }
    }
}

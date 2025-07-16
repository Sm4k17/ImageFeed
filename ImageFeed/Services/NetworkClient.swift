//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 20.05.2025.
//

import Foundation

protocol NetworkRouting {
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
    func cancel()
}

final class NetworkClient: NetworkRouting {
    // MARK: - Nested Types
    enum NetworkError: LocalizedError {
        case codeError(Int)
        case invalidData
        case invalidResponse
        case requestFailed(Error)
        case cancelled
        case noNetworkConnection
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .codeError(let code):
                return "Server returned status code \(code)"
            case .invalidData:
                return "Received invalid data"
            case .invalidResponse:
                return "Invalid server response"
            case .requestFailed(let error):
                return "Request failed: \(error.localizedDescription)"
            case .cancelled:
                return "Request was cancelled"
            case .noNetworkConnection:
                return "No network connection available"
            case .timeout:
                return "Request timed out"
            }
        }
    }
    
    private struct OAuthTokenResponse: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
    
    // MARK: - Properties
    private var currentTask: URLSessionTask?
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        cancelPendingRequest()
        
        let request = makeTokenRequest(code: code)
        
        currentTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            let result: Result<String, Error> = self.processTokenResponse(
                data: data,
                response: response,
                error: error
            )
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        currentTask?.resume()
    }
    
    func cancel() {
        cancelPendingRequest()
    }
    
    // MARK: - Private Methods
    private func makeTokenRequest(code: String) -> URLRequest {
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        var components = URLComponents(string: "https://unsplash.com/oauth/token")!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        return request
    }
    
    private func processTokenResponse(
            data: Data?,
            response: URLResponse?,
            error: Error?
        ) -> Result<String, Error> {
            if let error = error {
                logError(error)
                return .failure(mapError(error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                if let httpResponse = response as? HTTPURLResponse {
                    return .failure(NetworkError.codeError(httpResponse.statusCode))
                }
                return .failure(NetworkError.invalidResponse)
            }
            
            do {
                let responseBody = try decoder.decode(OAuthTokenResponse.self, from: data)
                logSuccess("Token received")
                return .success(responseBody.accessToken)
            } catch {
                logDecodingError(error)
                return .failure(error)
            }
        }
    
    private func mapError(_ error: Error) -> Error {
        let nsError = error as NSError
        
        switch nsError.code {
        case NSURLErrorCancelled:
            return NetworkError.cancelled
        case NSURLErrorNotConnectedToInternet, NSURLErrorCannotConnectToHost:
            return NetworkError.noNetworkConnection
        case NSURLErrorTimedOut:
            return NetworkError.timeout
        default:
            return NetworkError.requestFailed(error)
        }
    }
    
    private func cancelPendingRequest() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - Logging
    private func logResponse(_ response: HTTPURLResponse) {
#if DEBUG
        print("""
        🌐 [OAuth2] Response:
        Status Code: \(response.statusCode)
        """)
#endif
    }
    
    private func logError(_ error: Error) {
#if DEBUG
        print("""
        🛑 [OAuth2] Error:
        \(error.localizedDescription)
        """)
#endif
    }
    
    private func logInvalidResponse() {
#if DEBUG
        print("🛑 [OAuth2] Invalid response")
#endif
    }
    
    private func logInvalidData() {
#if DEBUG
        print("🛑 [OAuth2] Invalid data")
#endif
    }
    
    private func logDecodingError(_ error: Error) {
#if DEBUG
        print("""
        🛑 [OAuth2] Decoding error:
        \(error.localizedDescription)
        """)
#endif
    }
    
    private func logSuccess(_ message: String) {
#if DEBUG
        print("✅ [OAuth2] \(message)")
#endif
    }
}

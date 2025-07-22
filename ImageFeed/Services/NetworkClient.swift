//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 20.05.2025.
//

import Foundation

final class NetworkClient {
    
    // MARK: - Nested Types
    enum NetworkError: LocalizedError {
        case invalidRequest
        case codeError(Int)
        case invalidData
        case invalidResponse
        case requestFailed(Error)
        case cancelled
        case noNetworkConnection
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .invalidRequest:
                return "Invalid request parameters"
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
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    // MARK: - Properties
    private var currentTask: URLSessionTask?
    private let session: URLSession
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        cancelPendingRequest()
        
        guard let request = makeTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        logRequest(request)
        
        currentTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            let result = self.processTokenResponse(
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
    
    // MARK: - Private Methods
    private func makeTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashTokenURLString) else {
            print("[Network] Error: Invalid URL string - \(Constants.unsplashTokenURLString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        guard let httpBody = bodyString.data(using: .utf8) else {
            print("[Network] Error: Failed to create HTTP body from parameters")
            return nil
        }
        
        request.httpBody = httpBody
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
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
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logInvalidResponse()
            return .failure(NetworkError.invalidResponse)
        }
        
        logResponse(httpResponse)
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            logInvalidStatusCode(httpResponse.statusCode)
            if let data = data {
                logResponseData(data)
            }
            return .failure(NetworkError.codeError(httpResponse.statusCode))
        }
        
        guard let data = data else {
            logInvalidData()
            return .failure(NetworkError.invalidData)
        }
        
        logResponseData(data)
        
        do {
            let responseBody = try decoder.decode(OAuthTokenResponse.self, from: data)
            logSuccess("Token received successfully")
            return .success(responseBody.accessToken)
        } catch let decodingError {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["access_token"] as? String {
                logWarning("Used fallback token extraction")
                return .success(token)
            }
            
            logDecodingError(decodingError)
            return .failure(decodingError)
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
    
    // MARK: - Logging Methods
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("""
        🔧 [Network Request]
        URL: \(request.url?.absoluteString ?? "nil")
        Method: \(request.httpMethod ?? "nil")
        Headers: \(request.allHTTPHeaderFields ?? [:])
        Body: \(request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "nil")
        """)
        #endif
    }
    
    private func logResponse(_ response: HTTPURLResponse) {
        #if DEBUG
        print("""
        🌐 [Network Response]
        Status Code: \(response.statusCode)
        URL: \(response.url?.absoluteString ?? "nil")
        """)
        #endif
    }
    
    private func logResponseData(_ data: Data) {
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 [Response Data]\n\(jsonString)")
        } else {
            print("📦 [Response Data] (binary data, size: \(data.count) bytes)")
        }
        #endif
    }
    
    private func logError(_ error: Error) {
        #if DEBUG
        let nsError = error as NSError
        print("""
        🛑 [Network Error]
        Domain: \(nsError.domain)
        Code: \(nsError.code)
        Description: \(error.localizedDescription)
        """)
        #endif
    }
    
    private func logInvalidResponse() {
        #if DEBUG
        print("🛑 [Network] Invalid response (not HTTPURLResponse)")
        #endif
    }
    
    private func logInvalidData() {
        #if DEBUG
        print("🛑 [Network] Response contains no data")
        #endif
    }
    
    private func logInvalidStatusCode(_ code: Int) {
        #if DEBUG
        print("🛑 [Network] Server returned error status code: \(code)")
        #endif
    }
    
    private func logDecodingError(_ error: Error) {
        #if DEBUG
        print("""
        🛑 [JSON Decoding Failed]
        Error: \(error.localizedDescription)
        Underlying error: \((error as NSError).userInfo[NSUnderlyingErrorKey] ?? "none")
        """)
        #endif
    }
    
    private func logSuccess(_ message: String) {
        #if DEBUG
        print("✅ [Network] \(message)")
        #endif
    }
    
    private func logWarning(_ message: String) {
        #if DEBUG
        print("⚠️ [Network] \(message)")
        #endif
    }
}

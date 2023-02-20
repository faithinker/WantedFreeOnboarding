//
//  NetworkService.swift
//  Concurrency
//
//  Created by jhkim on 2023/02/20.
//

import UIKit

// 네트워트 초기 세팅 : https://stackoverflow.com/questions/50389383/swift-codable-extract-a-single-coding-key

class NetworkService {
    static let shared = NetworkService()
    private init() { }
    
    private let API_Key = "0qkSNtNaUL0XRhFBY7ov2q8VEC2FVAFy"
    
    private var baseUrl: URL {
        guard let url = URL(string: "https://api.giphy.com/v1/") else { fatalError() }
        return url
    }
    
    enum EndPoint {
        case random
        
        var path: String {
            switch self {
            case .random:       return "gifs/random"
            }
        }
        
        var query: [String: AnyHashable] {
            switch self {
            default:
                return [:]
            }
        }
        
        var method: Method {
            switch self {
            default: return .get
            }
        }
        
        enum Method: String {
            case get, delete, post, patch
        }
    }
    
    func request<T: Decodable>(endPoint: EndPoint, completion: @escaping(Result<T, GiphyError>) -> Void) {
        
        guard let relativeUrl = URL(string: endPoint.path, relativeTo: baseUrl) else {
            completion(.failure(.invalidUrl)); return
        }
        guard var component = URLComponents(url: relativeUrl, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidUrl)); return
        }
        
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "api_key", value: API_Key)]
        
        if endPoint.query.isEmpty == false {
            endPoint.query.forEach {
                queryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
            }
        }
        component.queryItems = queryItems
        
        guard let componentUrl = component.url else { completion(.failure(.invalidUrl)); return }
        
        var request = URLRequest(url: componentUrl)
        request.httpMethod = endPoint.method.rawValue
        
        print("Request URL: \(componentUrl.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ =  error { completion(.failure(.responseError)); return }
                        
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { completion(.failure(.invalidResponse)); return }
            
            guard let data = data else { completion(.failure(.invalidData)); return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.jsonDecoderFail))
            }
        }
        task.resume()
        
    }
    


}


enum GiphyError:String, Error {
    case invalidUrl
    case responseError
    case invalidRequest
    case invalidData
    case invalidResponse
    case jsonDecoderFail
}

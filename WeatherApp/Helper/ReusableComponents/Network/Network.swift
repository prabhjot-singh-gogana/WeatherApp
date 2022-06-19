//
//  Network.swift
//  NewsDemoMVVM
//
//  Created by Prabhjot Singh Gogana on 14/3/22.
//


import Foundation



// Json decoding for converting object to json and json to object  throgh Codable
public protocol PSJsonDecoding {
    associatedtype PSMapperModel
    static func decode(json: Dictionary<String, Any>) -> PSMapperModel?
    static func arrayDecoding(json: Dictionary<String, Any>) -> [PSMapperModel]?
    static func decode(with data: Data) -> PSMapperModel?
}

public extension PSJsonDecoding where PSMapperModel: Codable {
    static func arrayDecoding(json: Dictionary<String, Any>) -> [PSMapperModel]? {
        do {
            let json = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedObject = try? decoder.decode([PSMapperModel].self, from: json)
            return decodedObject
        } catch {
            print(error)
            return nil
        }
    }
    
    static func decode(json: Dictionary<String, Any>) -> PSMapperModel? {
        do {
            let json = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedObject = try? decoder.decode(PSMapperModel.self, from: json)
            return decodedObject
        } catch {
            print(error)
            return nil
        }
    }
    static func decode(with data: Data) -> PSMapperModel? {
        return try? JSONDecoder().decode(PSMapperModel.self, from: data)
    }
}



class APIManager<T: PSJsonDecoding> {
    
    
    enum RequestURL: String {
        case baseURL = "https://newsapi.org/v2/top-headlines?country=us&pageSize=10&apiKey=12aea93cf9e04cc69eb396e65c735711"
    }
    
    enum ApiResult {
        case success(T)
        case failure(RequestError)
    }
    enum HTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    enum RequestError: Error {
        case unknownError
        case connectionError
        case authorizationError
        case invalidRequest
        case notFound
        case invalidResponse
        case serverError
        case serverUnavailable
    }
    
    // for requesting the data from url with parameters and http method
    
    static func requestData(method:HTTPMethod,parameters: [String:Any]?,completion: @escaping (ApiResult)->Void) {
        
        let header =  ["Content-Type": "application/x-www-form-urlencoded"]
        
        var urlRequest = URLRequest(url: URL(string: RequestURL.baseURL.rawValue)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpMethod = method.rawValue
        var newParams: String?  {
            if let parameters = parameters {
                let params = parameters.reduce("") { (result, param) -> String in
                    return result + "&\(param.key)=\(param.value)"
                }
                return params
            }
            return nil
        }
        if let parameters = newParams {
            if method != .post {
                urlRequest.url = URL(string: RequestURL.baseURL.rawValue + parameters)
            } else {
                urlRequest.httpBody = parameters.data(using: .utf8)
            }
        }
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print(error)
                completion(ApiResult.failure(.connectionError))
            }else if let data = data ,let responseCode = response as? HTTPURLResponse {
                let responseJson = T.decode(with: data)
                switch responseCode.statusCode {
                case 200:
                    completion(ApiResult.success(responseJson as! T))
                case 400...499:
                completion(ApiResult.failure(.authorizationError))
                case 500...599:
                completion(ApiResult.failure(.serverError))
                default:
                    completion(ApiResult.failure(.unknownError))
                    break
                }
                
            }
        }.resume()
    }
}




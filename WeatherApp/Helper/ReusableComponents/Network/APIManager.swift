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
    
    
    enum RequestURL {
        case list
        case detail(Int)
        
        var apiName: String {
            switch self {
            case .list:
                return "/list"
            case .detail(let weatherID):
                return "/\(weatherID)"
            }
        }
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
    
    static func requestData(requestURL:RequestURL, method:HTTPMethod,parameters: [String:Any]?,completion: @escaping (ApiResult)->Void) {
        
        let header =  ["Content-Type": "application/x-www-form-urlencoded"]
        let baseURL = "https://testapi.io/api/olestang/weather" //We can use the base url in info file
        let strURL = baseURL + requestURL.apiName
        var urlRequest = URLRequest(url: URL(string: strURL)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
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
                urlRequest.url = URL(string: strURL + parameters)
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




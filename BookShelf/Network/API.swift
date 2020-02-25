//
//  API.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/20.
//  Copyright © 2020 cream. All rights reserved.
//

import Foundation

protocol APIURLConvertible {
    
    var host: String { get }
    var path: String { get }
    var url: URL { get }
}

struct APIResponse<DecodableType: Decodable> {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    var decodedObject: DecodableType? {
        guard let data = self.data,
            let object = try? JSONDecoder().decode(DecodableType.self, from: data) else { return nil }
        return object
    }
}

private let urlSession = URLSession(configuration: .default)

struct APIClient<Request: APIURLConvertible> {
    
    static func request(_ urlConvertible: Request, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = urlSession.dataTask(with: urlConvertible.url, completionHandler: completion)
        task.resume()
    }
    
    static func request<T: Decodable>(_ urlConvertible: Request, decodedType: T.Type, responseCompletion: @escaping (APIResponse<T>) -> Void) {
        
        self.request(urlConvertible) { (data, response, error) in
            guard let data = data, let response = response, error == nil else {
                return responseCompletion(APIResponse<T>(error: error))
            }
            
            return responseCompletion(APIResponse<T>(data: data, response: response, error: error))
        }
    }
}

enum API { }

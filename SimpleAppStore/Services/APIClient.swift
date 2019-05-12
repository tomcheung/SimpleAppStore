//
//  APIClient.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

enum APIError: Error {
    case parseJSONError(DecodingError)
    case unexpected
}

class APIClient {
    
    private static let jsonDecoder: JSONDecoder = JSONDecoder()
    
    static func appListing(count: Int) -> SignalProducer<AppEntityResponse, APIError> {
        let url = URL(string: "https://itunes.apple.com/hk/rss/topfreeapplications/limit=\(count)/json")
        return APIClient.requestWithModel(url: url!, method: .get)
    }
    
    static func appRecommendation(count: Int) -> SignalProducer<AppEntityResponse, APIError> {
        let url = URL(string: "https://itunes.apple.com/hk/rss/topgrossingapplications/limit=\(count)/json")
        return APIClient.requestWithModel(url: url!, method: .get)
    }
    
    // MARK: - Helper function
    
    static private func requestWithModel<T: Decodable>(url: URL, method: HTTPMethod, param: [String: Any]? = nil) -> SignalProducer<T, APIError> {
        return ReactiveAlamofire.responseJSON(url: url, method: method, param: param)
//            .on(starting: {
//                print("start api request: \(url)")
//            }, failed: { (error) in
//                print("api \(url) fail: \(error)")
//            }, value: { (json) in
//                print("api \(url) completed: \(json)")
//            })
            .attemptMap { (json) -> T in
                return try APIClient.mapResponse(json: json)
            }
            .mapError { (error) -> APIError in
                switch error {
                case let decodingError as DecodingError:
                    return APIError.parseJSONError(decodingError)
                default:
                    return APIError.unexpected
                }
            }
        
    }
    
    // Suppose should be private, it just non-private for unit test
    static func mapResponse<Model: Decodable>(json: Any) throws -> Model {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try APIClient.jsonDecoder.decode(Model.self, from: data)
    }
}


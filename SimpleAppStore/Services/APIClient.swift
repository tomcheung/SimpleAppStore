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

struct APIError: Error {
    enum Reason {
        case parseJSONError
        case unexpected
        case connectionError
        case connectionTimeout
        case noInternetConnection
    }
    
    let reason: Reason
    let detailError: Error
    
    var message: String {
        switch self.reason {
        case .noInternetConnection:
            return "No internet connection"
        case .parseJSONError:
            return "Cannot read server response"
        case .connectionError:
            return "Connection problem (\(self.detailError.localizedDescription))"
        case .connectionTimeout:
            return "Connection timeout"
        default:
            return self.detailError.localizedDescription
        }
    }
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
    
    static func appDetail(appIds: [String]) -> SignalProducer<AppDetailResponse, APIError> {
        let ids = appIds.joined(separator: ",")
        let url = URL(string: "https://itunes.apple.com/hk/lookup")
        return APIClient.requestWithModel(url: url!, method: .get, param: ["id": ids])
    }
    
    // MARK: - Helper function
    
    static func requestWithModel<T: Decodable>(url: URL, method: HTTPMethod, param: [String: Any]? = nil) -> SignalProducer<T, APIError> {
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
                    return APIError(reason: .parseJSONError, detailError: decodingError)
                case let afError as AFError:
                    if case .responseSerializationFailed = afError {
                        return APIError(reason: .parseJSONError, detailError: afError)
                    } else {
                        return APIError(reason: .connectionError, detailError: afError)
                    }
                default:
                    return APIClient.parseFallbackError(error)
                }
            }
            .on(failed: { (error) in
                print("api \(url) fail: \(error)")
            })
    }
    
    static func parseFallbackError(_ error: Error) -> APIError {
        let nsError = error as NSError
        
        guard nsError.domain == NSURLErrorDomain else {
            return APIError(reason: .unexpected, detailError: error)
        }
        
        let reason: APIError.Reason
        switch nsError.code {
        case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorBadURL:
            reason = .connectionError
        case NSURLErrorTimedOut:
            reason = .connectionTimeout
        case NSURLErrorNotConnectedToInternet:
            reason = .noInternetConnection
        default:
            reason = .unexpected
        }
        
        return APIError(reason: reason, detailError: error)
    }
    
    static func mapResponse<Model: Decodable>(json: Any) throws -> Model {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try APIClient.jsonDecoder.decode(Model.self, from: data)
    }
}


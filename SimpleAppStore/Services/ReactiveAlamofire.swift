//
//  ReactiveAlamofire.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

class ReactiveAlamofire {
    
    private static let sessiontManager: SessionManager = {
        let urlConfiguration = URLSessionConfiguration.default
        urlConfiguration.urlCache = nil // Disable cache by default
        return SessionManager(configuration: urlConfiguration)
    }()
    
    // No any instance function in this class, so we prevent construct instance in this class
    private init() { }
    
    static func responseJSON(url: URL, method: HTTPMethod, param: [String: Any]?) -> SignalProducer<Any, Error> {
        return SignalProducer{ (observer, liftTime) in
            let request = ReactiveAlamofire.sessiontManager.request(url, method: method, parameters: param)
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let result):
                        observer.send(value: result)
                        observer.sendCompleted()
                    case .failure(let error):
                        observer.send(error: error)
                    }
                })
            
            liftTime.observeEnded {
                request.cancel()
            }
            
        }
    }
}

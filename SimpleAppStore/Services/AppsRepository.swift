//
//  AppsRepository.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 6/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol AppsRepositoryProtocol {
    func getAppListing(count: Int, offset: Int) -> SignalProducer<AppEntityResponse, APIError>
    func getAppRecommendation(count: Int, offset: Int) -> SignalProducer<AppEntityResponse, APIError>
}

class AppsRepository: AppsRepositoryProtocol {
    static let shared = AppsRepository()
    
    // offset is unused because api is not supported
    func getAppListing(count: Int, offset: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return APIClient.appListing(count: count)
    }
    
    func getAppRecommendation(count: Int, offset: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return APIClient.appRecommendation(count: count)
    }
}

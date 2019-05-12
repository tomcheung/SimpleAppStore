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
    func getAppListing(count: Int) -> SignalProducer<AppEntityResponse, APIError>
    func getAppRecommendation(count: Int) -> SignalProducer<AppEntityResponse, APIError>
}

class AppsRepository: AppsRepositoryProtocol {
    static let shared = AppsRepository()
    
    func getAppListing(count: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return APIClient.appListing(count: count)
    }
    
    func getAppRecommendation(count: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return APIClient.appRecommendation(count: count)
    }
}

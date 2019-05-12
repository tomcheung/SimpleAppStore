//
//  MockAppsRepository.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 12/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import ReactiveSwift
@testable import SimpleAppStore

class MockDataAppsRepository: AppsRepositoryProtocol {
    var mockData: AppEntityResponse
    var mockError: APIError?
    
    init(mockData: AppEntityResponse) {
        self.mockData = mockData
        self.mockError = nil
    }
    
    func getAppListing(count: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return SignalProducer(value: self.mockData).delay(0.3, on: QueueScheduler.main)
    }
    
    func getAppRecommendation(count: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return SignalProducer(value: self.mockData).delay(0.3, on: QueueScheduler.main)
    }
}

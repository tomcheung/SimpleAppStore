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
    var mockData: AppDetailResponse
    var mockError: APIError?
    
    init(mockData: AppDetailResponse) {
        self.mockData = mockData
        self.mockError = nil
    }
    
    func getAppListing(count: Int, offset: Int) -> SignalProducer<[App], APIError> {
        return SignalProducer(value: self.mockData).delay(0.3, on: QueueScheduler.main).map { $0.results }
    }
    
    func getAppRecommendation(count: Int, offset: Int) -> SignalProducer<[App], APIError> {
        return SignalProducer(value: self.mockData).delay(0.3, on: QueueScheduler.main).map { $0.results }
    }
}

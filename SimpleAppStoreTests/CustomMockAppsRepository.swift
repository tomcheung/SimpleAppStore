//
//  CustomMockAppsRepository.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 12/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import ReactiveSwift
@testable import SimpleAppStore

class CustomMockAppsRepository: AppsRepositoryProtocol {
    enum ActionType {
        case appListing
        case recommendation
    }
    
    let fetchActionClosure: ((ActionType) -> SignalProducer<AppEntityResponse, APIError>)
    
    init(fetchActionClosure: @escaping ((ActionType) -> SignalProducer<AppEntityResponse, APIError>)) {
        self.fetchActionClosure = fetchActionClosure
    }
    
    func getAppListing(count: Int, offset: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return self.fetchActionClosure(.appListing)
    }
    
    func getAppRecommendation(count: Int, offset: Int) -> SignalProducer<AppEntityResponse, APIError> {
        return self.fetchActionClosure(.recommendation)
    }
}

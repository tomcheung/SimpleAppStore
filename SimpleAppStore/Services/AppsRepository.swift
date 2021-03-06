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
    func getAppListing(count: Int, offset: Int) -> SignalProducer<[App], APIError>
    func getAppRecommendation(count: Int, offset: Int) -> SignalProducer<[App], APIError>
}

/// A repository to manage data from both api and database
/// It will call the network to fetch, and store data into database, if network fail, it will query the database and return cached (return error if cache not avalible)
/// All ViewModel should access data thougth this class instead of interact data with APIClient / Database directly
class AppsRepository: AppsRepositoryProtocol {
    
    static let shared = AppsRepository()
    
    func getAppListing(count: Int, offset: Int) -> SignalProducer<[App], APIError> {
        // offset is unused in api because it is not supported
        let api = APIClient.appListing(count: count)
            .flatMap(.concat, AppsRepository.fetchAppDetails)
            .on(value: { result in
                do {
                    try DatabaseStorage.shared.saveData(appList: result, type: .appListing, clearPreviousRecords: (offset == 0), inBackground: true, offset: offset)
                } catch {
                    print("Save app listing to database fail: \(error)")
                }
            })

        // For load more case, it should not return cacheed db data
        if offset == 0 {
            return api.flatMapError { (apiError) -> SignalProducer<[App], APIError> in
                // If api failure, return cached value from database if exist
                return AppsRepository.fallbackFetchDatabaseResult(apiError: apiError, type: .appListing)
            }
        } else {
            return api
        }
        
    }
    
    func getAppRecommendation(count: Int, offset: Int) -> SignalProducer<[App], APIError> {
        let api = APIClient.appRecommendation(count: count)
            .flatMap(.concat, AppsRepository.fetchAppDetails)
            .on(value: { result in
                do {
                    try DatabaseStorage.shared.saveData(appList: result, type: .appRecommendation, clearPreviousRecords: (offset == 0), inBackground: true, offset: offset)
                } catch {
                    print("Save app recommendation to database fail: \(error)")
                }
            })
        
        if offset == 0 {
            return api.flatMapError { (apiError) -> SignalProducer<[App], APIError> in
                // If api failure, return cached value from database if exist
                return AppsRepository.fallbackFetchDatabaseResult(apiError: apiError, type: .appRecommendation)
            }
        } else {
            return api
        }
    }
    
    static private func fetchAppDetails(response: AppEntityResponse) -> SignalProducer<[App], APIError> {
        let ids = response.feed.entry.map { $0.appId }
        
        return APIClient.appDetail(appIds: ids)
            .map { appDetailResponse in
                return appDetailResponse.results
            }
        
    }
    
    static private func fallbackFetchDatabaseResult(apiError: APIError, type: DatabaseStorage.AppType) -> SignalProducer<[App], APIError> {
        print("network error when fetch \(type): \(apiError.reason), fetching db data...")
        return AppsRepository.getDatabaseRecord(type: type)
            // If still have error whem fetch database, return the original error
            .mapError { _ in apiError }
            // Or if db have no record, also throw return original error
            .attempt { (dbAppResult) -> Result<(), APIError> in
                if dbAppResult.isEmpty {
                    return .failure(apiError)
                } else {
                    return .success(())
                }
            }
    }
    
    static private func getDatabaseRecord(type: DatabaseStorage.AppType) -> SignalProducer<[App], Error> {
        return SignalProducer { (observer: Signal<[App], Error>.Observer, lifetime) in
            do {
                let result = try DatabaseStorage.shared.fetchData(type: type, inBackground: false)
                observer.send(value: result)
                observer.sendCompleted()
            } catch {
                observer.send(error: error)
            }
        }
    }
    
}

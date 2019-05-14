//
//  AppListViewModel.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 7/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import ReactiveSwift

class AppListViewModel {
    let appsRepository: AppsRepositoryProtocol
    
    // MARK: - External property for ViewController (output)
    let sections: Property<[AppListSection]>
    let serchKeyword: MutableProperty<String?> = MutableProperty<String?>(nil)
    let error: Signal<APIError?, Never>
    let appListing: Property<[App]>
    let appRecommdation: Property<[App]>
    
    // MARK: - Internal property
    private let sectionsInternal: MutableProperty<[AppListSection]>
    
    // MARK: - Actions
    private let fetchAppListAction = Action { (appsRepository: AppsRepositoryProtocol, offset: Int) -> SignalProducer<([App], offset: Int), APIError> in
        return appsRepository.getAppListing(count: 10, offset: offset).map { ($0, offset) }
    }
    private let fetchAppRecommendationAction = Action { (appsRepository: AppsRepositoryProtocol, offset: Int) -> SignalProducer<([App], offset: Int), APIError> in
        return appsRepository.getAppRecommendation(count: 10, offset: offset).map { ($0, offset) }
    }
    
    // MARK: -
    init(appsRepository: AppsRepositoryProtocol = AppsRepository.shared) {
        self.appsRepository = appsRepository
        
        let responseSignal = Signal.combineLatest(self.fetchAppListAction.values, self.fetchAppRecommendationAction.values)
        
        self.error = Signal<APIError?, Never>.merge(
            self.fetchAppListAction.errors.map { $0 }, self.fetchAppRecommendationAction.errors.map { $0 }, // map{$0}: Convert non-optional to optional
            responseSignal.map { _ in nil } // Only reset error state when both app list and app recommendation are return
        )
        
        self.sectionsInternal = MutableProperty<[AppListSection]>(AppListViewModel.skeletionSections())
        self.sections = Property(capturing: self.sectionsInternal)
        
        self.appListing = Property(initial: [], then: self.fetchAppListAction.values.scan([], AppListViewModel.scanFetchedResult))
        self.appRecommdation = Property(initial: [], then: self.fetchAppRecommendationAction.values.scan([], AppListViewModel.scanFetchedResult))
        
        self.sectionsInternal <~ SignalProducer.combineLatest(self.appRecommdation.signal, self.appListing.signal, self.serchKeyword.producer)
            .map(AppListViewModel.mapToSections)
    }
    
    // MARK: - Public method
    func fetchAppList() {
        self.fetchAppListAction.apply((self.appsRepository, offset: 0)).start()
        self.fetchAppRecommendationAction.apply((self.appsRepository, offset: 0)).start()
    }
    
    func fetchNextPage() {
        if self.fetchAppListAction.isExecuting.value {
            return
        }
        self.fetchAppListAction.apply((self.appsRepository, offset: self.appListing.value.count - 1)).start()
    }
    
    private static func scanFetchedResult(lastResult: [App], result: ([App], offset: Int)) -> [App] {
        let (appList, offset) = result
        if offset == 0 {
            return appList
        } else {
            return lastResult + appList
        }
    }
    
    static func filterResult(appViewModels: [AppCellViewModel], keyword: String?) -> [AppCellViewModel] {
        if let keyword = keyword, !keyword.isEmpty {
            return appViewModels.filter {
                // Case insensitive search
                $0.title.lowercased().contains(keyword.lowercased())
            }
        } else {
            return appViewModels
        }
    }
    
    // MARK: - Helper function
    private static func mapAppToViewModel(_ apps: [App]) -> [AppCellViewModel] {
        return apps.enumerated().map { (index, app) in
            AppCellViewModel(app: app, order: index + 1)
        }
    }
    
    private static func skeletionSections() -> [AppListSection] {
        let appSkeletion = (1...10).map { AppCellViewModel.skeletion(order: $0) }
        
        return [
            AppListSection(
                sectionIdentifier: "recommendationSkeletion",
                items: [AppListItem.list(appSkeletion)],
                headerItem: "Recommendation"
            ),
            AppListSection(
                sectionIdentifier: "listingSkeletion",
                items: appSkeletion.map { AppListItem.item($0) },
                headerItem: nil
            )
        ]
    }
    
    private static func mapToSections(appRecommendation: [App], appsList: [App], keyword: String?) -> [AppListSection] {
        let filteredAppRecommendation = AppListViewModel.filterResult(appViewModels: AppListViewModel.mapAppToViewModel(appRecommendation), keyword: keyword)
        let filteredAppsList = AppListViewModel.filterResult(appViewModels: AppListViewModel.mapAppToViewModel(appsList), keyword: keyword)

        let appRecommendationListItem: [AppListItem] = filteredAppRecommendation.isEmpty
            ? [AppListItem.message(
                ErrorMessageCellViewModel(errorMessage: (keyword == nil) ? "no_result".localized : "no_search_result_app_recommendation".localized,
                                          cellHeight: AppListViewController.Style.appRecommendationRowHeight))
              ]
            : [AppListItem.list(filteredAppRecommendation)]
        
        var appListItem: [AppListItem] = filteredAppsList.isEmpty
            ? [AppListItem.message(
                ErrorMessageCellViewModel(errorMessage: (keyword == nil) ? "no_result".localized : "no_search_result_app_listing".localized,
                                          cellHeight: AppListViewController.Style.appListingRowHeight))
              ]
            : filteredAppsList.map { AppListItem.item($0) }
        
        if keyword == nil && !appsList.isEmpty {
            // Last item loading indicator
            appListItem.append(AppListItem.item(AppCellViewModel.skeletion(order: appListItem.count + 1)))
        }
        
        return [
            AppListSection(
                sectionIdentifier: "recommendation",
                items: appRecommendationListItem,
                headerItem: nil
            ),
            AppListSection(
                sectionIdentifier: "listing",
                items: appListItem,
                headerItem: nil
            )
        ]
    }
}

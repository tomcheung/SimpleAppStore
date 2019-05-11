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
    
    // MARK: - External property for ViewController (output)
    let sections: Property<[AppListSection]>
    let serchKeyword: MutableProperty<String?> = MutableProperty<String?>(nil)
    
    // MARK: - Internal property
    let sectionsInternal: MutableProperty<[AppListSection]>
    
    // MARK: - Actions
    private let fetchAppListAction = Action { () -> SignalProducer<AppEntityResponse, APIClient.APIError> in
        return APIClient.appListing()
    }
    private let fetchAppRecommendationAction = Action { () -> SignalProducer<AppEntityResponse, APIClient.APIError> in
        return APIClient.appRecommendation()
    }
    
    // MARK: -
    init() {
        let appSkeletion = (1...10).map { AppCellViewModel.skeletion(order: $0) }
        let skeletionSections = AppListViewModel.mapToSections(appRecommendation: appSkeletion, appsList: appSkeletion, keyword: nil)
        self.sectionsInternal = MutableProperty<[AppListSection]>(skeletionSections)
        self.sections = Property(capturing: self.sectionsInternal)

        let appListing = self.fetchAppListAction.values
            .map { (response) -> [AppCellViewModel] in
                return response.feed.entry.enumerated().map { (index, app) in
                    AppCellViewModel(app: app, order: index + 1)
                }
            }

        let appRecommendation = self.fetchAppRecommendationAction.values
            .map { (response) -> [AppCellViewModel] in
                return response.feed.entry.map { AppCellViewModel(app: $0, order: 0) } // App Recommendation do not require display order
            }
        
        self.sectionsInternal <~ SignalProducer.combineLatest(appRecommendation, appListing, self.serchKeyword.producer)
            .map(AppListViewModel.mapToSections)
    }
    
    // MARK: - Public method
    func fetchAppList() {
        self.fetchAppListAction.apply().start()
        self.fetchAppRecommendationAction.apply().start()
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
    
    static func mapAppToViewModel(_ apps: [App]) -> [AppCellViewModel] {
        return apps.enumerated().map { (index, app) in
            AppCellViewModel(app: app, order: index + 1)
        }
    }
    
    static func mapToSections(appRecommendation: [AppCellViewModel], appsList: [AppCellViewModel], keyword: String?) -> [AppListSection] {
        let filteredAppRecommendation = AppListViewModel.filterResult(appViewModels: appRecommendation, keyword: keyword)
        let filteredAppsList = AppListViewModel.filterResult(appViewModels: appsList, keyword: keyword)
        
        let appRecommendationListItem: [AppListItem] = filteredAppRecommendation.isEmpty
            ? [AppListItem.error(
                ErrorMessageCellViewModel(errorMessage: (keyword == nil) ? "No Result" : "No serach result on app recommendation",
                                          cellHeight: AppListViewController.Style.appRecommendationRowHeight)
                )]
            : [AppListItem.list(filteredAppRecommendation)]
        
        let appListItem: [AppListItem] = filteredAppsList.isEmpty
            ? [AppListItem.error(
                ErrorMessageCellViewModel(errorMessage: (keyword == nil) ? "No Result" : "No serach result on app listing",
                                          cellHeight: 80)
                )]
            : filteredAppsList.map { AppListItem.item($0) }
        
        return [
            AppListSection(
                sectionIdentifier: "recommendation",
                items: appRecommendationListItem,
                headerItem: "Recommendation"
            ),
            AppListSection(
                sectionIdentifier: "listing",
                items: appListItem,
                headerItem: "App listing"
            )
        ]
    }
}

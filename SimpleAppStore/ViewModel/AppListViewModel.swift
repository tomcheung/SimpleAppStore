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
        let skeletionSections = AppListViewModel.mapToSections(appRecommendation: appSkeletion, appsList: appSkeletion)
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
        
        self.sectionsInternal <~ Signal.combineLatest(appRecommendation, appListing)
            .map(AppListViewModel.mapToSections)
    }
    
    // MARK: - Public method
    func fetchAppList() {
        self.fetchAppListAction.apply().start()
        self.fetchAppRecommendationAction.apply().start()
    }
    
    static func mapToSections(appRecommendation: [AppCellViewModel], appsList: [AppCellViewModel]) -> [AppListSection] {
        return [
            AppListSection(
                sectionIdentifier: "recommendation",
                items: [AppListItem.list(appRecommendation)],
                headerItem: "Recommendation"
            ),
            AppListSection(
                sectionIdentifier: "listing",
                items: appsList.map { AppListItem.item($0) },
                headerItem: "App listing"
            )
        ]
    }
}

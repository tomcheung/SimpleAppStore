//
//  AppListSection.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 6/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import ReactiveDataSource

enum AppListItem {
    case list([AppCellViewModel])
    case item(AppCellViewModel)
    case error(ErrorMessageCellViewModel)
}

extension AppListItem: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .list(let appList):
            hasher.combine(appList)
        case .item(let app):
            hasher.combine(app)
        case .error(let errorCellModel):
            hasher.combine(errorCellModel)
        }
    }
}

struct AppListSection: ReactiveDataSourceHeaderFooterSection {
    typealias HeaderItem = String
    typealias FooterItem = String
    typealias Item = AppListItem
    
    let headerItem: String?
    let footerItem: String?
    var uniqueIdentifier: String
    var items: [Item]
    
    init(sectionIdentifier: String, items: [Item], headerItem: String) {
        self.uniqueIdentifier = sectionIdentifier
        self.items = items
        self.headerItem = headerItem
        self.footerItem = nil // We only need header, don't need footer
    }
    
}

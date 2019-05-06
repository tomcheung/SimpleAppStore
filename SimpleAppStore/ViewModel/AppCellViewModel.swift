//
//  AppCellViewModel.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 7/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation

struct AppCellViewModel: Hashable {
    let title: String
    let subtitle: String
    let order: Int
    let imageURL: URL?
    var isSkeletion: Bool
    
    init(title: String, subtitle: String, order: Int, imageURL: URL?, isSkeletion: Bool) {
        self.title = title
        self.subtitle = subtitle
        self.order = order
        self.imageURL = imageURL
        self.isSkeletion = isSkeletion
    }
    
    init(app: App, order: Int) {
        self.init(title: app.appName, subtitle: app.appCategory, order: order, imageURL: app.imageURL, isSkeletion: false)
    }

    static func skeletion(order: Int) -> AppCellViewModel {
        return AppCellViewModel(title: "", subtitle: "", order: order, imageURL: nil, isSkeletion: true)
    }
    
}

//
//  AppEntity+App.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 13/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation

extension AppEntity: App {
    var appRating: Decimal? {
        if let rating = self.rating {
            return rating as Decimal
        } else {
            return nil
        }
    }
    
    var appId: String {
        return self.id ?? "-1"
    }
    
    var appName: String {
        return self.name ?? ""
    }
    
    var appCategory: String {
        return self.category ?? ""
    }
    
    var appImageURL: URL? {
        if let imageURL = self.imageURL {
            return URL(string: imageURL)
        } else {
            return nil
        }
    }
    
    func updateValue(from app: App) {
        self.id = app.appId
        self.name = app.appName
        self.category = app.appCategory
        self.imageURL = app.appImageURL?.absoluteString
    }
}

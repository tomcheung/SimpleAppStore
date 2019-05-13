//
//  AppDetail.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 13/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation

struct AppDetailResponse: Codable {
    let results: [AppDetail]
}

struct AppDetail: Codable {
    let trackName: String
    let trackId: Int
    let artworkUrl512: String
    let artworkUrl60: String
    let artworkUrl100: String
    let genres: [String]
    let averageUserRating: Double?
    let userRatingCount: Int?
}

extension AppDetail: App {
    
    var appName: String {
        return self.trackName
    }
    
    var appCategory: String {
        return self.genres.first ?? ""
    }
    
    var appImageURL: URL? {
        return URL(string: self.artworkUrl100)
    }
    
    var appId: String {
        return String(self.trackId)
    }
    
    var appRating: Double? {
        return self.averageUserRating
    }
    
    var appUserRatingCount: Int? {
        return self.userRatingCount
    }
}

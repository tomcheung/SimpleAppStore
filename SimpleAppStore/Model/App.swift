//
//  App.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation

protocol App {
    var appName: String { get }
    var appCategory: String { get }
    var appImageURL: URL? { get }
    var appId: String { get }
    var appRating: Decimal? { get }
}

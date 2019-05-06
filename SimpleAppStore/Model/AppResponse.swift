//
//  AppEntityResponse.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation

struct AppEntityResponse: Codable {
    
    struct Feed: Codable {
        let entry: [Entry]
    }
    
    struct LabelAttributes: Codable {
        let label: String
        let attributes: [String: String]?
    }
    
    struct Category: Codable {
        let attributes: [String: String]
    }
    
    struct Entry: Codable {
        let name: LabelAttributes
        let image: [LabelAttributes]
        let category: Category
        
        fileprivate enum CodingKeys: String, CodingKey {
            case name = "im:name"
            case image = "im:image"
            case category
        }
    }
    
    let feed: Feed
    
}

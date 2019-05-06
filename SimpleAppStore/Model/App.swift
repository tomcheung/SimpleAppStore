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
    var imageURL: URL? { get }
}

extension AppEntityResponse.Entry: App {
    var appName: String { return self.name.label }
    var appCategory: String { return self.category.attributes["label"] ?? "" }
    var imageURL: URL? {
        // Get the largest image from response im:image, base on it attributes.height
        let sordedImageURLString = self.image.sorted { (attr1, attr2) -> Bool in
            guard let attr1HeightAttrString = attr1.attributes?["height"], let attr2HeightAttrString = attr2.attributes?["height"] else {
                return true
            }
            
            if let imgHeight1 = Int(attr1HeightAttrString), let imgHeight2 = Int(attr2HeightAttrString) {
                return imgHeight1 < imgHeight2
            } else {
                return true
            }
        }
        
        if let imageURLLabel = sordedImageURLString.last?.label {
            return URL(string: imageURLLabel)
        } else {
            return nil
        }
    }
}

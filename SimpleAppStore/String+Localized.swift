//
//  String+Localized.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 14/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

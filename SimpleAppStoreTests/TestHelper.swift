//
//  TestHelper.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 12/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
@testable import SimpleAppStore

final class TestHelper {
    /// Load the sample json file from app bundle
    ///
    /// - Parameter filename: json filename WITHOUT extension (.json)
    /// - Returns: JSON dictionary
    static func loadJSONSampleFile(filename: String) -> Any {
        guard let path = Bundle(for: TestHelper.self).url(forResource: filename, withExtension: "json") else {
            fatalError("JSON sample file \(filename).json not exist!!")
        }
        
        do {
            let sampleFileData = try Data(contentsOf: path)
            return try JSONSerialization.jsonObject(with: sampleFileData, options: [])
        } catch {
            fatalError("Read JSON sample file \(filename).json fail \(error)!!")
        }
    }
    
    static func loadSampleResponse(jsonFile: String) throws -> AppDetailResponse {
        let sample = loadJSONSampleFile(filename: jsonFile)
        return try APIClient.mapResponse(json: sample)
    }
}

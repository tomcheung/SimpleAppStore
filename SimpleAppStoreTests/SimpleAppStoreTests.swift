//
//  SimpleAppStoreTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
@testable import SimpleAppStore

class SimpleAppStoreTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppListJSONParsing() {
        guard let sampleJSON = loadJSONSampleFile(filename: "TopAppListingSampleResponse") else {
            assertionFailure("Load json fail")
            return
        }
        expect(try APIClient.mapResponse(json: sampleJSON) as AppEntityResponse).notTo(throwError())
    }
    
    /// Load the sample json file from app bundle
    ///
    /// - Parameter filename: json filename WITHOUT extension (.json)
    /// - Returns: JSON dictionary, return nil if load fail
    private func loadJSONSampleFile(filename: String) -> [String:Any]? {
        guard let path = Bundle(for: SimpleAppStoreTests.self).url(forResource: filename, withExtension: "json") else {
            print("JSON sample file \(filename).json not exist!!")
            return nil
        }
        
        do {
            let sampleFileData = try Data(contentsOf: path)
            return try JSONSerialization.jsonObject(with: sampleFileData, options: []) as? [String: Any]
        } catch {
            print("Read JSON sample file \(filename).json fail \(error)!!")
            return nil
        }
    }

}

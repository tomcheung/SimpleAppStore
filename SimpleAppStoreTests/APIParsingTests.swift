//
//  APIParsingTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
@testable import SimpleAppStore

class APIParsingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppListJSONParsing() {
        let sampleJSON = TestHelper.loadJSONSampleFile(filename: "TopAppListingSampleResponse")
        expect(try APIClient.mapResponse(json: sampleJSON) as AppEntityResponse).notTo(throwError())
    }
    
    func testLoadInvalidJSON() {
        let sampleJSON = TestHelper.loadJSONSampleFile(filename: "InvalidSampleResponse")
        expect(try APIClient.mapResponse(json: sampleJSON) as AppEntityResponse).to(throwError(errorType: DecodingError.self))
    }

}

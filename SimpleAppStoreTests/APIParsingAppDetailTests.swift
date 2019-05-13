//
//  APIParsingAppDetailTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 13/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
@testable import SimpleAppStore

class APIParsingAppDetailTests: XCTestCase {

    func testFetchAppDetail() {
        let appDetail = APIClient.appDetail(appIds: ["1084662006"])
        let resultObserver = TestObserver<AppDetailResponse, APIError>()
        appDetail.start(resultObserver.observer)
        
        expect(resultObserver.lastValue?.results.first?.trackId).toEventually(equal(1084662006), timeout: 1)
        expect(resultObserver.failedError).toEventually(beNil(), timeout: 1)
    }

}

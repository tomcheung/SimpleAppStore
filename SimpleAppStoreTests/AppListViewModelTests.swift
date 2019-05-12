//
//  AppListViewModelTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 12/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
import ReactiveSwift

@testable import SimpleAppStore

class AppListViewModelTests: XCTestCase {
    
    var viewModel: AppListViewModel!
    var mockAppsRepository: MockDataAppsRepository!
    var testObserver: TestObserver<[AppListSection], Never>!
    
    override func setUp() {
        self.testObserver = TestObserver<[AppListSection], Never>()
        self.mockAppsRepository = MockDataAppsRepository(mockData: try! TestHelper.loadSampleResponse(jsonFile: "MockResponse"))
        self.viewModel = AppListViewModel(appsRepository: self.mockAppsRepository)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchAppListingData() {
        self.viewModel.fetchAppList()
        self.viewModel.sections.signal.observe(self.testObserver.observer)
        
        let expectedCellViewModel = AppCellViewModel(title: "Testing App 1",
                                                     subtitle: "遊戲",
                                                     order: 1,
                                                     imageURL: URL(string: "https://is3-ssl.mzstatic.com/image/thumb/Purple128/v4/5e/90/4a/5e904a82-5707-99e9-7e7e-fcc630ccf4e5/AppIcon-0-1x_U007emarketing-0-85-220-6.png/100x100bb-85.png"),
                                                     isSkeletion: false)
        
        let expectedResult = AppListSection(sectionIdentifier: "listing", items: [.item(expectedCellViewModel)], headerItem: nil)
        self.viewModel.fetchAppList()
        
        // Only compare last section (App Listing)
        expect(self.testObserver.lastValue?.last).toEventually(equal(expectedResult), timeout: 1)
    }
    
    func testFetchAppListingWithNoResult() {
        let emptyResponse = AppEntityResponse.Feed(entry: [])
        self.mockAppsRepository.mockData = AppEntityResponse(feed: emptyResponse)
        
        self.viewModel.sections.signal.observe(self.testObserver.observer)
        let expectedResult = AppListSection(sectionIdentifier: "listing",
                                            items: [.message(ErrorMessageCellViewModel(errorMessage: "No Result", cellHeight: AppListViewController.Style.appListingRowHeight))],
                                            headerItem: nil)

        self.viewModel.fetchAppList()
        expect(self.testObserver.lastValue?.last).toEventually(equal(expectedResult), timeout: 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

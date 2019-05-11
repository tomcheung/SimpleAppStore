//
//  AppListViewController.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 6/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import ReactiveDataSource

class AppListViewController: UIViewController, UITableViewDelegate {
    
    struct Style {
        static let headerRowHeight: CGFloat = 50
        static let appListingRowHeight: CGFloat = 80
        static let appRecommendationRowHeight: CGFloat = 170
    }
    
    // MARK: - Interface builder
    @IBOutlet weak var mainAppTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let mainListDataSource = ReactiveHeaderFooterTableViewDataSource<AppListSection>()
    let viewModel = AppListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDatasource()
        self.bindSearchInput()
        self.viewModel.fetchAppList()
    }
    
    private func bindSearchInput() {
        self.viewModel.serchKeyword <~ self.searchBar.reactive.continuousTextValues.debounce(0.3, on: QueueScheduler.main)
    }
    
    private func setupDatasource() {
        self.mainListDataSource.headerHeight = { _ in Style.headerRowHeight }
        self.mainListDataSource.headerIdentifier = { _ in "header" }
        
        self.mainListDataSource.reuseIdentifier = { viewModel in
            switch viewModel {
            case .item:
                return "appCell"
            case .list:
                return "appListCell"
            case .error:
                return "errorMessage"
            }
        }
        
        self.mainAppTableView.reactive.setReactiveDataSource(self.mainListDataSource)
        self.mainListDataSource.sections <~ self.viewModel.sections
        self.mainListDataSource.tableViewDelegate = self
        
        self.mainAppTableView.isSkeletonable = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellViewModel = self.mainListDataSource.item(at: indexPath) else {
            return 100
        }
        
        switch cellViewModel {
        case .error(let errorCellModel):
            return errorCellModel.cellHeight
        case .item:
            return Style.appListingRowHeight
        case .list:
            return Style.appRecommendationRowHeight
        }
    }

}


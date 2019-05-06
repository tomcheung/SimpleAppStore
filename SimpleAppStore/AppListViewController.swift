//
//  AppListViewController.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 6/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import SkeletonView
import ReactiveSwift
import ReactiveCocoa
import ReactiveDataSource

class AppListViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Interface builder
    @IBOutlet weak var mainAppTableView: UITableView!
    
    let mainListDataSource = ReactiveHeaderFooterTableViewDataSource<AppListSection>()
    let viewModel = AppListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainListDataSource.headerHeight = { _ in 50 }
        self.mainListDataSource.headerIdentifier = { _ in "header" }
        
        self.mainListDataSource.reuseIdentifier = { viewModel in
            switch viewModel {
            case .item:
                return "appCell"
            case .list:
                return "appListCell"
            }
        }
        
        self.mainAppTableView.reactive.setReactiveDataSource(self.mainListDataSource)
        self.mainListDataSource.sections <~ self.viewModel.sections
        self.mainListDataSource.tableViewDelegate = self
        
        self.mainAppTableView.isSkeletonable = true
        
        self.viewModel.fetchAppList()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellViewModel = self.mainListDataSource.item(at: indexPath) else {
            return 100
        }
        
        switch cellViewModel {
        case .item:
            return 80
        case .list:
            return 170
        }
    }

}


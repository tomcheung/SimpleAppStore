//
//  AppCollectionViewCell.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 11/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveDataSource

class AppCollectionViewCell: ReactiveCollectionViewCell<AppListItem>, AppReuseView {
    @IBOutlet var appImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appImageView.layer.cornerRadius = 20
    }
    
    override func bind(viewModel: AppListItem, disposable: CompositeDisposable) {
        guard case .item(let appCellModel) = viewModel else {
            print("item mismatch: \(viewModel)")
            return
        }
        
        self.updateUI(appCellViewModel: appCellModel)
        
    }
}

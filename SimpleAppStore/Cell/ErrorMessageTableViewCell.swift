//
//  ErrorMessageTableViewCell.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 11/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveDataSource

class ErrorMessageTableViewCell: ReactiveTableViewCell<AppListItem> {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func bind(viewModel: AppListItem, disposable: CompositeDisposable) {
        guard case let .error(errorMessageViewModel) = viewModel else {
            return
        }
        
        self.textLabel?.text = errorMessageViewModel.errorMessage
    }
}

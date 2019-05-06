//
//  ReactiveCollectionViewCell.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 2/8/2018.
//  Copyright © 2018 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveSwift

open class ReactiveCollectionViewCell<ViewModel>: UICollectionViewCell, ReactiveBindableCell {
	open func bind(viewModel: ViewModel, disposable: CompositeDisposable) {
		#if DEBUG
			fatalError("Override this method")
		#endif
	}
}

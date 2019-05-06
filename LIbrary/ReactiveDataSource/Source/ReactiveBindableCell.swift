//
//  ReactiveDataSourceCell.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 17/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveSwift

public protocol ReactiveCell {
	func bind(model: Any, disposable: CompositeDisposable)
}

public protocol ReactiveBindableCell: ReactiveCell {
	associatedtype ViewModel

	func bind(viewModel: ViewModel, disposable: CompositeDisposable)
}

public extension ReactiveBindableCell {
	func bind(model: Any, disposable: CompositeDisposable) {
		if let viewModel = model as? ViewModel {
			self.bind(viewModel: viewModel, disposable: disposable)
		}
	}
}

//
//  UITableView+Reactive.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 17/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import Foundation
import ReactiveSwift

extension Reactive where Base: UITableView {

	/*
	Seeking better solution for construct more elegant way to bind datasource:
	`self.tableView.reactive.items <~ SignalProducer<[Section], NoError>(value: [Section1, Section2, Section3])`
	Sadly swift array don't allow using [ReactiveDataSourceSection]

	var item: BindingTarget<[Section]> {
	return makeBindingTarget { (tableView, sections) in

	}
	}
	*/

	public func setReactiveDataSource<T>(_ dataSource: ReactiveHeaderFooterTableViewDataSource<T>) {
		self.base.dataSource = dataSource
		self.base.delegate = dataSource
		dataSource.tableView = self.base
	}

	public func setReactiveDataSource<T>(_ dataSource: ReactiveTableViewDataSource<T>) {
		self.base.dataSource = dataSource
		dataSource.tableView = self.base
	}
}


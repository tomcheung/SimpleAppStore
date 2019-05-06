//
//  ReactiveTableHeaderFooterView.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 17/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit

open class ReactiveTableHeaderFooterView<Section: Hashable>: UITableViewHeaderFooterView {
	open func bind(item: Section?) {
		#if DEBUG
		fatalError("Override this method")
		#endif
	}
}

//
//  ReactiveHeaderFooterTableViewDataSource.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 17/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit

open class ReactiveHeaderFooterTableViewDataSource<Section: ReactiveDataSourceHeaderFooterSection>: ReactiveTableViewDataSource<Section>, UITableViewDelegate {

	public var headerHeight: ((Section.HeaderItem) -> CGFloat)?
	public var footerHeight: ((Section.FooterItem) -> CGFloat)?
	public var headerIdentifier: ((Int) -> String?)?
	public var footerIdentifier: ((Int) -> String?)?
    public weak var tableViewDelegate: UITableViewDelegate?

    // MARK: - UITableViewDataSource
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection sectionIndex: Int) -> CGFloat {
		if let headerItem = sectionsSnapshot[sectionIndex].headerItem {
			return headerHeight?(headerItem) ?? 20
		} else {
			return 0
		}
	}

    open func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
		let headerSection = sectionsSnapshot[sectionIndex]
		guard let identifier = headerIdentifier?(sectionIndex), let headerItem = headerSection.headerItem else {
			return nil
		}

		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)

		if let headerView = header as? ReactiveTableHeaderFooterView<Section.HeaderItem> {
			headerView.bind(item: headerItem)
		}

		return header
	}

    open func tableView(_ tableView: UITableView, heightForFooterInSection sectionIndex: Int) -> CGFloat {
		if let headerItem = sectionsSnapshot[sectionIndex].footerItem {
			return footerHeight?(headerItem) ?? 0
		} else {
			return 0
		}
	}

    open func tableView(_ tableView: UITableView, viewForFooterInSection sectionIndex: Int) -> UIView? {
		let footerSection = sectionsSnapshot[sectionIndex]
		guard let identifier = footerIdentifier?(sectionIndex), let footerItem = footerSection.footerItem else {
			return nil
		}

		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)

		if let footerView = header as? ReactiveTableHeaderFooterView<Section.FooterItem> {
			footerView.bind(item: footerItem)
		}

		return header
	}
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewDelegate?.tableView?(tableView, heightForRowAt: indexPath) ?? UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewDelegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableViewDelegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return self.tableViewDelegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? 0
    }

}

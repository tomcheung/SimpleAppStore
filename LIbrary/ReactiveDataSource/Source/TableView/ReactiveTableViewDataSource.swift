//
//  ReactiveTableViewDataSource.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 3/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveSwift

open class ReactiveTableViewDataSource<Section: ReactiveDataSourceSection>: ReactiveDataSource<Section>, UITableViewDataSource {
    public weak var tableView: UITableView?
    
    override func applyUpdateView(newSections: [Section], datasourceChangeset: DataSourceChangeset, completion: ((Bool) -> Void)?) {
        guard let tableView = self.tableView else {
            self.sectionsSnapshot = newSections
            return
        }
        
        tableView.beginUpdates()
        
        self.sectionsSnapshot = newSections
        
        // Sections
        tableView.insertSections(datasourceChangeset.insertSections, with: .automatic)
        tableView.deleteSections(datasourceChangeset.deleteSections, with: .automatic)
        for move in datasourceChangeset.movedSections {
            tableView.moveSection(move.from, toSection: move.to)
        }
        
        // Item
        tableView.insertRows(at: datasourceChangeset.insertItems, with: .automatic)
        tableView.deleteRows(at: datasourceChangeset.deleteItems, with: .automatic)
        for move in datasourceChangeset.movedItems {
            tableView.moveRow(at: move.from, to: move.to)
        }
        
        tableView.endUpdates()
        completion?(true)
    }
    
    override func reloadView() {
        self.tableView?.reloadData()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsSnapshot.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsSnapshot[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else {
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        
        let cellId = reuseIdentifier?(item) ?? "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        disposableDictionary[cell]?.dispose()
        if let binableCell = cell as? ReactiveCell {
            let disposable = CompositeDisposable()
            binableCell.bind(model: item, disposable: disposable)
            disposableDictionary[cell] = disposable
        }
        
        return cell
    }

}


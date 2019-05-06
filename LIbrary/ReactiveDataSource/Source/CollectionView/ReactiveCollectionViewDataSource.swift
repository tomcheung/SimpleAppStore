//
//  ReactiveCollectionViewDataSource.swift
//  ReactiveDataSource
//
//  Created by Cheung Chun Hung on 3/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveSwift

open class ReactiveCollectionViewDataSource<Section: ReactiveDataSourceSection>: ReactiveDataSource<Section>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public weak var collectionView: UICollectionView?
    public var collectionViewDelegate: UICollectionViewDelegate?

	override func applyUpdateView(newSections: [Section], datasourceChangeset: DataSourceChangeset, completion: ((Bool) -> Void)?) {
        guard let collectionView = self.collectionView else {
			self.sectionsSnapshot = newSections
			return
		}

		collectionView.performBatchUpdates({
			self.sectionsSnapshot = newSections
			// Sections
			collectionView.insertSections(datasourceChangeset.insertSections)
			collectionView.deleteSections(datasourceChangeset.deleteSections)
			for move in datasourceChangeset.movedSections {
				collectionView.moveSection(move.from, toSection: move.to)
			}

			// Item
			collectionView.insertItems(at: datasourceChangeset.insertItems)
			collectionView.deleteItems(at: datasourceChangeset.deleteItems)
			for move in datasourceChangeset.movedItems {
				collectionView.moveItem(at: move.from, to: move.to)
			}
		}, completion: completion)
    }

	override func reloadView() {
		self.collectionView?.reloadData()
	}

    //MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionsSnapshot.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionsSnapshot[section].items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = self.item(at: indexPath) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }

        let cellId = reuseIdentifier?(item) ?? "cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)

        disposableDictionary[cell]?.dispose()
        if let binableCell = cell as? ReactiveCell {
            let disposable = CompositeDisposable()
            binableCell.bind(model: item, disposable: disposable)
            disposableDictionary[cell] = disposable
        }

        return cell
    }

    //MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, didHighlightItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, didUnhighlightItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool  {
        return self.collectionViewDelegate?.collectionView?(collectionView, shouldSelectItemAt: indexPath) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool  {
        return self.collectionViewDelegate?.collectionView?(collectionView, shouldDeselectItemAt: indexPath) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }

    //MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let delegateFlowLayout = self.collectionViewDelegate as? UICollectionViewDelegateFlowLayout,
            let size = delegateFlowLayout.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) {
            return size
        } else {
            if #available(iOS 10.0, *) {
                return UICollectionViewFlowLayout.automaticSize
            } else {
                return collectionViewLayout.collectionViewContentSize
            }
        }
    }

}

extension Reactive where Base: UICollectionView {

	public func setReactiveDataSource<T>(_ dataSource: ReactiveCollectionViewDataSource<T>) {
		self.base.dataSource = dataSource
//        self.base.delegate = dataSource
		dataSource.collectionView = self.base
	}

	//	func sections<T:ReactiveDataSourceSection>() -> BindingTarget<[T]> {
	//		return self.makeBindingTarget(on: UIScheduler()) { (collectionView, [T]) in
	//
	//		}
	//	}
}


//
//  ReactiveDataSource.swift
//  ReactiveDataSource
//
//  Created by Tom Cheung on 2/8/2018.
//

import UIKit
import ReactiveSwift
import FlexibleDiff

public protocol ReactiveDataSourceSection: Equatable {
	associatedtype Item: Hashable

	/// A identifier to indicate whenever is same section (inner item may be different) when compute delta operation.
	/// If uniqueIdentifier is same but items array is change, it will perform compute item delta by default
	var uniqueIdentifier: String { get }
	var items: [Item] { get }
}

extension ReactiveDataSourceSection {
    public static func != (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
}

public protocol ReactiveDataSourceHeaderFooterSection: ReactiveDataSourceSection {
	associatedtype HeaderItem: Hashable
	associatedtype FooterItem: Hashable
	var headerItem: HeaderItem? { get }
	var footerItem: FooterItem? { get }
}

internal let deltaComputeQueue = DispatchQueue(label: "reactiveDataSource.delta")

public enum ReactiveDataSourceUpdatesStrategy {
	case reloadAll
	case deltaItems
}

public struct DataSourceChangeset {
    var insertSections: IndexSet
    var deleteSections: IndexSet
    var movedSections: [(from: Int, to: Int)]

    // Delta of items
    var insertItems: [IndexPath]
    var deleteItems: [IndexPath]
    var movedItems: [(from: IndexPath, to: IndexPath)]
}

open class ReactiveDataSource<Section: ReactiveDataSourceSection>: NSObject {
	public let sections = MutableProperty<[Section]>([])
	public var showDeltaLog: Bool = false
    public var reuseIdentifier: ((Section.Item) -> String)?
	public var updateStrategy: ReactiveDataSourceUpdatesStrategy = .deltaItems
    public let sectionsChange: Signal<[Section], Never>

	internal var sectionsSnapshot: [Section] = []
    internal var deltaTimestamp: CFTimeInterval = 0

	// TODO: Pending deprecate
	var disposableDictionary = [UIView: CompositeDisposable]()

	public override init() {
		let (sectionsChangeSignal, sectionsChangeObserver) = Signal<[Section], Never>.pipe()
		self.sectionsChange = sectionsChangeSignal

		super.init()

		self.sections.signal
			.throttle(0.3, on: QueueScheduler.main)
			.observeValues { [weak self] (newSections) in
				guard let strongSelf = self else { return }

				if strongSelf.sectionsSnapshot.isEmpty {
					strongSelf.sectionsSnapshot = newSections
					strongSelf.reloadView()
					return
				}

				switch strongSelf.updateStrategy {
				case .deltaItems:
					// Perform delta computation in background to prevent block user interaction
					let oldSections = strongSelf.sectionsSnapshot

					let timestamp = CFAbsoluteTimeGetCurrent()
					strongSelf.deltaTimestamp = timestamp

					deltaComputeQueue.async {
						let changeset = ReactiveCollectionViewDataSource.computeChangeset(previousSection: oldSections, currentSection: newSections)

						if strongSelf.showDeltaLog {
							print("[ReactiveCollectionViewDataSource]", changeset, "oldSections", oldSections, "oldSections", newSections)
						}

						DispatchQueue.main.async {
							guard timestamp == strongSelf.deltaTimestamp else {
								print("[ReactiveCollectionViewDataSource] A new dataset found, skip the batch update, (latestTimestamp: \(self?.deltaTimestamp ?? -1), update timestamp: \(timestamp)")
								return
							}
							strongSelf.applyUpdateView(newSections: newSections, datasourceChangeset: changeset, completion: { _ in
								sectionsChangeObserver.send(value: newSections)
							})
						}
					}

				case .reloadAll:
					strongSelf.sectionsSnapshot = newSections
					strongSelf.reloadView()
					sectionsChangeObserver.send(value: newSections)
				}
		}
	}

    static func computeChangeset(previousSection: [Section], currentSection: [Section]) -> DataSourceChangeset {

		let sectionChangeset = Changeset(previous: previousSection, current: currentSection, identifier: { $0.uniqueIdentifier })

        var changeset = DataSourceChangeset(
            // Delta of sections

            insertSections  : sectionChangeset.inserts,
            deleteSections  : sectionChangeset.removals,
            movedSections   : [],

            // Delta of items
            insertItems     : [],
            deleteItems     : [],
            movedItems      : []
        )

        // Delta of item, with item change animation
        for sectionIndex in sectionChangeset.mutations {
            let (oldItems, newItems) = (previousSection[sectionIndex].items, currentSection[sectionIndex].items)
            let itemChange = Changeset(previous: oldItems, current: newItems)


            let insertIndexPath = itemChange.inserts.map { IndexPath(item: $0, section: sectionIndex) }
            changeset.insertItems.append(contentsOf: insertIndexPath)

            let deleteIndexPath = itemChange.removals.map { IndexPath(item: $0, section: sectionIndex) }
            changeset.deleteItems.append(contentsOf: deleteIndexPath)

            for moveIndexPath in itemChange.moves {
                changeset.movedItems.append((
                    from:   IndexPath(item: moveIndexPath.source, section: sectionIndex),
                    to:     IndexPath(item: moveIndexPath.destination, section: sectionIndex)
                ))
            }
        }

		var mutatedSections = IndexSet()
		for move in sectionChangeset.moves where move.isMutated {
//			print("insert", move.source, move.destination)
			mutatedSections.insert(move.destination)
			mutatedSections.insert(move.source)
			// print("insert", move.source, move.destination)
		}

		var mutatedMoveSections: (insertSections:IndexSet, deleteSections: IndexSet) = (IndexSet(), IndexSet())
		//TODO: Workaround solution, delete than insert changed section, can do both section and item delta together?
		for move in sectionChangeset.moves {
			if !mutatedSections.contains(move.source) && !mutatedSections.contains(move.destination) {
                changeset.movedSections.append((from: move.source, to: move.destination))
//				print("move", move.source, move.destination)
			} else {
				// If one of move (source OR destination, not both) is mutated, those section also required perform delete than insert operation
				mutatedMoveSections.insertSections.insert(move.destination)
				mutatedMoveSections.deleteSections.insert(move.source)
			}
		}

		// If inner item changed, cannot call moveSection because num of item in section is different
        changeset.insertSections.formUnion(mutatedMoveSections.insertSections)
        changeset.deleteSections.formUnion(mutatedMoveSections.deleteSections)

        return changeset
	}

	public func item(at indexPath: IndexPath) -> Section.Item? {
		guard sectionsSnapshot.indices.contains(indexPath.section) && sectionsSnapshot[indexPath.section].items.indices.contains(indexPath.row) else {
			return nil
		}
		return sectionsSnapshot[indexPath.section].items[indexPath.item]
	}

	func applyUpdateView(newSections: [Section], datasourceChangeset: DataSourceChangeset, completion: ((Bool) -> Void)?) {
		// Override by sub-class
	}

	func reloadView() {
		// Override by sub-class
	}

}

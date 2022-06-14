//
//  GIFViewPresenter.swift
//  GiphyAssignment
//
//  Created by Sri on 13/06/22.
//

import Foundation
import UIKit

final class GIFCollectionViewHandler<CellType: UICollectionViewCell & CellDataProvider>: NSObject {

    private enum Section: Hashable { case main }

    typealias Item = CellType.DataItem
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private weak var collectionView: UICollectionView?
    private lazy var dataSource: DataSource = makeDataSource()
    var items = [Item]()


    private weak var cellDelegate: GiphyCellDelegate?
    private weak var imageFetcher: AsyncImageFetcher?


    init(collectionView: UICollectionView, cellDelegate: GiphyCellDelegate?, imageFetcher: AsyncImageFetcher) {
        self.collectionView = collectionView
        self.cellDelegate = cellDelegate
        self.imageFetcher = imageFetcher
        super.init()
    }
}

extension GIFCollectionViewHandler {

    private func cellProvider(_ collectionView: UICollectionView, indexPath: IndexPath, data: Item) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.reuseId, for: indexPath) as! CellType
        cell.load(data, forIndexPath: indexPath)
        cell.delegate = cellDelegate

        imageFetcher?.getGIFFor(data as! GIF, priority: .veryHigh, index: indexPath.row, completionHandler: { [weak cell] (index, data) in
            guard index == indexPath.row else { return }
            DispatchQueue.main.async {
                (cell as? GiphyCell)?.updateGIF(data: data)
            }
        })
        
        return cell
    }

    private func makeDataSource() -> DataSource {
        guard let collectionView = collectionView else { fatalError() }
        return DataSource(collectionView: collectionView, cellProvider: cellProvider)
    }

    private func update(animateDiffrences: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animateDiffrences)
    }

    public func add(_ items: [Item]) {
        items.forEach {
            self.items.append($0)
        }

        update(animateDiffrences: true)
    }


    public func set(_ items: [Item]) {
        self.items = items
        update(animateDiffrences: true)
    }


    public func clearData() {
        self.items = []
        update(animateDiffrences: false)
    }

    public func remove(_ items: [Item]) {
        items.forEach { item in
            self.items.removeAll { $0 == item }
        }
        update(animateDiffrences: true)
    }

    public func reloadVisibleCells() {

        if let visibleIndexPaths = collectionView?.indexPathsForVisibleItems {
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems(visibleIndexPaths.compactMap(item))
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }


    public func reload(_ item: Item) {
        var updatedSnapshot = self.dataSource.snapshot()
        updatedSnapshot.reloadItems([item])
        self.dataSource.apply(updatedSnapshot, animatingDifferences: false)
    }


    public func item(at indexPath: IndexPath) -> Item? {
        if self.items.count > indexPath.row {
            return self.items[indexPath.row]
        }
        return nil
    }
}

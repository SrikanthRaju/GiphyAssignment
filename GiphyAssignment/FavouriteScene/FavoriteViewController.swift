//
//  FavoriteViewController.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation
import UIKit
import Combine

final class FavoriteViewController: UIViewController {

    private let viewModel: FavoriteViewModel
    private let imageFetcher: AsyncImageFetcher

    private lazy var segmentControl = UISegmentedControl(items: GIFViewStyle.allCases.map { $0.displayName })
    @Published private var layoutStyle = GIFViewStyle.grid

    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layoutStyle.layout)
    private lazy var collectViewHandler = GIFCollectionViewHandler<GiphyCell>(collectionView: collectionView,
                                                                              cellDelegate: self,
                                                                              imageFetcher: imageFetcher)

    private var disposables: Set<AnyCancellable> = []
    private var segmentControlLayoutConstraint: NSLayoutConstraint?

    init(viewModel: FavoriteViewModel, imageFetcher: AsyncImageFetcher) {
        self.viewModel = viewModel
        self.imageFetcher = imageFetcher
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()

        /// Will notify the change in UISegmentedControl value change
        /// Based on change even we will update the layout of UICollectionView
        $layoutStyle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in
                self?.collectionView.setCollectionViewLayout(style.layout, animated: true, completion: { _ in
                    self?.collectionView.collectionViewLayout.invalidateLayout()
                })
            }
            .store(in: &disposables)

        /// We are tracking the favorited items to update collectionview based on the item event type
        viewModel.favoritedGIFs.sink { [weak self] items in
            guard let self = self else { return }

            switch items {
            case .set(let items):
                /// Set new data and reload collection view
                self.collectViewHandler.set(items)

            case .added(let items):
                /// add new data and update collection view
                self.collectViewHandler.add(items)

            case .remove(let items):
                /// remove existing data and update collection view
                self.collectViewHandler.remove(items)
            }
        }
        .store(in: &disposables)


        // Requesting Viewmodel to load the data 
        viewModel.loadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.segmentControlLayoutConstraint?.constant = UIScreen.main.bounds.width * 0.95
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

}

// UI Creation
extension FavoriteViewController {

    private func createUI() {
        addCollectionView()
        setupCollectionViewConstraints()
        addSegmentControl()
    }

    private func addCollectionView() {
        collectionView.register(GiphyCell.self, forCellWithReuseIdentifier: GiphyCell.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }

    private func setupCollectionViewConstraints() {
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func addSegmentControl() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(didChangeLayoutMode(_:)), for: .valueChanged)
        navigationItem.titleView = segmentControl

        segmentControlLayoutConstraint = segmentControl.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.95)
        segmentControlLayoutConstraint?.isActive = true
    }

    @objc private func didChangeLayoutMode(_ sender: UISegmentedControl) {
        self.layoutStyle = sender.selectedSegmentIndex == 0 ? .grid : .list
    }
}


extension FavoriteViewController: GiphyCellDelegate {

    func didSelectFavourite(_ cell: GiphyCell, forIndexPath indexPath: IndexPath) {
        if let item = collectViewHandler.item(at: indexPath) {
            viewModel.updateGifFavouriteState(item)
        }
    }
}

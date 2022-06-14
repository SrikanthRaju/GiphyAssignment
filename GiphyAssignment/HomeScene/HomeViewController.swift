//
//  HomeViewController.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation
import UIKit
import Combine

class HomeViewController: UIViewController {


    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: GIFViewStyle.list.layout)

    private lazy var collectViewHandler = GIFCollectionViewHandler<GiphyCell>(collectionView: collectionView,
                                                                              cellDelegate: self,
                                                                              imageFetcher: imageFetcher)

    private let threshold = UIScreen.main.bounds.height/2 // threshold from bottom of tableView
    private var isLoadingMore = false // flag

    private let viewModel: HomeViewModel
    private let imageFetcher: AsyncImageFetcher

    private var disposables: Set<AnyCancellable> = []
    private var searchDisposables: Set<AnyCancellable> = []
    private var trendingDisposables: Set<AnyCancellable> = []

    init(viewModel: HomeViewModel, imageFetcher: AsyncImageFetcher) {
        self.viewModel = viewModel
        self.imageFetcher = imageFetcher
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()

        /// To update the list data when state switches between search and trending

        viewModel.$isSearchActive
            .sink(receiveValue: { [weak self] _isSearchActive in
                guard let self = self else {
                    self?.isLoadingMore = false
                    return
                }
                self.collectViewHandler.clearData()
                if !_isSearchActive {
                    self.searchDisposables.forEach({ $0.cancel() })
                    self.observeTrending()
                    self.collectViewHandler.add(self.viewModel.trendingManager.allGifs.compactMap{ GIF($0) })
                } else {
                    self.trendingDisposables.forEach({ $0.cancel() })
                    self.observeSearching()
                }
                self.isLoadingMore = false
            })
            .store(in: &disposables)

        /// To update the visible cell states if user has disliked the gif from diffrent scene
        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
            .map {$0.object}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] obj in
                guard let self = self else { return }
                self.collectViewHandler.reloadVisibleCells()
            }.store(in: &disposables)
    }

    func observeTrending() {
        viewModel.trendingManager.loadData
            .sink { [weak self] result in
                guard let self = self else {
                    self?.isLoadingMore = false
                    return
                }

                switch result {
                case .success(let result):
                    let gifmodels = result.1.compactMap{ GIF($0) }
                        DispatchQueue.main.async {
                            if result.0 == .reset {
                                self.collectViewHandler.set(gifmodels)
                            } else {
                                self.collectViewHandler.add(gifmodels)
                            }
                            self.isLoadingMore = false
                        }
                case .failure(_):
                    break

                }
            }
            .store(in: &trendingDisposables)
    }


    func observeSearching() {

        viewModel.searchManager.loadData
            .dropFirst()
            .sink { [weak self] result in
                guard let self = self else {
                    self?.isLoadingMore = false
                    return
                }
                switch result {
                case .success(let result):
                    let gifmodels = result.1.compactMap{ GIF($0) }
                        DispatchQueue.main.async {
                            if result.0 == .reset {
                                self.collectViewHandler.set(gifmodels)
                            } else {
                                self.collectViewHandler.add(gifmodels)
                            }

                            self.isLoadingMore = false
                        }
                case .failure(_):
                    break

                }
            }
            .store(in: &searchDisposables)
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}

// UI Creation
extension HomeViewController {

    func createUI() {
        addSearchController()
        addCollectionView()
        setupCollectionViewConstraints()
    }

    func addSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for GIF's"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func addCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(GiphyCell.self, forCellWithReuseIdentifier: String(describing: GiphyCell.self))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView)
    }

    func setupCollectionViewConstraints() {
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? GiphyCell else { return }
        cell.startAnimatingGIF()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? GiphyCell else { return }
        cell.stopAnimatingGIF()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;


        if !isLoadingMore && (maximumOffset - contentOffset <= threshold) {
            // Get more data - API call\]
            self.isLoadingMore = true
            viewModel.loadMoreGifs()
        }
    }

}

extension HomeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {
            if let item = collectViewHandler.item(at: indexPath) {
                self.imageFetcher.getGIFFor(item,
                                            priority: .veryLow,
                                            index: indexPath.row,
                                            completionHandler: nil)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {
            if let item = collectViewHandler.item(at: indexPath) {
                self.imageFetcher.cancelImageLoadingFor(model: item)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Filter data
        viewModel.searchString = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension HomeViewController: UISearchControllerDelegate {

    func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.isSearchActive = true
        imageFetcher.cancelAllImageLoading()
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.isSearchActive = false
        imageFetcher.cancelAllImageLoading()
    }
}


extension HomeViewController: GiphyCellDelegate {
    func didSelectFavourite(_ cell: GiphyCell, withModel model: GIF?) {
        if let item = model {
            viewModel.updateGifFavouriteState(item)
        }
    }
}

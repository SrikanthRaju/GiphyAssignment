//
//  HomeViewModel.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation
import UIKit
import Combine

class HomeViewModel {

    let trendingManager: GiphyManager
    let searchManager: GiphyManager

    private let gifUseCase: GiphyUseCase
    private let favouriteUseCase: FavouriteUseCase
    private var disposables: Set<AnyCancellable> = []

    @Published var searchString: String?
    @Published var isSearchActive: Bool = false

    init(gifUseCase: GiphyUseCase, favouriteUseCase: FavouriteUseCase) {
        self.gifUseCase = gifUseCase
        self.favouriteUseCase = favouriteUseCase
        self.trendingManager = GiphyManager(type: .trending, useCaseProvider: gifUseCase)
        self.searchManager = GiphyManager(type: .search(nil), useCaseProvider: self.gifUseCase)
        loadData()
    }

    func getGiphyManager() -> GiphyManager? {
        return isSearchActive ? searchManager : trendingManager
    }

    func loadData() {


        $searchString
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.global(qos: .background))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.searchManager.updateSearch(text: searchText?.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            .store(in: &disposables)
    }

    func updateGifFavouriteState(_ item: GIF) {
        if favouriteUseCase.isFavourite(item.id) {
            favouriteUseCase.removeFromFavourite(item.id)
        } else {
            favouriteUseCase.addToFavourite(item)
        }
    }

    func loadMoreGifs() {
        getGiphyManager()?.loadMoreGifs()
    }
}

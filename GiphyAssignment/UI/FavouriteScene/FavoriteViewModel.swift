//
//  FavoriteViewModel.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation
import CoreData
import Combine

final class FavoriteViewModel {

    enum FavoriteItem {
        case set([GIF])
        case added([GIF])
        case remove([GIF])
    }

    private let favouriteUseCase: FavouriteUseCase
    private var disposables: Set<AnyCancellable> = []

    var favoritedGIFs = CurrentValueSubject<FavoriteItem, Never>(FavoriteItem.set([]))

    init(favouriteUseCase: FavouriteUseCase) {
        self.favouriteUseCase = favouriteUseCase
    }

    func loadData() {
        let fetchRequest = FavouriteEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        do {
            let result = try favouriteUseCase.viewContext.fetch(fetchRequest)
            let items = result.compactMap { $0.asGIF() }
            self.favoritedGIFs.send(.set(items))
        } catch {
            print("fetching Error: ", error.localizedDescription)
        }

        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
            .sink { [weak self] notification in
                guard let self = self else { return }
                self.addNewGifAsfavorite(notification)
                self.removeGifAsfavorite(notification)
            }.store(in: &disposables)
    }

    private func addNewGifAsfavorite(_ notification: Notification) {
        let insertedObjectsSet = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
        let updatedObjectsSet = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()

        var newGifs = insertedObjectsSet.compactMap { ($0 as? FavouriteEntity)?.asGIF() }
        if !updatedObjectsSet.isEmpty {
            let updateGifs = updatedObjectsSet.compactMap { ($0 as? FavouriteEntity)?.asGIF() }
            newGifs.append(contentsOf: updateGifs)
        }

        self.favoritedGIFs.send(.added(newGifs))
    }

    private func removeGifAsfavorite(_ notification: Notification) {
        let deletedObjectsSet = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()

        let deleteGifs = deletedObjectsSet.compactMap { ($0 as? FavouriteEntity)?.asGIF() }
        self.favoritedGIFs.send(.remove(deleteGifs))
    }

    func updateGifFavouriteState(_ item: GIF) {
        if favouriteUseCase.isFavourite(item.id) {
            favouriteUseCase.removeFromFavourite(item.id)
        } else {
            favouriteUseCase.addToFavourite(item)
        }
    }
}

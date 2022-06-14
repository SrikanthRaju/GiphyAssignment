//
//  FavouriteRepository.swift
//  GiphyAssignment
//
//  Created by Sri on 13/06/22.
//

import Foundation
import CoreData.NSManagedObjectContext

struct FavouriteRepository {

    let dataStore: StoreData

    init(dataStore: StoreData) {
        self.dataStore = dataStore
    }

}

extension FavouriteRepository: FavouriteUseCase {

    var viewContext: NSManagedObjectContext {
        return dataStore.viewContext()
    }

    func addToFavourite(_ item: GIF) {
        let favourite = FavouriteEntity(context: viewContext)
        favourite.id = item.id
        favourite.remoteUrl = item.urlString
        favourite.addedAt = Date()

        do {
            try viewContext.save()
        }
        catch {
            print("adding to favourite failed. Reason: ", error.localizedDescription)
        }

    }

    /// Remove an Item from the favourite store
    /// - Parameters:
    ///   - id: item to be removed

    func removeFromFavourite(_ id: String) {

        let fetchRequest = FavouriteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.fetchLimit = 1

        do {
            let result = try viewContext.fetch(fetchRequest)
            result.forEach(viewContext.delete)
            try viewContext.save()

        } catch {
            print(error)
        }

    }

    /// Check whether an url exists in favourites store
    /// - Parameters:
    ///  - id: item to be verified
    /// - Returns:
    ///  - True:  Item is Favourite
    ///  - False: Item is not Favourite

    func isFavourite(_ id: String) -> Bool {
        return isFavouriteGIF(id)
    }


}


func isFavouriteGIF(_ id: String) -> Bool {
    let fetchRequest = FavouriteEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id = %@", id)
    fetchRequest.fetchLimit = 1

    do {
        let result = try StoreData.inDatabase.viewContext().fetch(fetchRequest)
        return !result.isEmpty

    } catch {
        print(error.localizedDescription)
    }
    return false
}

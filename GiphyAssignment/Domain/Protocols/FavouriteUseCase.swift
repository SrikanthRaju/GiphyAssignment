//
//  FavouriteUseCase.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation
import CoreData

// TODO: Rename as Favourites Repository

protocol FavouriteUseCase {


    /// This should be used for read-only data for best performance
    
    var viewContext: NSManagedObjectContext { get }

    /// Add an Item to favourite store
    /// - Parameters:
    ///   - item: Item to be stored

    func addToFavourite(_ item: GIF)

    /// Remove an Item from the favourite store
    /// - Parameters:
    ///   - item: item to be removed

    func removeFromFavourite(_ id: String)

    /// Check whether an url exists in favourites store
    /// - Parameters:
    ///  - item: item to be verified
    /// - Returns:
    ///  - True:  Item is Favourite
    ///  - False: Item is not Favourite

    func isFavourite(_ id: String) -> Bool

}

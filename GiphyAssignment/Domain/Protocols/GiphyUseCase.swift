//
//  GiphyUseCase.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

// TODO: Rename as Giphy Repository

protocol GiphyUseCase {

    /// Gets the Trending GIF's
    ///
    /// - Parameter offset: for  pagination result data offset
    /// - Parameter limit: for limiting the result data
    /// - Returns: Result of the response
    ///

    func getTrendingGifs(offset: Int, limit: Int) async -> Result<GIFResModel, ApiError>


    /// Get GIFs that match the search query
    /// - Parameter query: query for searching gif
    /// - Parameter offset: for  pagination result data offset
    /// - Parameter limit: for limiting the result data
    /// - Returns: Result of the response
    ///

    func searchGifs(query: String, offset: Int, limit: Int) async -> Result<GIFResModel, ApiError>
}








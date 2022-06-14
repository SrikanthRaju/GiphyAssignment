//
//  GIFRepository.swift
//  GiphyAssignment
//
//  Created by Sri on 13/06/22.
//

import Foundation

struct GIFRepository {

    let networkService: ApiServiceProtocol

    init(service: ApiServiceProtocol) {
        self.networkService = service
    }
}

extension GIFRepository: GiphyUseCase {

    func getTrendingGifs(offset: Int, limit: Int) async -> Result<GIFResModel, ApiError> {

        let endPoint = GIFEndpoint.trendingGifs(offset: offset, limit: limit)
        let response: Result<GIFResModel, ApiError> = await networkService.request(endpoint: endPoint, parser: GIFDataParser())
        return response
    }

    func searchGifs(query: String, offset: Int, limit: Int) async -> Result<GIFResModel, ApiError> {

        networkService.cancelAllTasks()
        let endPoint = GIFEndpoint.searchGifs(searchQuery: query, offset: offset, limit: limit)
        let response: Result<GIFResModel, ApiError> = await networkService.request(endpoint: endPoint, parser: GIFDataParser())
        return response
    }

}

///
//  GiphyManager.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation
import Combine

final class GiphyManager {

    enum GiphyType {
        case trending
        case search(String?)
    }

    enum ResultStatus {
        case reset
        case append
    }

    var loadData = PassthroughSubject<Result<(GiphyManager.ResultStatus, [GIFDataModel]), Error>, Never>()

    private let limit: Int
    private(set) var isLoading = false

    private var totalItems: Int = 0
    private var noMoreItems = false
    private var currentOffset: Int = 0
    private(set) var type: GiphyType
    private let useCaseProvider: GiphyUseCase
    private(set) var allGifs: Set<GIFDataModel> = Set<GIFDataModel>()
    private var resultStatus = ResultStatus.append


    init(type: GiphyType, useCaseProvider: GiphyUseCase, limit: Int = 10) {
        self.type = type
        self.useCaseProvider = useCaseProvider
        self.limit = limit
        loadUseCaseData()
    }

    func updateSearch(text: String?) {
        type = .search(text)
        resetData()
        loadUseCaseData()
    }

    private func loadUseCaseData() {
        switch type {
        case .trending:
            Task(priority: .userInitiated) { [weak self] in
                await self?.loadTrendingGifs(offset: currentOffset)
            }

        case .search(let query):
            Task(priority: .userInitiated) { [weak self] in
                await self?.loadSearchingGifs(query: query, offset: currentOffset)
            }
        }
    }

    func loadMoreGifs() {
        guard !isLoading && !noMoreItems else {
            return
        }
        isLoading = true
        resultStatus = .append
        loadUseCaseData()
    }

    func resetData() {
        totalItems = 0
        currentOffset = 0
        noMoreItems = false
        allGifs = []
        resultStatus = .reset
    }

    private func parseResponse(_ result: Result<GIFResModel, ApiError>) {
        switch result {
        case .success(let respModel):
            totalItems = respModel.pagination.totalCount
            currentOffset = respModel.pagination.offset + limit
            noMoreItems = respModel.pagination.count < limit
            loadData.send(.success((resultStatus, dataOperation(respModel.data))))

        case .failure(let apiError):
            loadData.send(.failure(apiError))

        }

        isLoading = false
    }


    private func dataOperation(_ data: [GIFDataModel]) -> [GIFDataModel] {
        let newGifsSet = Set<GIFDataModel>(data)
        let nonDuplicatedGifs = newGifsSet.subtracting(allGifs)
        allGifs = allGifs.union(data)
        return nonDuplicatedGifs.map { $0 }
    }

}

extension GiphyManager {

    private func loadTrendingGifs(offset: Int) async {
        isLoading = true
        let result = await useCaseProvider.getTrendingGifs(offset: offset, limit: self.limit)
        parseResponse(result)
    }

}


extension GiphyManager {

    private func loadSearchingGifs(query: String?, offset: Int) async {
        guard let query = query, !query.isEmpty else {
            loadData.send(.success((resultStatus, [])))
            return
        }
        isLoading = true
        let result = await useCaseProvider.searchGifs(query: query, offset: offset, limit: self.limit)
        parseResponse(result)
    }
}

extension GiphyManager.GiphyType: Equatable {

    static func == (lhs: GiphyManager.GiphyType, rhs: GiphyManager.GiphyType) -> Bool {
        switch (lhs, rhs) {

        case (.trending, .trending): return true
        case (.search, .search): return true
        default: return false
        }
    }
}

extension GiphyManager.ResultStatus: Equatable {

    static func == (lhs: GiphyManager.ResultStatus, rhs: GiphyManager.ResultStatus) -> Bool {
        switch (lhs, rhs) {

        case (.reset, .reset), (.append, .append) : return true
        default: return false
        }
    }
}

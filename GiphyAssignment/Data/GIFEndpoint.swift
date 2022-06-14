//
//  GIFEndpoint.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

enum GIFEndpoint {
    case trendingGifs(offset: Int, limit: Int)
    case searchGifs(searchQuery: String, offset: Int, limit: Int)
}

extension GIFEndpoint: APIEndpoint {

    struct KeyName {
        static let accessToken = "api_key"
        static let query = "q"
        static let limit = "limit"
        static let offset = "offset"
    }

    struct KeyValue {
        static let token = Config.current.giphyAPIKey.base64Decoded()
        static let linit = "25"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: [String : AnyHashable]? {
        switch self {
        case .trendingGifs(let offset, let limit):
            return [
                KeyName.accessToken: KeyValue.token,
                KeyName.offset: offset,
                KeyName.limit: limit
            ]
        case .searchGifs(let query, let offset, let limit):
            return [
                KeyName.accessToken: KeyValue.token,
                KeyName.offset: offset,
                KeyName.limit: limit,
                KeyName.query: query
            ]
        }
    }

    var urlString: String {
        let baseUrl = Config.current.baseUrl
        switch self {
        case .trendingGifs:
          return "\(baseUrl)/v1/gifs/trending"
        case .searchGifs:
          return "\(baseUrl)/v1/gifs/search"
        }
    }
}


fileprivate extension String {

  func base64Encoded() -> String {
    guard let result = data(using: .utf8)?.base64EncodedString()  else {
      fatalError("Unable to encode to base 64!")
    }
    return result
  }

  func base64Decoded() -> String {
    guard let data = Data(base64Encoded: self), let result = String(data: data, encoding: .utf8) else {
      fatalError("Unable to decode to base 64!")
    }
    return result
  }

}


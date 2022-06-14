//
//  ApiError.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

public enum ApiError : Error {

    case noInternet
    case invalidUrl
    case invalidResponse(String?)
    case emptyResponseData
    case unDecodableResponse(ParseError)
}

extension ApiError: LocalizedError {

    public var errorDescription: String? {
            switch self {
            case .noInternet:
                return "Intenet connection not available"
            case .invalidUrl:
                return "Url not found"
            case .invalidResponse(let message):
                return message
            case .emptyResponseData:
                return "No response data found"
            case .unDecodableResponse( _):
                return "Error: Data decoding failed"
            }
        }
}

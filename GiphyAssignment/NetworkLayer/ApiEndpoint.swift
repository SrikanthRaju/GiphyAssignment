//
//  APIEndpoint.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// `APIEndpoint` protocol represents a request for remote/web API.
/// Following 4 items must be implemented.
/// - `var parameters: [String: AnyHashable]?`
/// - `var urlString: String`
/// - `var method: HTTPMethod`
/// - `var headerFields: [String: String]?`
///
public protocol APIEndpoint {
    /// The HTTP request method.
    var method: HTTPMethod { get }

    /// The values of this property will be computed  depending on `method`.
    var parameters: [String: AnyHashable]? { get }

    /// The HTTP header fields.
    var headerFields: [String: String] { get }

    /// The  URLString .
    var urlString: String { get }
}

extension APIEndpoint {

    var parameters: [String: AnyHashable]? {
        return nil
    }

    var headerFields: [String: String] {
        return [:]
    }

    /// Builds `URLRequest` from properties of `self`.
    /// - Throws: `RequestError`, `Error`
    func buildURLRequest() throws -> URLRequest {

        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl
        }

        guard var components = URLComponents(string: urlString) else {
            throw ApiError.invalidUrl
        }

        if let queryParameters = parameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { (key, value) -> URLQueryItem in
                return URLQueryItem(name: key, value: "\(value)")
            }
        }

        var urlRequest = URLRequest(url: url)
        if let newURL = components.url {
            urlRequest.url = newURL
        }
        urlRequest.httpMethod = method.rawValue

        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }
}

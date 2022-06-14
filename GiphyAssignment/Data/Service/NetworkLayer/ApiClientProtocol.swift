//
//  ApiServiceProtocol.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

protocol ApiServiceProtocol: AnyObject {

    var urlSession: URLSession { get }

    // To log network request
    var apiLogger: ApiLogger? { get }

    /// Generic based request function for Rest API calls
    /// - Parameter endpoint: Protocol based self-contained request with parameters as HTTP method, url, body-parameters etc.
    /// - Parameter parser: Protocol based generic parser with parameters as Data.
    /// - Returns: Result<T, ApiError> -  returns Decodable. modal type if success, ApiError otherwise

    func request<T: Decodable>(endpoint: APIEndpoint, parser: DataParser) async -> Result<T, ApiError>

    /// Cancel all tasks in urlSession
    func cancelAllTasks()
}


extension ApiServiceProtocol {

    // MARK: Default implementation for request

    func cancelAllTasks() {
        urlSession.getAllTasks { $0.forEach { $0.cancel() } }
    }

    func request<T: Decodable>(endpoint: APIEndpoint, parser: DataParser) async -> Result<T, ApiError> {

        do {
            let parsedObject: T = try await withCheckedThrowingContinuation({ [weak self] continuation in

                do {

                    guard Reachability.shared.isReachable else {
                        return continuation.resume(throwing: ApiError.noInternet)
                    }

                    let urlRequest = try endpoint.buildURLRequest()
                    self?.apiLogger?.log(request: urlRequest)
                    let task = urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
                        guard error == nil else {
                            self?.apiLogger?.log(error: error!)
                            return continuation.resume(throwing: ApiError.invalidResponse(error?.localizedDescription))
                        }

                        guard let rawData = data, !rawData.isEmpty else {
                            return continuation.resume(throwing: ApiError.emptyResponseData)
                        }

                        do {
                            let response: T = try parser.parse(data: rawData)
                            continuation.resume(returning: response)
                        } catch {
                            self?.apiLogger?.log(error: error)
                            continuation.resume(throwing: ApiError.unDecodableResponse(error as! ParseError))
                        }

                    }
                    task.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            })

            return .success(parsedObject)

        } catch {
            return .failure(error as! ApiError)
        }
    }
}




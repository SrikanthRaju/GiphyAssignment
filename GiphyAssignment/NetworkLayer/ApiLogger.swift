//
//  ApiLogger.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation

public protocol ApiLogger {
    func log(request: URLRequest)
    func log(error: Error)
}

public final class DefaultApiLogger: ApiLogger {
    public init() { }

    public func log(request: URLRequest) {
        print("-------------")
        let urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        print("[\(request.httpMethod!)]: \(request.url!)")
        print("params: \(urlComponents!.queryItems!)")
        print("-------------")
    }

    public func log(error: Error) {
        printIfDebug("\(error)")
    }
}

fileprivate func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}

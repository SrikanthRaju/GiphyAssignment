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

        let taskState = (error as NSError).userInfo[NSLocalizedDescriptionKey] as! String
        let urlString = (error as NSError).userInfo[NSURLErrorFailingURLStringErrorKey] as! String
        let urlComponents = URLComponents(string: urlString)
        print("-------------")
        print("[\(taskState)]: \(urlString)")
        print("params: \(urlComponents!.queryItems!)")
        print("-------------")
    }
}

fileprivate func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}

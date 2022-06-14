///
//  GIFService.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation


class GIFService: ApiServiceProtocol {

    let urlSession: URLSession
    var apiLogger: ApiLogger? = DefaultApiLogger()

    init(sessionConfiguration: URLSessionConfiguration = .ephemeral) {
        self.urlSession = URLSession(configuration: sessionConfiguration)
    }
}

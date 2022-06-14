//
//  Config.swift
//  GiphyAssignment
//
//  Created by Sri on 11/06/22.
//

import Foundation

protocol EnvConfiguration {
    var baseUrl: String { get }
    var giphyAPIKey: String { get }
}

struct Config {
    // TODO: automatically environment switch by Bundle Id
    static let current = Dev()

    struct Dev: EnvConfiguration {
        let baseUrl = "https://api.giphy.com"
        let giphyAPIKey = "d0FQWDcxb1JkYUpIcno4OVVZdklNV1NZcDk5ZEpvTFk="
    }

    struct Prod: EnvConfiguration {
        let baseUrl = ""
        let giphyAPIKey = ""
    }
}

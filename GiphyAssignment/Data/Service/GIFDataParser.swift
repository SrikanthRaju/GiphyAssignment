//
//  GIFDataParser.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

struct GIFDataParser: DataParser {

    func parse<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ParseError.decodingError
        }
    }
}

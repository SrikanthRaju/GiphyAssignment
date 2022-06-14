//
//  DataParser.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

// MARK: - Data Parser Error Types
public enum ParseError: Error {
    case decodingError
}


// MARK: - Data Parser protocol
public protocol DataParser {

    func parse<T: Decodable>(data: Data) throws -> T
}


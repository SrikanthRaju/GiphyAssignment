//
//  ApiServiceProtocol.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

public struct GIFResModel: Decodable {
    public let pagination: GIFPaginationModel
    public let data: [GIFDataModel]
}

public struct GIFPaginationModel: Decodable {
    public let offset: Int
    public let count: Int
    public let totalCount: Int
}


public struct GIFDataModel: Codable, Hashable {

    public let id: String
    public let title: String
    public let images: GIFImagesModel

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: GIFDataModel, rhs: GIFDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct GIFImagesModel: Codable {
  public let original: FixedHeight
  public let fixedHeightDownsampled: FixedHeight?
}

public struct FixedHeight: Codable {
    let height, width, size: String
    let url: String
}

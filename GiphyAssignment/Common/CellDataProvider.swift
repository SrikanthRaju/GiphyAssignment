//
//  CellDataProvider.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation


protocol ReuseID {
    static var reuseId: String { get }
}

extension ReuseID {
    static var reuseId: String {
        String(describing: Self.self)
    }
}

protocol CellDataProvider: AnyObject, ReuseID {
    associatedtype DataItem: Hashable
    var delegate: GiphyCellDelegate? { get set }

    func load(_ model: DataItem, forIndexPath indexPath: IndexPath)
}

enum Section: Hashable {
    case main
}

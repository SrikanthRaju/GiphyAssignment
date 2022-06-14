//
//  ImageAsserts.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation
import UIKit

// Protocol defines the definition of a ImageAssert

protocol ImageAssert {

    // Name of the image
    var imageName: String { get }

    /// Image with rendering mode `Template`.
    /// Used to apply tint color
    var templateImage: UIImage? { get }

    /// Image with rendering mode `Original`.
    var originalImage: UIImage? { get }

}


extension ImageAssert {

    var templateImage: UIImage? {
        return UIImage(named: self.imageName)?.withRenderingMode(.alwaysTemplate)
    }

    var originalImage: UIImage? {
        return UIImage(named: self.imageName)?.withRenderingMode(.alwaysOriginal)
    }

    func colored(by tintColor: UIColor) -> UIImage? {
        return templateImage?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
    }
}


struct ImageAsserts {

    private init() {}

    enum Icon: String, ImageAssert {
        case gifUnselected = "play.rectangle.on.rectangle"
        case gifSelected = "play.rectangle.on.rectangle.fill"

        case favUnselected = "heart"
        case favSelected = "heart.fill"

        var imageName: String {
            return rawValue
        }
    }
}

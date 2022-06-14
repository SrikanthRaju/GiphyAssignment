//
//  GIF.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation

struct GIF {
    let id: String
    let url: URL

    var urlString: String {
        return url.absoluteString
    }

    init?(_ dataModel: GIFDataModel) {
        guard let downsized = dataModel.images.fixedHeightDownsampled, let downSizedUrl = URL(string: downsized.url) else {
            guard let originalUrl = URL(string: dataModel.images.original.url) else {
                return nil
            }
            self.url = originalUrl
            self.id = dataModel.id

            return
        }
        self.url = downSizedUrl
        self.id = dataModel.id
    }

    init?(withID id: String, urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
        self.id = id
    }

    /// Unique file name

    var fileName: String {
      return "local_\(id).gif"
    }


    /// Gets the path for image file
    ///
    /// - Returns: path for image file
    func getDiskPath() -> String {
      let tempDir = NSTemporaryDirectory()
      let flickrDir = "GiphyData"
      let fullDirPath = "\(tempDir)\(flickrDir)"
      try? FileManager.default.createDirectory(atPath: fullDirPath, withIntermediateDirectories: true, attributes: nil)
      return "\(fullDirPath)/\(fileName)"
    }



    func getGifPathUrl(notify: @escaping (URL?)->Void)  {
        DispatchQueue.global().async {
            let path = getDiskPath()
            if FileManager.default.fileExists(atPath: path) {
                let url = URL(fileURLWithPath: path)
                DispatchQueue.main.async {
                    notify(url)
                }
            }
            DispatchQueue.main.async {
                notify(nil)
            }
        }

    }

    
}

extension GIF: Hashable, Equatable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GIF, rhs: GIF) -> Bool {
        return lhs.id == rhs.id
    }
}


extension FavouriteEntity {

    func asGIF() -> GIF? {
        return GIF(withID: self.id ?? "", urlString: self.remoteUrl ?? "")
    }
    
}

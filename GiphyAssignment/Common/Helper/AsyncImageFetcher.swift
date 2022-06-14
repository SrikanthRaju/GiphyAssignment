//
//  AsyncImageFetcher.swift
//  GiphyAssignment
//
//  Created by Sri on 14/06/22.
//

import Foundation
import UIKit

/// Gets the image for the url.
/// First it looks into the NSCache, then on disk and at last it fetches the data
/// from the server
class AsyncImageFetcher {

    /// Operation queue for downloading the Images from the server
    let operationQueue = OperationQueue()

    /// Keeps the images in memory for cache
    let imageCache = NSCache<NSString, NSData>()

    /// Default session for all image loading from the serverb
    let session = URLSession(configuration: .default)

    /// Keeps the operation that are in progress, we can also get the operation from the
    /// operation queue but that's CPU intensive especially when we need to canecel array of
    /// operations. Then complexity becomes O(n^2) and using dict it's O(n)
    var operationsInProgress = [String : ImageDownloader]()

    /// Holds the completion handler
    /// We've having one competion handler for on key, we can also make it array so that
    /// multiple completion handlers can be invoked but this is not need now, so having
    /// one to one maping
    var completionHandlers = [String : ((Int, Data) -> Void)]()

    /// Serial queue to syncronise the access of `operationsInProgress`,`imageCache`, `completionHandler` and `operationQueue`
    let serialDispatchQueue = DispatchQueue(label: "ImageFetcher", qos: .userInitiated)


    /// Initilizer
    ///
    /// - Parameters:
    ///   - concurrentOperations: number of concurrent operations for image downloading
    ///   - cacheImageCount: max number of images to be cached
    init(concurrentOperations: Int, cacheImageCount: Int) {
        self.operationQueue.maxConcurrentOperationCount = concurrentOperations
        self.imageCache.countLimit = cacheImageCount
    }

    /// Gets the image a flickr model form cache/disk/network
    ///
    /// - Parameters:
    ///   - flickrModel: flickr model
    ///   - width: thumbnail width, if nil the returns the full image
    ///   - priority: operation priority
    ///   - index: // TODO: for debugging purpose, just kept for you to see how it's downloading
    ///   - completionHandler: competion handler
    func getGIFFor(_ model: GIF, priority: Operation.QueuePriority , index: Int, completionHandler: ((Int, Data) -> Void)?) {
        serialDispatchQueue.async { [weak self] in
            if let weakSelf = self {
                // Get the file name
                let fileName = model.fileName

                // So first we'll check the image cache
                if let data = weakSelf.imageCache.object(forKey: fileName as NSString) {
                    // Wooooo! we found the image in the cache, return this image
                    print("Image found in cache:\(fileName)")
                    // Remove completion handler if any
                    completionHandler?(index, data as Data)
                }
                else if weakSelf.operationsInProgress[fileName] == nil {
                    // Operation is not in progress then either file exists at path or don't
                    if FileManager.default.fileExists(atPath: model.getDiskPath()),
                       let data = NSData(contentsOfFile: model.getDiskPath()) {
                        // Set the image in image cache
                        self?.imageCache.setObject(data, forKey: fileName as NSString)
                        // Call the completion handler
                        completionHandler?(index, data as Data)
                    }
                    else {
                        // File don't exits and operation is not in progresss. Add operation ASAP!
                        print("Getting image from network:\(fileName)")
                        // Create the completion handler
                        let imageOperationHandler = weakSelf.getCompletionHandler(index: index, fileName: fileName)
                        // Create the operation
                        let operation = ImageDownloader(model: model, session: weakSelf.session, completionHandler: imageOperationHandler)
                        // Set the priority
                        operation.queuePriority = priority
                        // Syncronize the `operationsInProgress`
                        weakSelf.serialDispatchQueue.async { [weak self] in
                            operation.index = index
                            // Add the completion handler
                            // Save the completion handler
                            if let handler = completionHandler {
                                weakSelf.completionHandlers[fileName] = handler
                            }
                            // Add operation to dictionay and queue
                            self?.operationsInProgress[fileName] = operation
                            self?.operationQueue.addOperation(operation)
                        }
                    }
                }
                else {
                    // Operation is already in progress now if we've a completion handler
                    // then add it to dict
                    print("Operation already in progress: \(index) | CH:\(completionHandler == nil ? "nil"  : "non-nil")")
                    if let handler = completionHandler {
                        self?.completionHandlers[fileName] = handler
                    }
                }
            }
        }
    }


    /// Completion handler for the ImageDownloadOperation, this code was repetative
    /// thus added a method for it
    ///
    /// - Parameters:
    ///   - width: width for the image to down sample
    ///   - fileName: fileName
    ///   - completionHandler: completion handler
    /// - Returns: completion handler
    private func getCompletionHandler(index: Int, fileName: String) -> ImageDownloader.CompletionHandlerClosure {
        return { [weak self] (success, model) in
            if success {
                // File have been saved to disk, now we've to get it and
                // give the image data back
                // Down sample the image based on the width
                print("Operation Completed, operations:\(String(describing: self?.operationQueue.operations.count)) | for :\(index)")
                let data = NSData(contentsOfFile: model.getDiskPath())

                self?.serialDispatchQueue.async { [weak self] in
                    // Remove the operation from the progress oepration
                    self?.operationsInProgress.removeValue(forKey: fileName)
                    // Add this file to cache
                    if let data = data {
                        // Set the image in image cache
                        self?.imageCache.setObject(data, forKey: fileName as NSString)
                        // Call the completion handler
                        if let handler = self?.completionHandlers.removeValue(forKey: fileName) {
                            handler(index, data as Data)
                        }
                    }
                }
            }
        }
    }


    /// Clears the image cache, useful in cases when you receive memory warnings
    func clearCache() {
        self.serialDispatchQueue.async { [weak self] in
            self?.imageCache.removeAllObjects()
        }
    }

    /// Cancels the opertaion that is downloading the image for `flickrModel`
    ///
    /// - Parameter flickrModel: model for which operation needs to be cancelled
    func cancelImageLoadingFor(model: GIF) {
        self.serialDispatchQueue.async { [weak self] in
            let key = model.fileName
            if let operation = self?.operationsInProgress[key] {
                operation.cancel()
                self?.operationsInProgress.removeValue(forKey: key)
            }
        }
    }

    func cancelAllImageLoading() {
        self.serialDispatchQueue.async { [weak self] in

            if let operationsInProgressKeys = self?.operationsInProgress.keys {
                operationsInProgressKeys.forEach { [weak self] key in
                    if let operation = self?.operationsInProgress[key] {
                        operation.cancel()
                        self?.operationsInProgress.removeValue(forKey: key)
                    }
                }
            }
        }
    }

}

//
//  ImagePersistence.swift
//  ImagePersistence
//
//  Created by Martin Rehder on 14.03.2017.
/*
 * Copyright 2017-present Martin Jacob Rehder.
 * http://www.rehsco.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

open class ImagePersistence: ImagePersistenceInterface {
    private let fileManager = FileManager.default
    private let directoryURL: URL
    public static var storageID = "ipimages"

    open var imageCache = ImageCache()
    
    public init?() {
        let possibleDirectories = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        if possibleDirectories.count > 0 {
            let documentDirectory = possibleDirectories[0]
            let directoryURL = documentDirectory.appendingPathComponent(ImagePersistence.storageID)
            self.directoryURL = directoryURL
            let path = self.directoryURL.path
            if !fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    NSLog("Cannot create image directory at path \(path). Description: \(error.description)")
                    return nil
                }
            }
        } else {
            NSLog("Cannot create image directory")
            return nil
        }
    }
    
    open func filenameFromImageID(_ imageID: String, suffix: String = "png") -> String {
        return "com.rehsco.imagepersistence.\(imageID).\(suffix)"
    }

    open func imageAsJPEG(_ image: UIImage, quality: CGFloat) -> Data {
        return image.jpegData(compressionQuality: quality)!
    }
    
    open func imageAsPNG(_ image: UIImage) -> Data {
        return image.pngData()!
    }
    
    open func imageFromData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    open func saveImage(_ image: UIImage, imageID: String) {
        let imageData = self.imageAsPNG(image)
        self.saveImageData(imageData, imageID: imageID)
        self.imageCache.addImage(id: imageID, image: image)
    }

    open func saveImageData(_ imageData: Data, imageID: String) {
        let filename = self.filenameFromImageID(imageID)
        encryptAndStoreImage(imageData, filename: filename)
    }
    
    private func encryptAndStoreImage(_ imageData: Data, filename: String) {
        if let data = self.encryptImage(imageData) {
            let path = self.directoryURL.appendingPathComponent(filename).path
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
        }
        else {
            NSLog("Cannot save image with filename \(filename)")
        }
    }
    
    open func deleteImage(_ imageID: String) {
        let filename = self.filenameFromImageID(imageID)
        deleteImageWithFilename(filename, withFileExistsCheck: false)
        self.imageCache.removeImage(id: imageID)
    }
    
    private func deleteImageWithFilename(_ filename: String, withFileExistsCheck: Bool) {
        let path = self.directoryURL.appendingPathComponent(filename).path
        if !withFileExistsCheck || fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                if withFileExistsCheck {
                    NSLog("Cannot remove image at path \(path)")
                }
            }
        } else {
            NSLog("Cannot remove image. Cannot get path for filename \(filename)")
        }
    }
    
    open func deleteAllImages() {
        let path = self.directoryURL.path
        self.imageCache.removeAll()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: path)
            for file in directoryContents {
                let fullPath = self.directoryURL.appendingPathComponent(file).path
                do {
                    try fileManager.removeItem(atPath: fullPath)
                } catch {
                    NSLog("Could not delete file: \(file)")
                }
            }
        }
        catch {
            NSLog("Could not access \(path)")
        }
    }
    
    open func hasImageCached(_ imageID: String) -> Bool {
        return self.imageCache.getImage(id: imageID) != nil
    }
    
    open func getImage(_ imageID: String) -> UIImage? {
        if let image = self.imageCache.getImage(id: imageID) {
            return image
        }
        let filename = self.filenameFromImageID(imageID)
        let filePath = directoryURL.appendingPathComponent(filename).path
        if let data = fileManager.contents(atPath: filePath), let imageData = self.decryptImage(data) {
            if let image = self.imageFromData(imageData) {
                self.imageCache.addImage(id: imageID, image: image)
                return image
            }
        }
        return nil
    }

    open func getImageData(_ imageID: String) -> Data? {
        let filename = self.filenameFromImageID(imageID)
        let filePath = directoryURL.appendingPathComponent(filename).path
        if let data = fileManager.contents(atPath: filePath), let imageData = self.decryptImage(data) {
            return imageData
        }
        return nil
    }
    
    // MARK: - Encryption (Optional)
    
    // Override in subclass
    open func encryptImage(_ data: Data) -> Data? {
        return data
    }
    
    // Override in subclass
    open func decryptImage(_ data: Data) -> Data? {
        return data
    }
}

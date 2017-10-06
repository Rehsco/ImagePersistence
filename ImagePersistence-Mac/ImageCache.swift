//
//  ImageCache.swift
//  ImagePersistence
//
//  Created by Martin Rehder on 23.03.2017.
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

import Cocoa

open class ImageCache {
    open var maxNumImages = 100
    // This is a approximated value in MB. This is not an accurate threshold
    open var maxImageMemoryThreshold:Double = 128

    private var imageCache: [String: NSImage] = [:]
    private var imageIDList: [String] = []
    
    public init(maxNumImages: Int = 100, maxImageMemoryThreshold: Double = 128) {
        self.maxNumImages = maxNumImages
        self.maxImageMemoryThreshold = maxImageMemoryThreshold
    }
    
    open func addImage(id: String, image: NSImage) {
        self.imageCache[id] = image
        if !self.imageIDList.contains(id) {
            self.imageIDList.append(id)
            if self.hasReachedCacheLimit() {
                if let fID = self.imageIDList.first {
                    self.imageCache.removeValue(forKey: fID)
                    self.imageIDList.removeFirst()
                }
            }
        }
    }
    
    open func getImage(id: String) -> NSImage? {
        if let image = self.imageCache[id] {
            // Keep the cache ID list organized (very simple algorithm to keep most used ID's in the cache)
            if let idx = self.findLastInListFirst(id: id) {
                self.imageIDList.remove(at: idx)
                self.imageIDList.append(id)
            }
            return image
        }
        return nil
    }
    
    // Search placement in index list from behind, as those items are the ones most recently used
    private func findLastInListFirst(id: String) -> Int? {
        for idx in (0..<self.imageIDList.count).reversed() {
            if self.imageIDList[idx] == id {
                return idx
            }
        }
        return nil
    }

    open func removeImage(id: String) {
        if let idx = self.imageIDList.index(of: id) {
            self.imageIDList.remove(at: idx)
            self.imageCache.removeValue(forKey: id)
        }
    }
    
    open func removeAll() {
        self.imageCache.removeAll()
        self.imageIDList.removeAll()
    }
    
    open func hasReachedCacheLimit() -> Bool {
        if self.imageIDList.count > maxNumImages {
            return true
        }
        var consumedApproxMem:Double = 0
        for image in self.imageCache.values {
            let size = image.size.width * image.size.height * 4
            consumedApproxMem += Double(size) / (1024.0*1024.0)
        }
        if consumedApproxMem >= self.maxImageMemoryThreshold {
            return true
        }
        return false
    }
}

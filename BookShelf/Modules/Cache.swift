//
//  DiskCache.swift
//  BookShelf
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import UIKit

class DiskCache {
    
    let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    let cacheUrl: URL
    var async: Bool = false
    
    fileprivate init(usage: String) {
        var cacheUrl = URL(fileURLWithPath: rootPath)
        cacheUrl.appendPathComponent("com.cream.DiskCache")
        cacheUrl.appendPathComponent(usage)
        self.cacheUrl = cacheUrl
        
        self.createCacheDeriectoryIfNeeded()
    }
    
    private func createCacheDeriectoryIfNeeded() {
        do {
            if FileManager.default.fileExists(atPath: self.cacheUrl.path) == false {
                try FileManager.default.createDirectory(at: self.cacheUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    fileprivate func setObject(_ object: NSObject, key: String) {
        let setAction = {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
                try data.write(to: self.cacheUrl(with: key), options: [.atomicWrite])
            } catch {
                print("#Error : \(error.localizedDescription)")
            }
        }
        
        if async {
            DispatchQueue.global().async {
                setAction()
            }
        } else {
            setAction()
        }
    }
    
    fileprivate func hasCachedObject(withKey key: String) -> Bool {
        return FileManager.default.fileExists(atPath: self.cacheUrl(with: key).path)
    }
    
    fileprivate func getObject<T: NSObject & NSCoding>(withKey key: String, decodedType: T.Type, completion: @escaping ((T?) -> Void)) {
        let getAction = {
            let cacheObjectUrl = self.cacheUrl(with: key)
            if FileManager.default.fileExists(atPath: cacheObjectUrl.path) {
                do {
                    let data = try Data(contentsOf: cacheObjectUrl)
                    if let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: decodedType, from: data) {
                        completion(object)
                    }
                } catch {
                    print("#Error : \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
        
        if async {
            DispatchQueue.global().async {
                getAction()
            }
        } else {
            getAction()
        }
    }
    
    fileprivate func setData(_ data: NSData, key: String) {
        
        let setAction = {
            do {
                try data.write(to: self.cacheUrl(with: key), options: [.atomic])
            } catch {
                print("#Error : \(error.localizedDescription)")
            }
        }
        
        if async {
            DispatchQueue.global().async {
                setAction()
            }
        } else {
            setAction()
        }
    }
    
    fileprivate func getData(withKey key: String, completion: @escaping (NSData?) -> Void) {
        
        let getAction = {
            let cacheObjectUrl = self.cacheUrl(with: key)
            if FileManager.default.fileExists(atPath: cacheObjectUrl.path) {
                do {
                    completion(try NSData(contentsOf: cacheObjectUrl, options: [.mappedIfSafe]))
                } catch {
                    print("NSData(contentOf:...) method failed. \(error.localizedDescription)")
                }
            } else {
                completion(nil)
            }
        }
        if async {
            DispatchQueue.global().async {
                getAction()
            }
        } else {
            getAction()
        }
    }
    
    fileprivate func remove(withKey key: String) {
        DispatchQueue.global().async {
            if FileManager.default.fileExists(atPath: self.cacheUrl(with: key).path) {
                try? FileManager.default.removeItem(atPath: self.cacheUrl(with: key).path)
            }
        }
    }
    
    private func cacheUrl(with key: String) -> URL {
        return self.cacheUrl.appendingPathComponent(key, isDirectory: false)
    }
    
    func cleanCache() {
        do {
            if FileManager.default.fileExists(atPath: self.cacheUrl.path) {
                try FileManager.default.removeItem(at: self.cacheUrl)
            }
            self.createCacheDeriectoryIfNeeded()
        } catch {
            print("#Error : \(error.localizedDescription)")
        }
    }
}

final class ImageCache: DiskCache {
    static let shared = ImageCache(usage: "Image")
    
    private static let memCache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, key: String) {
        ImageCache.memCache.setObject(image, forKey: key as NSString)
        super.setObject(image, key: key)
    }
    
    func hasCachedImage(withKey key: String) -> Bool {
        let memCachedImage = ImageCache.memCache.object(forKey: key as NSString)
        if memCachedImage != nil {
            return true
        }
        return super.hasCachedObject(withKey: key)
    }
    
    func getImage(withKey key: String, completion: @escaping (UIImage?) -> Void) {
        if let memCachedImage = ImageCache.memCache.object(forKey: key as NSString) {
            completion(memCachedImage)
            return
        }
        super.getObject(withKey: key, decodedType: UIImage.self) { image in
            guard let image = image else {
                completion(nil)
                return
            }
            ImageCache.memCache.setObject(image, forKey: key as NSString)
            completion(image)
        }
    }

    func removeImage(withKey key: String) {
        ImageCache.memCache.removeObject(forKey: key as NSString)
        super.remove(withKey: key)
    }
    
    override func cleanCache() {
        super.cleanCache()
        ImageCache.memCache.removeAllObjects()
    }
}

final class DataCache: DiskCache {
    static let shared = DataCache(usage: "Data")
    
    private static let memCache = NSCache<NSString, NSData>()
    
    func setData(_ data: Data, key: String) {
        DataCache.memCache.setObject(NSData(data: data), forKey: key as NSString)
        super.setData(NSData(data: data), key: key)
    }
    
    func hasCachedData(withKey key: String) -> Bool {
        let memCachedData = DataCache.memCache.object(forKey: key as NSString)
        if memCachedData != nil {
            return true
        }
        return super.hasCachedObject(withKey: key)
    }
    
    func getData(withKey key: String, completion: @escaping (Data?) -> Void) {
        if let memCachedData = DataCache.memCache.object(forKey: key as NSString) {
            completion(memCachedData as Data)
            return
        }
        super.getData(withKey: key) { nsData in
            guard let nsData = nsData else {
                completion(nil)
                return
            }
            DataCache.memCache.setObject(nsData, forKey: key as NSString)
            completion(nsData as Data)
        }
    }
    
    func removeData(withKey key: String) {
        DataCache.memCache.removeObject(forKey: key as NSString)
        super.remove(withKey: key)
    }
    
    override func cleanCache() {
        super.cleanCache()
        DataCache.memCache.removeAllObjects()
    }
}

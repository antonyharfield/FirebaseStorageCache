//
//  FIRStorageCache.swift
//  ABC Events
//
//  Created by Ant on 28/12/2016.
//  Copyright © 2016 Apptitude. All rights reserved.
//

import Foundation
import FirebaseStorage

public class FirebaseStorageCache {
    
    fileprivate let cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
    }
    
    public func get(storageReference: StorageReference, completion: @escaping (_ object: Data?) -> Void) {
        
        let filePath = self.filePath(storageReference: storageReference)
        
        cache.get(key: filePath, completion: { object in
            if let object = object {
                // Cache hit
                DispatchQueue.main.async(execute: {
                    completion(object)
                })
                return
            }
            // Cache miss: download file
            storageReference.downloadURL(completion: { (url, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        completion(nil)
                    })
                    return
                }
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    guard let httpURLResponse = response as? HTTPURLResponse,
                        httpURLResponse.statusCode == 200,
                        let data = data, error == nil else {
                            print(error?.localizedDescription ?? "Error status code \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                            DispatchQueue.main.async(execute: {
                                completion(nil)
                            })
                            return
                    }
                    // Store result in cache
                    self.cache.add(key: filePath, data: data, completion: {
                        DispatchQueue.main.async(execute: {
                            completion(data)
                        })
                    })
                }).resume()
            })
        })
    }
    
    public func get(downloadURL: String, completion: @escaping (_ object: Data?) -> Void) {
        // Check valid download url
        guard let url = URL(string: downloadURL) else {
            completion(nil)
            return
        }
        
        let filePath = self.filePath(url: url)
        
        cache.get(key: filePath, completion: { object in
            if let object = object {
                // Cache hit
                DispatchQueue.main.async(execute: {
                    completion(object)
                })
                return
            }
            // Cache miss: download file
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200,
                    let data = data, error == nil else {
                        print(error?.localizedDescription ?? "Error status code \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                        DispatchQueue.main.async(execute: {
                            completion(nil)
                        })
                        return
                }
                // Store result in cache
                self.cache.add(key: filePath, data: data, completion: {
                    DispatchQueue.main.async(execute: {
                        completion(data)
                    })
                })
            }).resume()
        })
    }
    
    public func remove(storageReference: StorageReference) {
        cache.remove(key: filePath(storageReference: storageReference), completion: nil)
    }
    
    private func filePath(storageReference: StorageReference) -> String {
        return "\(storageReference.bucket)/\(storageReference.fullPath)"
    }
    
    private func filePath(url: URL) -> String {
        return "\(url.path)"
    }
}

extension FirebaseStorageCache {
    
    static public var main: FirebaseStorageCache = FirebaseStorageCache(cache: DiskCache(name: "firstoragecache"))
    
    var cachePath: String {
        if let diskCache = cache as? DiskCache {
            return diskCache.cachePath
        }
        return ""
    }
    
    public func prune() {
        if let diskCache = cache as? DiskCache {
            diskCache.prune()
        }
    }

}

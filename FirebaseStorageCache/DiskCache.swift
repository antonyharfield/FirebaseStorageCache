//
//  DiskCache.swift
//  FirebaseStorageCache
//

import Foundation

class DiskCache: Cache {
    
    let name: String
    let cachePath: String
    let cacheDuration: TimeInterval
    
    private let writeQueue: DispatchQueue
    private let readQueue: DispatchQueue
    private let fileManager: FileManager
    
    init(name: String, cacheDuration: TimeInterval = 3600) {
        self.name = name
        self.cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/" + name
        self.cacheDuration = cacheDuration
        
        fileManager = FileManager()
        writeQueue = DispatchQueue(label: "write-\(name)", attributes: [])
        readQueue = DispatchQueue(label: "read-\(name)", attributes: [])
    }
    
    internal func get(key: String, completion: @escaping (_ object: Data?) -> Void) {
        readQueue.async { [weak self] in
            guard let weakSelf = self else {
                completion(nil)
                return
            }
            
            let fullPath = "\(weakSelf.cachePath)/\(key)"
            if let attr = try? weakSelf.fileManager.attributesOfItem(atPath: fullPath),
                let modificationDate = attr[FileAttributeKey.modificationDate] as? Date,
                modificationDate.addingTimeInterval(weakSelf.cacheDuration).timeIntervalSinceNow > 0,
                let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
                
                print("DiskCache: hit: \(key) \(modificationDate.addingTimeInterval(weakSelf.cacheDuration).timeIntervalSinceNow)")
                completion(data)
            }
            else {
                print("DiskCache: miss: \(key)")
                completion(nil)
            }
        }
    }
    
    internal func add(key: String, data: Data, completion: (() -> Void)? = nil) {
        writeQueue.async { [weak self] in
            guard let weakSelf = self else {
                completion?()
                return
            }
            
            if !weakSelf.fileManager.fileExists(atPath: weakSelf.cachePath) {
                do {
                    try weakSelf.fileManager.createDirectory(atPath: weakSelf.cachePath, withIntermediateDirectories: true, attributes: nil)
                } catch {}
            }
            
            let fullPath = "\(weakSelf.cachePath)/\(key)"
            
            let directoryPath = URL(fileURLWithPath: fullPath).deletingLastPathComponent().path
            if !weakSelf.fileManager.fileExists(atPath: directoryPath) {
                do {
                    try weakSelf.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                } catch {}
            }
            
            let attributes = [FileAttributeKey.modificationDate.rawValue: NSDate()]
            weakSelf.fileManager.createFile(atPath: fullPath, contents: data, attributes: attributes)
            print("DiskCache: saved: \(key)")
            completion?()
        }
    }
    
    internal func remove(key: String, completion: (() -> Void)? = nil) {
        writeQueue.async { [weak self] in
            guard let weakSelf = self else {
                completion?()
                return
            }
            
            let fullPath = "\(weakSelf.cachePath)/\(key)"
            do {
                try weakSelf.fileManager.removeItem(atPath: fullPath)
            } catch {}
            
            print("DiskCache: removed: \(key)")
            completion?()
        }
    }
    
}

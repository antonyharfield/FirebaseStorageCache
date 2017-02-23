//
//  DiskCache.swift
//  FirebaseStorageCache
//

import Foundation

public class DiskCache: Cache {
    
    let name: String
    let cachePath: String
    let cacheDuration: TimeInterval
    
    private let writeQueue: DispatchQueue
    private let readQueue: DispatchQueue
    private let fileManager: FileManager
    
    init(name: String, cacheDuration: TimeInterval = 3600) {
        self.name = name
        self.cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/" + name
        //self.cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/" + name
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
                
                print("DiskCache: hit: \(key)")
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
    
    internal func prune() {
        writeQueue.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            if weakSelf.fileManager.fileExists(atPath: weakSelf.cachePath), let filePaths = weakSelf.fileManager.enumerator(atPath: weakSelf.cachePath) {
                
                while let file = filePaths.nextObject() as? String {
                    
                    let filePath = "\(weakSelf.cachePath)/\(file)"
                    if let attr = try? weakSelf.fileManager.attributesOfItem(atPath: filePath),
                        let type = attr[FileAttributeKey.type] as? String,
                        type != "NSFileTypeDirectory",
                        let modificationDate = attr[FileAttributeKey.modificationDate] as? Date,
                        modificationDate.addingTimeInterval(weakSelf.cacheDuration).timeIntervalSinceNow < 0 {
                        
                            try? weakSelf.fileManager.removeItem(atPath: filePath)
                            print("DiskCache: pruning: \(file)")
                    }
                }
            }
        }
    }
    
}

//
//  Cache.swift
//  FirebaseStorageCache
//
//  Created by Ant on 19/02/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import Foundation

protocol Cache {
    
    func get(key: String, completion: @escaping (_ object: Data?) -> Void)
    
    func add(key: String, data: Data, completion: (() -> Void)?)
    
    func remove(key: String, completion: (() -> Void)?)
    
}

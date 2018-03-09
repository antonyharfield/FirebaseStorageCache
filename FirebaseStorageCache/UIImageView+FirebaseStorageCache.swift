//
//  UIImageView+FirebaseStorageCache.swift
//
//  Created by Ant on 28/12/2016.
//  Copyright © 2016 Apptitude. All rights reserved.
//

import UIKit
import FirebaseStorage

extension UIImageView {
    
    public func setImage(storageReference: StorageReference, cache: FirebaseStorageCache = .main) {
        cache.get(storageReference: storageReference) { data in
            if let data = data, let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
    
    public func setImage(downloadURL: String, cache: FirebaseStorageCache = .main) {
        cache.get(downloadURL: downloadURL) { data in
            if let data = data, let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
}

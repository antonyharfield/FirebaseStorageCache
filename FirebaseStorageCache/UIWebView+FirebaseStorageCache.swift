//
//  UIWebView+FirebaseStorageCache.swift
//
//  Created by Ant on 30/12/2016.
//  Copyright © 2016 Apptitude. All rights reserved.
//

import UIKit
import WebKit
import FirebaseStorage

extension UIWebView {
    
    public func loadHTML(storageReference: FIRStorageReference, cache: FirebaseStorageCache = .main, postProcess: ((Data) -> Data)? = nil) {
        
        cache.get(storageReference: storageReference) { data in
            if let data = data {
                self.load(postProcess?(data) ?? data, mimeType: "text/html", textEncodingName: "utf-8", baseURL: URL(fileURLWithPath: cache.cachePath))
            }
        }
    }
}

extension WKWebView {
    
    public func loadHTML(storageReference: FIRStorageReference, cache: FirebaseStorageCache = .main, postProcess: ((Data) -> Data)? = nil) {
        
        cache.get(storageReference: storageReference) { data in
            if let data = data {
                self.load(postProcess?(data) ?? data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: URL(fileURLWithPath: cache.cachePath))
            }
        }
    }
}

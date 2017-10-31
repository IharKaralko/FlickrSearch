//
//  Photo.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/15/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class Photo  {
    var thumbnail : UIImage?
    var largeImage : UIImage?
    var photoID = String()
    var farm = Int()
    var server = String()
    var secret = String()
    
    
    func flickrImageURL(_ size:String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }
    
    func loadLargeImage(_ completion: @escaping (_ flickrPhoto:Photo, _ error: NSError?) -> Void) {
        guard let loadURL = flickrImageURL("b") else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }
        URLSession.shared.dataTask(with: loadURL, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self, error as NSError?)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
                return
            }
            
            let returnedImage = UIImage(data: data)
            self.largeImage = returnedImage
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }
    
    
    func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
        
        guard let thumbnail = thumbnail else {
            return size
        }
        
        let imageSize = thumbnail.size
        var returnSize = size
        let aspectRatio = imageSize.width / imageSize.height
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        return returnSize
    }
}

 //
 //  FlickrPhoto.swift
 //  FlickrApp
 //
 //  Created by Ihar Karalko on 9/15/17.
 //  Copyright © 2017 Ihar Karalko. All rights reserved.
 //

 import UIKit

class FlickrPhoto : Equatable {
  var thumbnail : UIImage?
  var largeImage : UIImage?
  let photoID : String
  let farm : Int
  let server : String
  let secret : String
  
  init (photoID:String,farm:Int, server:String, secret:String) {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
  func flickrImageURL(_ size:String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
      return url
    }
    return nil
  }
  
   
    func loadLargeImage(_ photo:FlickrPhoto)->UIImage?{
         //guard
            let loadURL = flickrImageURL("b")// else {
    
    let loadRequest = URLRequest(url:loadURL!)
    
    URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
        if error != nil {
            print(error!.localizedDescription)
      
        return
      }
      
      guard let data = data else {
        return
      }
      
      let returnedImage = UIImage(data: data)
      photo.largeImage = returnedImage
     }).resume()
        return photo.largeImage
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

func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}

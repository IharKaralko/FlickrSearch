//
//  FlickrTwo.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/20/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit


let apiKey = "6b78b4e6eda4ef1239026421f11c630a"

class Flickr {
 
    
   func flickrSearchURLForSearchTerm( _ searchTerm:String) -> URL? {
    
    
    guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
   
     func searchFlickrForTerm(_ searchTerm: String, completion : @escaping (_ results: FlickrSearchResults?, _ error : NSError?) -> Void){
        
        guard let searchURL = flickrSearchURLForSearchTerm(searchTerm) else {
            let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let session = URLSession.shared
        
        session.dataTask(with:searchURL) { (data, response, error) in
            if let _ = error {
                let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                DispatchQueue.main.async{
                    completion(nil, APIError)
                }
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    DispatchQueue.main.async{
                        completion(nil, APIError)
                    }
                    return
            }
            do {
                guard  let parsedData = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                    else{ return }
                
                guard   let stat = parsedData["stat"] as? String else {
                    return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    print("Fail  process!!!! ")
                    return
                default:
                    print("unknown case")
                    return
                }
                
                    guard let photosContainer = parsedData["photos"] as? [String: Any],
                        let photosReceived = photosContainer["photo"] as? [[String: Any]] else {
                            let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                            DispatchQueue.main.async{
                                completion(nil, APIError)
                            }
                            return
                    }
                    
                    var flickrPhotos = [Photo]()
                    
                    for mem in photosReceived{
                        
                        let photo = Photo()
                        
                        guard let photoID = mem["id"] as? String,
                            let farm = mem["farm"] as? Int,
                            let server = mem["server"] as? String,
                            let secret = mem["secret"] as? String
                            else { break }
                        
                        photo.photoID  = photoID
                        photo.farm = farm
                        photo.server = server
                        photo.secret = secret
                        
                        
                        guard let url = photo.flickrImageURL(),
                            let imageData = try? Data(contentsOf: url as URL) else {
                                break
                        }
                        
                        if let image = UIImage(data: imageData) {
                            photo.thumbnail = image
                            flickrPhotos.append(photo)
                        }
                    }
                    DispatchQueue.main.async{
                        completion(FlickrSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos), nil)
                    }
                  }
                  catch  {
                    completion(nil, nil)
                    return
            }
            
            }.resume()
        
    }
}

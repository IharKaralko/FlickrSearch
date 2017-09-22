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
 
    
    func flickrSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
        
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
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
            let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let session = URLSession.shared
      //  let searchRequest = URLRequest(url: searchURL)
        
    
        
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
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                    // print(parsedData)
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
                        return
                    }
                    
                    guard let photosContainer = parsedData["photos"] as? [String: AnyObject],
                        let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                            let APIError = NSError(domain: "FlickrApp", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                            DispatchQueue.main.async{
                                completion(nil, APIError)
                            }
                            return
                    }
                    
                    var flickrPhotos = [Photo]()
                    
                                     for mem in photosReceived{
                               
                        let photo = Photo()
                        
                        
                        photo.photoID  = mem["id"] as! String
                        photo.farm = mem["farm"] as! Int
                        photo.server = mem["server"] as! String
                        photo.secret = mem["secret"] as! String
                        
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
                  catch _ {
                    completion(nil, nil)
                    return
                     
            }
           
            }.resume()
        
            }
   
    
}

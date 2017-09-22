//
//  FlickrTwo.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/20/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit
let apiKeyTwo = "6b78b4e6eda4ef1239026421f11c630a"

class FlickrTwo {
    var results: FlickrSearchResultsOne?
    
    func flickrSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
        
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKeyTwo)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
   
     func searchFlickrForTerm(_ searchTerm: String, completion : @escaping (_ results: FlickrSearchResultsOne?, _ error : NSError?) -> Void){
        
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
                    completion(FlickrSearchResultsOne(searchTerm: searchTerm, searchResults: flickrPhotos), nil)
                    }
                    
                        }
                  catch _ {
                    completion(nil, nil)
                    return
                     
            }
           
            }.resume()
        
        //return results
    }
   
    func GetJsonPhoto(_ searchTerm: String){
       let session = URLSession.shared
        
        guard  let searchURL = flickrSearchURLForSearchTerm(searchTerm)
            else {
                results = nil
                print("Unknown API response")
                return
        }
        
        session.dataTask(with:searchURL) { (data, response, error) in
//            if error != nil {
//                print(error!.localizedDescription)
//            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    // print(parsedData)
                    
                    
                    let currentConditions = parsedData["photos"] as! [String:Any]
                    // print(currentConditions)
                    let members = currentConditions["photo"] as! [[String: Any]]
                    print(members.count)
                    
                    var photos = [Photo]()
                    
                    
                    for mem in members{
                        //  print(mem)
                        
                        let photo = Photo()
                        
                        
                        photo.photoID  = mem["id"] as! String
                        photo.farm = mem["farm"] as! Int
                        photo.server = mem["server"] as! String
                        photo.secret = mem["secret"] as! String
                        
                        
                        photos.append(photo)
                       
                    }
                    
                    OperationQueue.main.addOperation({
                        self.results = FlickrSearchResultsOne(searchTerm: searchTerm, searchResults: photos)})
                    
                  }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
           // }
            }.resume()
         }
       
}

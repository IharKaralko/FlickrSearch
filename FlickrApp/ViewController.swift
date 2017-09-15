//
//  ViewController.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/11/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var k = 0
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var buddyicons: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
  
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let identifier = "CellIdentifier"
    
    let images = ["photo", "search", "you", "setting","photo", "search", "you", "setting","photo", "search", "you", "setting","photo", "search", "you", "setting","photo", "search", "you", "setting"]
    
    let albums = ["balkan","bonsai","bochka", "dastarhan"]
    
    var photos = [Photo]()
    
    @IBAction func indexChanged(_ sender: Any) {
        
     
        
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            k = 0
            collectionView.reloadData()
            //            let stringURL = "https://www.flickr.com/photos/158119896@N05"
//            
//            guard let url = URL(string: stringURL) else { return }
//            
//            let request = URLRequest(url: url)
//            webView.loadRequest(request)
        case 1:
            k = 1
            collectionView.reloadData()
            //        let stringURL = "https://www.flickr.com/photos/158119896@N05/albums"
//            guard let url = URL(string: stringURL) else { return }
//            
//            let request = URLRequest(url: url)
//            webView.loadRequest(request)
        default:
            break;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if k == 0 {
            return photos.count
        }
        else { return albums.count
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if k == 0 {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as! MyCollectionViewCell
            
            let photo = photos[indexPath.row]
           
           DispatchQueue.global().async{
                guard         let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.photoID)_\(photo.secret)_m.jpg") else{ return }
            
                guard  let imageData = try? Data(contentsOf: url) else { return }
                
                if let image = UIImage(data: imageData) {
                    
                    DispatchQueue.main.async{
                       cell.myImageView.image = image
                    }
                }
            
                else {return}
            }
          //  cell.myImageView.image = UIImage(named: images[indexPath.row])
            
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as! MyCollectionViewCell
            cell.myImageView.image = UIImage(named: albums[indexPath.row])
            
            return cell
        }
    
            
            
       
        
        
    }
    
    
    
    
    let buddyiconUrl = "http://farm5.staticflickr.com/4389/buddyicons/158119896@N05.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self // as? UICollectionViewDataSource
        getBuddyicon()
        GetUserName()
        GetJsonPhoto()
         //collectionView.reloadData()
    }
   
    func GetJsonPhoto(){
        let session = URLSession.shared
        let urlString  = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&per_page=150&format=json&nojsoncallback=1"
        
               guard let url = URL(string: urlString) else { return }
        
        session.dataTask(with:url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                   // print(parsedData)
                    let currentConditions = parsedData["photos"] as! [String:Any]
                   // print(currentConditions)
                    let members = currentConditions["photo"] as! [[String: Any]]
                    print(members.count)
                    
                    for mem in members{
                        //  print(mem)
                        
                        let photo = Photo()
                      
                        
                        photo.photoID  = mem["id"] as! String
                        photo.farm = mem["farm"] as! Int
                        photo.server = mem["server"] as! String
                        photo.secret = mem["secret"] as! String
                        
                       
                        self.photos.append(photo)
                    }
                   
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                   
                    }
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            }.resume()
    }

    
    
    
    
    
    
    
    
    func GetUserName(){
        
        let memberLinkRequest = "https://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&format=json&nojsoncallback=1"
        let session = URLSession.shared
        guard let linkurl = URL(string: memberLinkRequest) else { return }
        
        session.dataTask(with:linkurl) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let currentConditions = parsedData["person"] as! [String:Any]
                    let linkMembers =  currentConditions["username"] as! [String:Any]
                    let linkFeed = linkMembers["_content"] as! String
                    DispatchQueue.main.async{
                        self.userName.text = linkFeed
                    }
                    
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            }.resume()
    }
    
    func getBuddyicon(){
        
        DispatchQueue.global().async{
            guard let url = URL(string: self.buddyiconUrl) else { return }
            guard let imageData = try? Data(contentsOf: url) else { return }
            if let image = UIImage(data: imageData) {
                DispatchQueue.main.async{
                    self.buddyicons.image = image
                }
            }
            else {return}
            self.buddyicons.clipsToBounds = true
            self.buddyicons.layer.cornerRadius = 36
        }
    }
}


//
//  ViewController.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/11/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var k = 0
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var buddyicons: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
  
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //let identifier = "CellIdentifier"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    let itemsPerRow: CGFloat = 3
    var inexPath: Int?
    
    
    
    
    let images = ["photo", "search", "you", "setting","photo", "search", "you", "setting","photo", "search", "you", "setting","photo", "search", "you", "setting","photo", "search", "you", "setting"]
    
    let albums = ["balkan","bonsai","bochka", "dastarhan"]
    
    var photos = [Photo]()
    var sets = [Album]()
    
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
        else { return sets.count
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellAlbum", for: indexPath) as! MyAlbumCollectionViewCell
            
            print(indexPath.row)
            
              let photoSet = sets[indexPath.row]
            print(indexPath.row)
            
            DispatchQueue.global().async{
                guard         let url = URL(string: "https://farm\(photoSet.setPhotos[0].farm).staticflickr.com/\(photoSet.setPhotos[0].server)/\(photoSet.setPhotos[0].photoID)_\(photoSet.setPhotos[0].secret)_m.jpg") else{ return }
                print(url)
                guard  let imageData = try? Data(contentsOf: url) else { return }
                
                print(imageData)
                
                if let image = UIImage(data: imageData) {
                    
                    DispatchQueue.main.async{
                        cell.albumImageView.image = image
                        cell.label.text = photoSet.photoSetTitle
                    }
              }
                    
                else {return}
            }
            
            
            
            
            //cell.myImageView.image = UIImage(named: albums[indexPath.row])
            
            
            return cell
        }
        
    }
    
    
    //Mark UICollectionViewDelegateFlowLayout
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        if k == 0 {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
        else {
            return CGSize(width: 220, height: 190)
        }
    }
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    
    
    
    
    
    
    
    let buddyiconUrl = "http://farm5.staticflickr.com/4389/buddyicons/158119896@N05.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetPhotoSetsJson()
        collectionView.delegate = self
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

    func GetPhotoSetsJson(){
        
        let session = URLSession.shared
        
        let urlString  = "https://api.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&format=json&nojsoncallback=1"
        
        guard let url = URL(string: urlString) else { return }
        
        session.dataTask(with:url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                     //print(parsedData)
                    let currentConditions = parsedData["photosets"] as! [String:Any]
                    // print(currentConditions)
                    
                    let members = currentConditions["photoset"] as! [[String: Any]]
                 //  print(members)

                    for mem in members{
                        
                     let photoSet = Album()
 
                        
                        photoSet.photoSetID  = mem["id"] as! String
                        
                        let sessionOne = URLSession.shared
                        
                         let urlStringOne  = "https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&photoset_id=\(photoSet.photoSetID)&format=json&nojsoncallback=1"
                        
                        guard let url = URL(string: urlStringOne) else { return }
                        
                        sessionOne.dataTask(with:url) { (data, response, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                do {
                                    let parsedDataOne = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                                 //  print(parsedDataOne)
                                    let currentConditionsOne = parsedDataOne["photoset"] as! [String:Any]
                                    //print(currentConditionsOne)
                                  
                                      let membersOne = currentConditionsOne["photo"] as! [[String: Any]]
                                 //   print(membersOne)
                                    for memOne in membersOne{
                                        
                                        let  photo = Photo()
                                        photo.photoID = memOne["id"] as! String
                                        photo.farm = memOne["farm"] as! Int
                                        photo.secret = memOne["secret"] as! String
                                        photo.server = memOne["server"] as! String
                                        photoSet.setPhotos.append(photo)
                                        
                                    }
                                    photoSet.photoSetTitle =   currentConditionsOne["title"] as! String
                                    //  print(photoSet.photoSetTitle)
                                    
                                    
                                    //     let currentConditions = parsedData["photosets"] as! [String:Any]
                                    // print(currentConditions)
                                    
                                    //   let members = currentConditions["photoset"] as! [[String: Any]]
                                    //print(members)
                                    
                                }
                                catch let error as NSError {
                                    print(error.localizedDescription)
                                }
                                self.sets.append(photoSet)
                                print(self.sets.count)
                            }
                            }.resume()
                        
                    
                    
                        
                        
                        
                        
                        
                        
                        
//                    let titleSet = mem["description"] as! String
//                        //    photoSet.photoSetTitle = titleSet["_content"] as! String
//                       
//                       print(titleSet)
//                      //  print(photoSet.photoSetID)
                        //                       photo.farm = mem["farm"] as! Int
//                        photo.server = mem["server"] as! String
//                        photo.secret = mem["secret"] as! String
//                        
//                        
//                        self.photos.append(photo)
//                    }
//                    
//                    DispatchQueue.main.async{
//                        self.collectionView.reloadData()
//                        
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
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if k != 0 {
         inexPath = indexPath.row
        // print(inexPath)
        self.performSegue(withIdentifier: "detail", sender: self)
        }
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if k != 0{
            
    //    indexPath = collectionView.indexPathsForSelectedItems()[0] as? IndexPath
            if segue.identifier == "detail"{
                
//      if let indexPath = collectionView.indexPathsForSelectedItems{
            let dvc = segue.destination as! DetailAlbumCollectionViewController;
                dvc.setPhotos = sets[inexPath!].setPhotos
                dvc.title = sets[inexPath!].photoSetTitle
            }
        }
    }
   // }
}


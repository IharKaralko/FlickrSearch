//
//  ViewController.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/11/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    var k = 0
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var buddyicons: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
       
    var pathRow = Int()
    var photos = [Photo]()
    var sets = [Album]()
    
    var largePhotoIndexPath: IndexPath? {
        didSet {
            
            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath {
                indexPaths.append(largePhotoIndexPath)
            }
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }
            collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPaths)
            }) { completed in
                //4
                if let largePhotoIndexPath = self.largePhotoIndexPath {
                    self.collectionView.scrollToItem(
                        at: largePhotoIndexPath,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            k = 0
            collectionView.reloadData()
        case 1:
            k = 1
            collectionView.reloadData()
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        getBuddyicon()
        GetUserName()
        GetJsonPhoto()
        GetPhotoSetsJson()
    }
  
    let buddyiconUrl = "http://farm5.staticflickr.com/4389/buddyicons/158119896@N05.jpg"

    func getBuddyicon(){
        DispatchQueue.global().async{
            guard let url = URL(string: self.buddyiconUrl) else { return }
            guard let imageData = try? Data(contentsOf: url) else { return }
            if let image = UIImage(data: imageData) {
                DispatchQueue.main.async{
                    self.buddyicons.image = image
                    self.buddyicons.clipsToBounds = true
                    self.buddyicons.layer.cornerRadius = 36
                }
            }
            else { return }
        }
    }
    
    func GetUserName(){
         let memberLinkRequest = "https://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&format=json&nojsoncallback=1"
        let session = URLSession.shared
        guard let linkurl = URL(string: memberLinkRequest) else { return }
        
        session.dataTask(with:linkurl) { (data, response, error) in
           
            guard let data = data,
            let _ = response as? HTTPURLResponse
                        else { return }
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                  guard  let parsedData = try JSONSerialization.jsonObject(with: data) as? [String:Any],
                    let currentConditions = parsedData["person"] as? [String:Any],
                    let linkMembers =  currentConditions["username"] as? [String:Any],
                    let linkFeed = linkMembers["_content"] as? String
                    else { return }
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

    func GetJsonPhoto(){
        let session = URLSession.shared
        let urlString  = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&per_page=150&format=json&nojsoncallback=1"
        
        guard let url = URL(string: urlString) else { return }
        
        session.dataTask(with:url) { (data, response, error) in
            guard let data = data,
                let _ = response as? HTTPURLResponse
                else { return }
            
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                  guard  let parsedData = try JSONSerialization.jsonObject(with: data) as? [String:Any],
                    let currentConditions = parsedData["photos"] as? [String:Any],
                    let members = currentConditions["photo"] as? [[String: Any]]
                    else { return }
                    
                    for mem in members{
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
           
            guard let data = data,
                let _ = response as? HTTPURLResponse
                else { return }
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                   guard let parsedData = try JSONSerialization.jsonObject(with: data) as? [String:Any],
                    let currentConditions = parsedData["photosets"] as? [String:Any],
                    let members = currentConditions["photoset"] as? [[String: Any]]
                    else { return }
                    
                    for mem in members{
                        let photoSet = Album()
                        
                        guard let photoSetID  = mem["id"] as? String else { return}
                       
                        photoSet.photoSetID  = photoSetID
                        
                        let sessionOne = URLSession.shared
                        
                        let urlStringOne  = "https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=6b78b4e6eda4ef1239026421f11c630a&user_id=158119896@N05&photoset_id=\(photoSet.photoSetID)&format=json&nojsoncallback=1"
                        
                        guard let url = URL(string: urlStringOne) else { return }
                        
                        sessionOne.dataTask(with:url) { (data, response, error) in
                            guard let data = data,
                                let _ = response as? HTTPURLResponse
                                else { return }
                            
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                do {
                                   guard let parsedDataOne = try JSONSerialization.jsonObject(with: data) as? [String:Any],
                                    let currentConditionsOne = parsedDataOne["photoset"] as? [String:Any],
                                    let membersOne = currentConditionsOne["photo"] as? [[String: Any]]
                                    else { return }
                                    
                                    for memOne in membersOne{
                                        let  photo = Photo()
                                       
                                        guard let photoID = memOne["id"] as? String,
                                            let farm = memOne["farm"] as? Int,
                                            let server = memOne["server"] as? String,
                                            let secret = memOne["secret"] as? String
                                            else { break }
                                        
                                        photo.photoID  = photoID
                                        photo.farm = farm
                                        photo.server = server
                                        photo.secret = secret
                                        photoSet.setPhotos.append(photo)
                                    }
                                   
                                    guard let photoSetTitle = currentConditionsOne["title"] as? String
                                        else { return }
                                    
                                    photoSet.photoSetTitle =  photoSetTitle
                                }
                                catch let error as NSError {
                                    print(error.localizedDescription)
                                }
                                self.sets.append(photoSet)
                               // print(self.sets.count)
                            }
                            }.resume()
                    }
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            }.resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if k != 0{
            if segue.identifier == "detail"{
                let dvc = segue.destination as! DetailAlbumCollectionViewController;
                dvc.setPhotos = sets[pathRow].setPhotos
                dvc.title = sets[pathRow].photoSetTitle
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource{
    
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
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellAlbum", for: indexPath) as! MyAlbumCollectionViewCell
            let photoSet = sets[indexPath.row]
           
            
            DispatchQueue.global().async{
                guard         let url = URL(string: "https://farm\(photoSet.setPhotos[0].farm).staticflickr.com/\(photoSet.setPhotos[0].server)/\(photoSet.setPhotos[0].photoID)_\(photoSet.setPhotos[0].secret)_m.jpg") else{ return }
                guard  let imageData = try? Data(contentsOf: url) else { return }
                if let image = UIImage(data: imageData) {
                    
                    DispatchQueue.main.async{
                        cell.albumImageView.image = image
                        cell.label.text = photoSet.photoSetTitle
                    }
                }
                else {return}
            }
            return cell
        }
    }
}
// MARK: -   UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if k != 0 {
            pathRow = indexPath.row
            self.performSegue(withIdentifier: "detail", sender: self)
        }
        else {
            if largePhotoIndexPath == indexPath {largePhotoIndexPath  = nil}
            else{largePhotoIndexPath = indexPath}
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if k == 0 {
            if indexPath == largePhotoIndexPath {
                let flickrPhoto = photos[indexPath.row]
                var size = collectionView.bounds.size
                size.height = 240
                size.width = 280
                return flickrPhoto.sizeToFillWidthOfSize(size)
             }
              return CGSize(width: 140, height: 140)
        }
        else {
            return CGSize(width: 220, height: 190)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

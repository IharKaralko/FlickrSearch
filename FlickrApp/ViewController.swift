//
//  ViewController.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/11/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var buddyicons: UIImageView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            let stringURL = "https://www.flickr.com/photos/158119896@N05"
            
            guard let url = URL(string: stringURL) else { return }
            
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        case 1:
            let stringURL = "https://www.flickr.com/photos/158119896@N05/albums"
            guard let url = URL(string: stringURL) else { return }
            
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        default:
            break;
        }
    }
    
    
    let buddyiconUrl = "http://farm5.staticflickr.com/4389/buddyicons/158119896@N05.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBuddyicon()
        GetUserName()
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
            self.buddyicons.layer.cornerRadius = 53
        }
    }
}


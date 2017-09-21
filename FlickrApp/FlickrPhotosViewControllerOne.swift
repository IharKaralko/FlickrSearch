//
//  FlickrPhotosViewControllerOne.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/20/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit


 class FlickrPhotosViewControllerOne: UICollectionViewController {
    
    // MARK: - Properties
    let reuseIdentifier = "SearchCell"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var searches = [FlickrSearchResultsOne]()
    let flickr = FlickrTwo()

    let itemsPerRow: CGFloat = 3

    //1
    var largePhotoIndexPath: IndexPath? {
        didSet {
            //2
            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath {
                indexPaths.append(largePhotoIndexPath)
            }
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }
            //3
            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: indexPaths)
            }) { completed in
                //4
                if let largePhotoIndexPath = self.largePhotoIndexPath {
                    self.collectionView?.scrollToItem(
                        at: largePhotoIndexPath,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }


}

// MARK: - Private
 extension FlickrPhotosViewControllerOne {
    func photoForIndexPath(indexPath: IndexPath) -> Photo {
        return searches[(indexPath as NSIndexPath).section].searchResults[(indexPath as IndexPath).row]
    }
}

extension FlickrPhotosViewControllerOne : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1
//        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        textField.addSubview(activityIndicator)
//        activityIndicator.frame = textField.bounds
//        activityIndicator.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!) {
            results, error in
            
            
        //    activityIndicator.removeFromSuperview()
            
            
            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                // 3
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)
                
                // 4
                self.collectionView?.reloadData()
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - UICollectionViewDataSource
extension FlickrPhotosViewControllerOne {
    //1
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "FlickrPhotoHeaderView",
                                                                             for: indexPath) as! FlickrPhotoHeaderView
            headerView.label.text = searches[(indexPath as NSIndexPath).section].searchTerm
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
    }    
    
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        //1
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
//                                                      for: indexPath) as! FlickrSearchCell
//        //2
//        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
//        cell.backgroundColor = UIColor.white
//        //3
//        cell.searchImage.image = flickrPhoto.thumbnail
//        
//        return cell
//    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrSearchCell
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        
        //        //1
        //        cell.activityIndicator.stopAnimating()
        
        //2
        guard indexPath == largePhotoIndexPath else {
            cell.searchImage.image = flickrPhoto.thumbnail
            return cell
        }
        
        //3
        guard flickrPhoto.largeImage == nil else {
            cell.searchImage.image = flickrPhoto.largeImage
            return cell
        }
        
        //4
        cell.searchImage.image = flickrPhoto.thumbnail
        // cell.activityIndicator.startAnimating()
        
        //5
           flickrPhoto.loadLargeImage(){ loadedFlickrPhoto, error in
        
        //            //6
        //            cell.activityIndicator.stopAnimating()
        
        //7
        //            guard loadedFlickrPhoto.largeImage != nil && error == nil else {
        //                return
        //            }
        
        //8
        if let cell = collectionView.cellForItem(at: indexPath) as? FlickrSearchCell,
            indexPath == self.largePhotoIndexPath  {
            cell.searchImage.image = loadedFlickrPhoto.largeImage
            }
        
        }
        
        
//        //8
//        if let cell = collectionView.cellForItem(at: indexPath) as? FlickrSearchCell,
//                 indexPath == self.largePhotoIndexPath  {
//               cell.searchImage.image = flickrPhoto.loadLargeImage(flickrPhoto) //loadedFlickrPhoto.largeImage
//        }
        //}
        
        return cell
    }
  
    
    
}

extension FlickrPhotosViewControllerOne : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        // New code
        if indexPath == largePhotoIndexPath {
            let flickrPhoto = photoForIndexPath(indexPath: indexPath)
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidthOfSize(size)
        }
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
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
}

// MARK: - UICollectionViewDelegate
extension FlickrPhotosViewControllerOne {
    
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
        return false
    }
}

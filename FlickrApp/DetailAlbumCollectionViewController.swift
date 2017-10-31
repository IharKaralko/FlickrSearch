//
//  DetailAlbumCollectionViewController.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/17/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class DetailAlbumCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    let itemsPerRow: CGFloat = 3
    var setPhotos = [Photo]()
    
    var largePhotoIndexPath: IndexPath? {
        didSet {
            
            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath {
                indexPaths.append(largePhotoIndexPath)
            }
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }
            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: indexPaths)
            }) { completed in
                if let largePhotoIndexPath = self.largePhotoIndexPath {
                    self.collectionView?.scrollToItem(
                        at: largePhotoIndexPath,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }
    
      
 
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DetailAlbumCollectionViewCell
        let photo = setPhotos[indexPath.row]
        
        
        DispatchQueue.global().async{
            do{
            guard  let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.photoID)_\(photo.secret)_m.jpg") else{ return }
            
           //     guard  let imageData = try? Data(contentsOf: url) else { return }
                
             let imageData = try Data(contentsOf: url)
         
                if let image = UIImage(data: imageData) {
                DispatchQueue.main.async{
              
              cell.detailAlbumImage.image = image

                }
            }
             else {return}
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
           }
        return cell
    }
     
    // MARK: - UICollectionViewDelegateFlowLayout
        func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
      
        if indexPath == largePhotoIndexPath {
            let flickrPhoto = setPhotos[indexPath.row]
            var size = collectionView.bounds.size
           size.height -= topLayoutGuide.length
           size.height -= (sectionInsets.top + sectionInsets.right)
           size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidthOfSize(size)
        }

        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - UICollectionViewDelegate
extension DetailAlbumCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
     largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
    }

}


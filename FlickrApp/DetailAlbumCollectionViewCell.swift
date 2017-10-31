//
//  DetailAlbemCollectionViewCell.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/17/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

class DetailAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var detailAlbumImage: UIImageView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        detailAlbumImage.image = nil
    }
}

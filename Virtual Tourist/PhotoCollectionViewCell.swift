//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 19/03/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var taskToCancel : NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    override func prepareForReuse() {
        if photoImageView.image != nil {
            photoImageView.image = nil
        }
    }
    
}

//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 17/04/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {

    // Standard Core Data init method
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Init with dictionary
    
    init(pin: Pin, dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary["id"] as! String
        title = dictionary["title"] as! String
        imagePath = dictionary["url_m"] as! String
        location = pin
        
    }
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier("\(id).jpg")
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: "\(id).jpg")
        }
    }
    
    override func prepareForDeletion() {
        // Setting image to nil will trigger imageCache to delete image data from cache.
        image = nil
        
    }

}

//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 01/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPhotosForPin(pin: Pin, completion:(success: Bool, error: NSError?) -> Void) {
        let parameters: [String: AnyObject] = [
            ParameterKeys.Method: Methods.SearchPhotos,
            ParameterKeys.BoundingBox: createBoundingBoxString(latitude: pin.latitude, longitude: pin.longitude),
            ParameterKeys.Extras: Constants.Extras,
            ParameterKeys.Format: Constants.JSON,
            ParameterKeys.SafeSearch: Constants.SafeSearch
        ]
        
        get(parameters) { (result, error) in
            
            guard let photosDictionary = result[JSONResponseKeys.Photos] as? [String: AnyObject] else {
                completion(success: false, error: error)
                return
            }
            
            guard let totalPhotos = photosDictionary[JSONResponseKeys.Total] as? String where Int(totalPhotos) > 0 else {
                let userInfo = [NSLocalizedDescriptionKey : "No photo is found!"]
                completion(success: false, error: NSError(domain: "noPhoto", code: 0, userInfo: userInfo))
                return
            }
            
            guard let photos = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                let userInfo = [NSLocalizedDescriptionKey : "No such key: photo"]
                completion(success: false, error: NSError(domain: "noSuchKey", code: 1, userInfo: userInfo))
                return
            }
            
            for photoDictionary in photos {
                let _ = Photo(pin: pin, dictionary: photoDictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext)
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            completion(success: true, error: nil)
            
        }
        
    }
    
    // MARK: Helpers
    
    /* Helper: Create bounding box for Flickr Photo Search */
    func createBoundingBoxString(latitude latitude: Double, longitude: Double) -> String {
        
        let bottomLeftLon = max(longitude - BoundingBox.EdgeLength, BoundingBox.LonMin)
        let bottomLeftLat = max(latitude - BoundingBox.EdgeLength, BoundingBox.LatMin)
        let topRightLon = min(longitude + BoundingBox.EdgeLength, BoundingBox.LonMax)
        let topRightLat = min(latitude + BoundingBox.EdgeLength, BoundingBox.LatMax)
        
        return "\(bottomLeftLon),\(bottomLeftLat),\(topRightLon),\(topRightLat)"
    }
    
}
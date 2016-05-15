//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 01/05/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPhotosForPin(pin: Pin, customPage: Int?, completion:(success: Bool, error: NSError?) -> Void) {
        var parameters: [String: AnyObject] = [
            ParameterKeys.Method: Methods.SearchPhotos,
            ParameterKeys.BoundingBox: createBoundingBoxString(latitude: pin.latitude, longitude: pin.longitude),
            ParameterKeys.Extras: Constants.Extras,
            ParameterKeys.Format: Constants.JSON,
            ParameterKeys.SafeSearch: Constants.SafeSearch,
            ParameterKeys.NoJSONCallback: Constants.NoJSONCallback,
            ParameterKeys.PerPage: Constants.PerPage,
            ParameterKeys.Page: customPage ?? 1
        ]
        
        if customPage > Constants.MaxPages {
            parameters[ParameterKeys.Page] = Int(arc4random_uniform(UInt32(Constants.MaxPages)))
        }
        
        get(parameters) { (result, error) in
            
            guard let data = result as? NSData else {
                completion(success: false, error: error)
                return
            }
            
            FlickrClient.parseJSONWithCompletionHandler(data) { (result, error) in
                
                guard let photosDictionary = result[JSONResponseKeys.Photos] as? [String: AnyObject] else {
                    completion(success: false, error: error)
                    return
                }
                
                guard let totalPhotos = photosDictionary[JSONResponseKeys.Total] as? String where Int(totalPhotos) > 0 else {
                    let userInfo = [NSLocalizedDescriptionKey: "No photo is found!"]
                    completion(success: false, error: NSError(domain: "noPhoto", code: 00, userInfo: userInfo))
                    return
                }
                
                if let pages = photosDictionary[JSONResponseKeys.Pages] as? Int {
                    pin.numberOfPhotoPages = pages
                }
                
                guard let photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                    let userInfo = [NSLocalizedDescriptionKey: "No such key: photo"]
                    completion(success: false, error: NSError(domain: "noSuchKey", code: 01, userInfo: userInfo))
                    return
                }
                
                for photoDictionary in photosArray {
                    let _ = Photo(pin: pin, dictionary: photoDictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext)
                }
                
                CoreDataStackManager.sharedInstance().saveContext()
                
                completion(success: true, error: nil)

            }
            
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
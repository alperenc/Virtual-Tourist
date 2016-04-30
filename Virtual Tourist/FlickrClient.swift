//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 28/04/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit

class FlickrClient: NSObject {

}

extension FlickrClient {
    
    // MARK: Constants
    
    struct Constants {
        
        // MARK: API Key
        static let APIKey = APIKeys.Flickr
        
        // MARK: URL
        static let BaseURL = "https://api.flickr.com/services/rest/"
        
        // MARK: Parameters
        static let JSON = "json"
        static let Extras = "url_m"
        static let SafeSearch = "1"
        static let NoJSONCallback = "1"
    }
    
    // MARK: Methods
    
    struct Methods {
        
        // MARK: Search Photos
        static let SearchPhotos = "flickr.photos.search"
    }
    
    // MARK: Parameter Keys
    
    struct ParameterKeys {
        
        static let Method = "method"
        static let ApiKey = "api_key"
        static let BoundingBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
    }
    
    // MARK: URL Keys
    
    struct URLKeys {
        
        // MARK: Server ID
        static let ServerID = "server-id"
        
        // MARK: Photo ID
        static let PhotoID = "id"
        
        // MARK: Photo Secret
        static let PhotoSecret = "secret"
    }
    
    // MARK: JSON Repsonse Keys
    
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Photos
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let PhotoDomain = "url_m"
    }
}

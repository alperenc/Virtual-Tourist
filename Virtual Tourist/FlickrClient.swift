//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 28/04/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit

class FlickrClient: NSObject {
    
    // MARK: Properties
    
    // Shared session
    var session: NSURLSession
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: GET
    
    func get(parameters: [String: AnyObject], completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.APIKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURL + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        return makeRequest(request, completion: completion)
    }
    
    // MARK: Get Image
    
    func getImage(imagePath: String, completion: (imageData: AnyObject!, error: NSError?)-> Void) -> NSURLSessionTask {
        
        let url = NSURL(string: imagePath)!
        
        let request = NSURLRequest(URL: url)
        
        return makeRequest(request, completion: completion)
    }
    
    // MARK: Helpers
    
    /* Helper: Make the request, check the data and return the task */
    func makeRequest(request: NSURLRequest, completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let task = FlickrClient.sharedInstance().session.dataTaskWithRequest(request) { (data, response, error) in
            // Was there an error with the request?
            guard error == nil else {
                print("There was an error with your request: \(error)")
                completion(result: nil, error: error)
                return
            }
            
            // Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Invalid response!"]
                completion(result: nil, error: NSError(domain: "invalidResponse", code: 0, userInfo: userInfo))
                
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "No data returned!"]
                completion(result: nil, error: NSError(domain: "noData", code: 0, userInfo: userInfo))
                return
            }
            
            // Return data in completion
            completion(result: data, error: nil)
        }
        
        // Start the request
        task.resume()
        
        return task
        
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}

extension FlickrClient {
    
    // MARK: Constants
    
    struct Constants {
        
        // MARK: API Key
        static let APIKey = APIKeys.Flickr
        
        // MARK: URL
        static let BaseURL = "https://api.flickr.com/services/rest/"
        
        // MARK: Parameter Constants
        static let JSON = "json"
        static let Extras = "url_m"
        static let SafeSearch = "1"
        static let NoJSONCallback = "1"
        static let Page = Int(arc4random_uniform(100))
        static let PerPage = 25
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
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"

    }
    
    // MARK: JSON Repsonse Keys
    
    struct JSONResponseKeys {
        
        // MARK: Photos
        static let Photos = "photos"
        static let Total = "total"
        
        // MARK: Photo
        static let Photo = "photo"
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let PhotoDomain = "url_m"
    }
    
    // MARK: Bounding Box Constants
    
    struct BoundingBox {
        
        // MARK: Lat/Lon Min&Max
        
        static let LatMin = -90.0
        static let LatMax = 90.0
        static let LonMin = -90.0
        static let LonMax = 90.0
        
        // MARK: Bounding Box Edge Length
        static let EdgeLength = 1.0
    }
}

//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Alp Eren Can on 07/03/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    @IBOutlet weak var addPinGestureRecognizer: UILongPressGestureRecognizer!
    
    var currentAnnotation = MKPointAnnotation()
    
    var editingMode: Bool = false
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedRegion = getMapRegion() {
            mapView.setRegion(savedRegion, animated: true)
        }
        
        // Delegate initialization
        mapView.delegate = self
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // Add fetched pins on tha map
        if let pins = fetchedResultsController.fetchedObjects as? [Pin] {
            mapView.addAnnotations(pins)
            
        }
        
    }
    
    // MARK: Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: Actions and Helpers

    @IBAction func editPins(sender: UIBarButtonItem) {
        editingMode = editingMode ? false : true
        
        if editingMode {
            sender.title = "Done"
            sender.style = .Done
            deletePinsLabel.hidden = false
        } else {
            sender.title = "Edit"
            sender.style = .Plain
            deletePinsLabel.hidden = true
        }
    }
    
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            let location = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            currentAnnotation.coordinate = locationCoordinate
            mapView.addAnnotation(currentAnnotation)
            
        case .Changed:
            let location = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            currentAnnotation.coordinate = locationCoordinate
            
        case .Ended:
            let location = sender.locationInView(mapView)
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            currentAnnotation.coordinate = locationCoordinate
            
            let pin = Pin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            
            mapView.removeAnnotation(currentAnnotation)
            currentAnnotation = MKPointAnnotation()
            
            mapView.addAnnotation(pin)
            
            // Close in on the pin
            mapView.setRegion(MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpanMake(5.0, 5.0)), animated: true)
            
            // And save the map region
            saveMapRegion()
            
            // Get photos for the pin as soon as the user drops it on the map
            let flickrInstance = FlickrClient.sharedInstance()
            
            flickrInstance.getPhotosForPin(pin) { (success, error) in
                if success {
                    let moc = CoreDataStackManager.sharedInstance().managedObjectContext
                    
                    let photosFetch = NSFetchRequest(entityName: "Photo")
                    photosFetch.predicate = NSPredicate(format: "location == %@", pin)
                    photosFetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
                    
                    do {
                        let photos = try moc.executeFetchRequest(photosFetch) as! [Photo]
                        
                        for photo in photos {
                            flickrInstance.getImage(photo.imagePath) { (data, error) in
                                if let imageData = data as? NSData {
                                    photo.image = UIImage(data: imageData)
                                } else {
                                    print("Error downloading images: \(error)")
                                }
                                
                            }
                        }
                        
                    } catch {}
                    
                } else {
                    print("Error getting photo info for this location: \(error)")
                }
            }
            
        default:
            return
            
        }
        
    }
    
    func saveMapRegion() {
        
        let regionDictionary = [
            RegionKeys.Latitude: mapView.region.center.latitude,
            RegionKeys.Longitude: mapView.region.center.longitude,
            RegionKeys.LatitudeDelta: mapView.region.span.latitudeDelta,
            RegionKeys.LongitudeDelta: mapView.region.span.longitudeDelta]
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(regionDictionary, forKey: "mapRegion")
        userDefaults.setValuesForKeysWithDictionary(regionDictionary)
        
    }

    func getMapRegion() -> MKCoordinateRegion? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        guard let regionDictionary = userDefaults.dictionaryForKey("mapRegion") else {
            return nil
        }
        
        guard let latitude = regionDictionary[RegionKeys.Latitude] as? CLLocationDegrees,
            let longitude = regionDictionary[RegionKeys.Longitude] as? CLLocationDegrees,
            let latitudeDelta = regionDictionary[RegionKeys.LatitudeDelta] as? CLLocationDegrees,
            let longitudeDelta = regionDictionary[RegionKeys.LongitudeDelta] as? CLLocationDegrees else {
                return nil
        }
        
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotoAlbum" {
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
            photoAlbumVC.pin = sender as! Pin
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        guard let pin = view.annotation as? Pin else {
            print("Selected annotation is not a Pin!")
            return
        }
        
        if editingMode {
            sharedContext.deleteObject(pin)
            CoreDataStackManager.sharedInstance().saveContext()
            
        } else {
            performSegueWithIdentifier("showPhotoAlbum", sender: pin)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        guard let pin = anObject as? Pin else {
            return
        }
        
        switch type {
        case .Delete:
            mapView.removeAnnotation(pin)
            
        case .Insert:
            mapView.addAnnotation(pin)
            
        default:
            return
            
        }
    }

}

extension TravelLocationsMapViewController {
    
    // MARK: Region keys
    struct RegionKeys {
        
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
        
    }
}


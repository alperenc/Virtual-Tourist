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
        
        // Delegate initialization
        mapView.delegate = self
        fetchedResultsController.delegate = self
        
        // Perform fetch
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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: Actions

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
            currentAnnotation = MKPointAnnotation()
            
            let pin = Pin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            
        default:
            return
            
        }
        
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotoAlbum" {
            let photoAlbumVC = segue.destinationViewController as! PhotoAlbumViewController
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
            return
        }
        
        if editingMode {
            sharedContext.deleteObject(pin)
            CoreDataStackManager.sharedInstance().saveContext()
            
        } else {
            performSegueWithIdentifier("showPhotoAlbum", sender: self)
        }
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

